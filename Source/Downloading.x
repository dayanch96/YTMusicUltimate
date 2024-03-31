#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FFMpegDownloader.h"
#import "Headers/YTAssetLoader.h"
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
        YTAssetLoader *al = [[%c(YTAssetLoader) alloc] initWithBundle:[NSBundle mainBundle]];

        YTMActionSheetController *sheetController = [%c(YTMActionSheetController) musicActionSheetController];
        sheetController.sourceView = sender;
        [sheetController addHeaderWithTitle:LOC(@"SELECT_ACTION") subtitle:nil];

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"DOWNLOAD_AUDIO") iconImage:[al imageNamed:@"yt_outline_audio_24pt"] style:0 handler:^ {
            [self downloadAudio];
        }]];

        [sheetController addAction:[%c(YTActionSheetAction) actionWithTitle:LOC(@"DOWNLOAD_COVER") iconImage:[al imageNamed:@"youtube_outline/image_24pt"] style:0 handler:^ {
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

    NSData *manifestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
    NSString *manifestString = [[NSString alloc] initWithData:manifestData encoding:NSUTF8StringEncoding];

    NSError *regexError = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#EXT-X-MEDIA:URI=\"(https://.*?/index.m3u8)\"" options:0 error:&regexError];

    if (!regexError) {
        NSTextCheckingResult *match = [regex firstMatchInString:manifestString options:0 range:NSMakeRange(0, [manifestString length])];

        if (match && [match numberOfRanges] >= 2) {
            NSString *extractedURL = [manifestString substringWithRange:[match rangeAtIndex:1]];
            [ffmpeg downloadAudio:extractedURL];

            NSMutableArray *thumbnailsArray = playerResponse.playerData.videoDetails.thumbnail.thumbnailsArray;
            YTIThumbnailDetails_Thumbnail *thumbnail = [thumbnailsArray lastObject];
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:thumbnail.URL]];

            if (imageData) {
                NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
                NSURL *coverURL = [documentsURL URLByAppendingPathComponent:[NSString stringWithFormat:@"YTMusicUltimate/%@ - %@.png", author, title]];
                [imageData writeToURL:coverURL atomically:YES];
            }
        }
    } else {
        YTAlertView *alertView = [%c(YTAlertView) infoDialog];
        alertView.title = LOC(@"OOPS");
        alertView.subtitle = regexError.localizedDescription;
        [alertView show];
    }
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

%ctor {
    if (!YTMU(@"premiumWorkaround") && !YTMU(@"workaroundReminded")) {
        NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];
        [YTMUltimateDict setObject:@(YES) forKey:@"workaroundReminded"];
        [[NSUserDefaults standardUserDefaults] setObject:YTMUltimateDict forKey:@"YTMUltimate"];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            YTAlertView *alertView = [%c(YTAlertView) confirmationDialogWithAction:^{
                [YTMUltimateDict setObject:@(YES) forKey:@"premiumWorkaround"];
            }
            actionTitle:LOC(@"YES")];
            alertView.title = @"YTMusicUltimate";
            alertView.subtitle = [NSString stringWithFormat:LOC(@"WORKAROUND_REMINDER"), LOC(@"PREMIUM_SETTINGS"), LOC(@"FORCE_PREMIUM"), LOC(@"FORCE_PREMIUM")];
            [alertView show];
        });
    }
}
