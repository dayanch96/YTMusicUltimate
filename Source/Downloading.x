#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FFMpegDownloader.h"
#import "Headers/YTUIResources.h"
#import "Headers/YTMActionSheetController.h"
#import "Headers/YTMActionRowView.h"
#import "Headers/YTIPlayerOverlayRenderer.h"
#import "Headers/YTIPlayerOverlayActionSupportedRenderers.h"
#import "Headers/YTMNowPlayingViewController.h"
#import "Headers/YTPlayerView.h"
#import "Headers/YTIThumbnailDetails_Thumbnail.h"
#import "Headers/YTIFormatStream.h"
#import "Headers/YTAlertView.h"

#define BHButtonType 909
#define STYLE_LIGHT_TEXT 15
#define SIZE_DEFAULT 1
#define buttonAccessibilityLabel @"BHDownloadButton"

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

// Set action bar button icon
%hook YTIIcon
- (UIImage *)iconImageWithColor:(UIColor *)color {
    if (self.iconType == BHButtonType) {
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(24, 24)];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
            UIImage *buttonImage = [UIImage systemImageNamed:@"flame"];
            UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
            UIImageView *buttonImageView = [[UIImageView alloc] initWithImage:buttonImage];
            buttonImageView.contentMode = UIViewContentModeScaleAspectFit;
            buttonImageView.clipsToBounds = YES;
            buttonImageView.tintColor = color;
            buttonImageView.frame = imageView.bounds;

            [imageView addSubview:buttonImageView];
            [imageView.layer renderInContext:rendererContext.CGContext];
        }];

        if ([image respondsToSelector:@selector(imageFlippedForRightToLeftLayoutDirection)]) {
            image = [image imageFlippedForRightToLeftLayoutDirection];
        }

        return image;
    }

    return %orig;
}
%end

@interface YTMActionRowView ()
- (NSString *)getURLFromManifest:(NSURL *)manifest;
@end

// Set action bar button
%hook YTMActionRowView
- (void)setButtonRenderers:(NSArray *)supportedRenderers {
    NSMutableArray *newSupportedRenderers = [supportedRenderers mutableCopy];

    YTIBrowseEndpoint *endPoint = [[%c(YTIBrowseEndpoint) alloc] init];
    endPoint.browseId = buttonAccessibilityLabel;

    YTICommand *command = [[%c(YTICommand) alloc] init];
    command.browseEndpoint = endPoint;

    YTIIcon *icon = [[%c(YTIIcon) alloc] init];
    icon.iconType = BHButtonType;

    YTIAccessibilityData *accessibilityDataString = [[%c(YTIAccessibilityData) alloc] init];
    accessibilityDataString.label = buttonAccessibilityLabel;

    YTIButtonRenderer *buttonRenderer = [[%c(YTIButtonRenderer) alloc] init];
    buttonRenderer.style = STYLE_LIGHT_TEXT;
    buttonRenderer.size = SIZE_DEFAULT;
    buttonRenderer.icon = icon;

    YTIFormattedString *text = [%c(YTIFormattedString) formattedStringWithString:@"YTMUltimate"];
    if (!YTMU(@"premiumWorkaround")) [buttonRenderer setText:text];

    buttonRenderer.accessibility = accessibilityDataString;
    buttonRenderer.accessibilityData.accessibilityData = accessibilityDataString;

    YTIPlayerOverlayActionSupportedRenderers *supportedRenderer = [[%c(YTIPlayerOverlayActionSupportedRenderers) alloc] init];
    [supportedRenderer setButtonRenderer:buttonRenderer];

    [newSupportedRenderers insertObject:supportedRenderer atIndex:1];
    YTMU(@"YTMUltimateIsEnabled") && (YTMU(@"downloadAudio") || YTMU(@"downloadCoverImage")) ? %orig(newSupportedRenderers) : %orig;

    NSMutableArray *actionButtonsFromRenderers = [self valueForKey:@"_actionButtonsFromRenderers"];
    MDCButton *ytmuButtonRenderer = actionButtonsFromRenderers.firstObject;
    if ([ytmuButtonRenderer.accessibilityLabel isEqualToString:buttonAccessibilityLabel]) {
        [ytmuButtonRenderer addTarget:self action:@selector(ytmuButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

%new
- (void)ytmuButtonAction:(MDCButton *)sender {
    YTPlayerResponse *playerResponse = self.parentResponder.parentViewController.playerViewController.playerResponse;

    if (playerResponse) {
        YTMActionSheetController *sheetController = [%c(YTMActionSheetController) musicActionSheetController];
        sheetController.sourceView = sender;
        [sheetController addHeaderWithTitle:LOC(@"SELECT_ACTION") subtitle:nil];

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"DOWNLOAD_AUDIO") iconImage:[%c(YTUIResources) audioOutline] style:0 handler:^ {
            [self downloadAudio];
        }]];

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"DOWNLOAD_COVER") iconImage:[%c(YTUIResources) outlineImageWithColor:[UIColor whiteColor]] style:0 handler:^ {
            [self downloadCoverImage];
        }]];

        if (YTMU(@"downloadAudio") && YTMU(@"downloadCoverImage")) {
            [sheetController presentFromViewController:self.parentResponder animated:YES completion:nil];
        } else if (YTMU(@"downloadAudio")) {
            [self downloadAudio];
        } else if (YTMU(@"downloadCoverImage")) {
            [self downloadCoverImage];
        }
    } else {
        YTAlertView *alertView = [%c(YTAlertView) infoDialog];
        alertView.title = LOC(@"DONT_RUSH");
        alertView.subtitle = LOC(@"DONT_RUSH_DESC");
        [alertView show];
    }
}

