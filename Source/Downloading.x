#import "FFMpegDownloader.h"

@implementation UIView (NearestViewController)
- (UIViewController *)nearestViewController {
    UIResponder *responder = self.nextResponder;
    while (responder) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        } responder = responder.nextResponder;
    } return nil;
}
@end

@interface YTIFormatStream : NSObject
@property (nonatomic, copy, readwrite) NSString *URL;
@end

@interface YTIStreamingData : NSObject
@property (nonatomic, copy, readwrite) NSString *hlsManifestURL;
@property (nonatomic, copy, readwrite) NSMutableArray *adaptiveFormatsArray;
@end

@interface YTIThumbnailDetails_Thumbnail : NSObject
@property (nonatomic, copy, readwrite) NSString *URL;
@property (nonatomic, assign, readwrite) unsigned int width;
@end

@interface YTIThumbnailDetails : NSObject
@property (nonatomic, strong, readwrite) NSMutableArray *thumbnailsArray;
@end

@interface YTIVideoDetails : NSObject
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *author;
@property (nonatomic, strong, readwrite) YTIThumbnailDetails *thumbnail;
@end

@interface YTIPlayerResponse : NSObject
@property (nonatomic, assign, readonly) YTIStreamingData *streamingData;
@property (nonatomic, assign, readonly) YTIVideoDetails *videoDetails;
@end

@interface YTPlayerResponse : NSObject
@property (nonatomic, assign, readonly) YTIPlayerResponse *playerData;
@end

@interface YTPlayerViewController : UIViewController
@property (nonatomic, assign, readonly) YTPlayerResponse *playerResponse;
@property (readonly, nonatomic) NSString *contentVideoID;
@property (nonatomic, assign, readonly) CGFloat currentVideoTotalMediaTime;
@end

@interface YTPlayerView : UIView
@property (nonatomic, strong) FFMpegDownloader *ffmpeg;
@property (nonatomic, assign, readwrite) UIViewController *viewDelegate;
- (void)prepareForDownloading:(UILongPressGestureRecognizer *)sender;
@end

@interface YTAlertView : UIView
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *subtitle;
+ (instancetype)infoDialog;
+ (instancetype)confirmationDialogWithAction:(void (^)(void))action actionTitle:(NSString *)actionTitle;
- (void)show;
@end

%hook YTPlayerView
%property (nonatomic, strong) FFMpegDownloader *ffmpeg;
- (void)setOverlayView:(id)arg1 {
    %orig;

    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(prepareForDownloading:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}

%new
- (void)prepareForDownloading:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        YTPlayerViewController *parentVC = (YTPlayerViewController *)[self nearestViewController];
        if (parentVC.playerResponse) {
            NSString *title = parentVC.playerResponse.playerData.videoDetails.title;
            NSString *author = parentVC.playerResponse.playerData.videoDetails.author;
            NSString *urlStr = parentVC.playerResponse.playerData.streamingData.hlsManifestURL;

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LOC(@"SELECT_ACTION") message:nil preferredStyle:UIAlertControllerStyleActionSheet];

            UIAlertAction *audioAction = [UIAlertAction actionWithTitle:LOC(@"DOWNLOAD_AUDIO") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                self.ffmpeg = [[FFMpegDownloader alloc] init];
                self.ffmpeg.tempName = parentVC.contentVideoID;
                self.ffmpeg.mediaName = [NSString stringWithFormat:@"%@ - %@", author, title];
                self.ffmpeg.duration = round(parentVC.currentVideoTotalMediaTime);

                NSData *manifestData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
                NSString *manifestString = [[NSString alloc] initWithData:manifestData encoding:NSUTF8StringEncoding];

                NSError *regexError = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#EXT-X-MEDIA:URI=\"(https://.*?/index.m3u8)\"" options:0 error:&regexError];

                if (!regexError) {
                    NSTextCheckingResult *match = [regex firstMatchInString:manifestString options:0 range:NSMakeRange(0, [manifestString length])];

                    if (match && [match numberOfRanges] >= 2) {
                        NSString *extractedURL = [manifestString substringWithRange:[match rangeAtIndex:1]];
                        [self.ffmpeg downloadAudio:extractedURL];

                        NSMutableArray *thumbnailsArray = parentVC.playerResponse.playerData.videoDetails.thumbnail.thumbnailsArray;
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
            }];

            UIAlertAction *photoAction = [UIAlertAction actionWithTitle:LOC(@"DOWNLOAD_COVER") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                dispatch_async(dispatch_get_main_queue(), ^{
                    hud.mode = MBProgressHUDModeIndeterminate;
                });

                NSMutableArray *thumbnailsArray = parentVC.playerResponse.playerData.videoDetails.thumbnail.thumbnailsArray;
                YTIThumbnailDetails_Thumbnail *thumbnail = [thumbnailsArray lastObject];
                NSString *thumbnailURL = [thumbnail.URL stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"w%u-h%u-", thumbnail.width, thumbnail.width] withString:@"w2048-h2048-"];

                self.ffmpeg = [[FFMpegDownloader alloc] init];
                [self.ffmpeg downloadImage:[NSURL URLWithString:thumbnailURL]];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                });
            }];

            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LOC(@"CANCEL") style:UIAlertActionStyleCancel handler:nil];

            [audioAction setValue:[UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0] forKey:@"titleTextColor"];
            [photoAction setValue:[UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0] forKey:@"titleTextColor"];
            [cancelAction setValue:[UIColor colorWithRed:230/255.0 green:75/255.0 blue:75/255.0 alpha:255/255.0] forKey:@"titleTextColor"];
            [alertController addAction:audioAction];
            [alertController addAction:photoAction];
            [alertController addAction:cancelAction];

            UIViewController *currentVC = [self nearestViewController];
            [currentVC presentViewController:alertController animated:YES completion:nil];
        } else {
            YTAlertView *alertView = [%c(YTAlertView) infoDialog];
            alertView.title = LOC(@"DONT_RUSH");
            alertView.subtitle = LOC(@"DONT_RUSH_DESC");
            [alertView show];
        }
    }
}
%end