%new
- (void)downloadAudio {
    YTMNowPlayingViewController *parentVC = self.parentResponder;
    YTPlayerResponse *playerResponse = parentVC.parentViewController.playerViewController.playerResponse;

    NSString *title = [playerResponse.playerData.videoDetails.title stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *author = [playerResponse.playerData.videoDetails.author stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *urlStr = playerResponse.playerData.streamingData.hlsManifestURL;

    FFMpegDownloader *ffmpeg = [[FFMpegDownloader alloc] init];
    ffmpeg.tempName = parentVC.parentViewController.playerViewController.contentVideoID;
    ffmpeg.mediaName = [NSString stringWithFormat:@"%@ - %@", author, title];
    ffmpeg.duration = round(parentVC.parentViewController.playerViewController.currentVideoTotalMediaTime);

    
    NSString *extractedURL = [self getURLFromManifest:[NSURL URLWithString:urlStr]];
    
    if (extractedURL.length > 0) {
        [ffmpeg downloadAudio:extractedURL];

        NSMutableArray *thumbnailsArray = playerResponse.playerData.videoDetails.thumbnail.thumbnailsArray;
        YTIThumbnailDetails_Thumbnail *thumbnail = [thumbnailsArray lastObject];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnail.URL]];

        if (imageData) {
            NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
            NSURL *coverURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"YTMusicUltimate/%@ - %@.png", author, title]];
            [imageData writeToURL:coverURL atomically:YES];
        }
    } else {
        YTAlertView *alertView = [%c(YTAlertView) infoDialog];
        alertView.title = LOC(@"OOPS");
        alertView.subtitle = LOC(@"LINK_NOT_FOUND");
        [alertView show];
    }
}

%new
- (NSString *)getURLFromManifest:(NSURL *)manifest {
    NSData *manifestData = [NSData dataWithContentsOfURL:manifest];
    NSString *manifestString = [[NSString alloc] initWithData:manifestData encoding:NSUTF8StringEncoding];
    NSArray *manifestLines = [manifestString componentsSeparatedByString:@"\n"];

    NSArray *groupIDS = @[@"234", @"233"]; // Our priority to find group id 234
    for (NSString *groupID in groupIDS) {
        for (NSString *line in manifestLines) {
            NSString *searchString = [NSString stringWithFormat:@"TYPE=AUDIO,GROUP-ID=\"%@\"", groupID];
            if ([line containsString:searchString]) {
                NSRange startRange = [line rangeOfString:@"https://"];
                NSRange endRange = [line rangeOfString:@"index.m3u8"];

                if (startRange.location != NSNotFound && endRange.location != NSNotFound) {
                    NSRange targetRange = NSMakeRange(startRange.location, NSMaxRange(endRange) - startRange.location);
                    return [line substringWithRange:targetRange];
                }
            }
        }
    }

    return nil;
}

%new
- (void)downloadCoverImage {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        hud.mode = MBProgressHUDModeIndeterminate;
    });

    YTMNowPlayingViewController *parentVC = self.parentResponder;
    YTPlayerResponse *playerResponse = parentVC.parentViewController.playerViewController.playerResponse;
    NSMutableArray *thumbnailsArray = playerResponse.playerData.videoDetails.thumbnail.thumbnailsArray;
    YTIThumbnailDetails_Thumbnail *thumbnail = [thumbnailsArray lastObject];
    NSString *thumbnailURL = [thumbnail.URL stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"w%u-h%u-", thumbnail.width, thumbnail.width] withString:@"w2048-h2048-"];

    FFMpegDownloader *ffmpeg = [[FFMpegDownloader alloc] init];
    [ffmpeg downloadImage:[NSURL URLWithString:thumbnailURL]];

    dispatch_async(dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
    });
}
%end
