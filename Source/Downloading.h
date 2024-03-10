#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FFMpegDownloader.h"

#define BHButtonType 909
#define STYLE_LIGHT_TEXT 15
#define SIZE_DEFAULT 1
#define buttonAccessibilityLabel @"BHDownloadButton"

@interface UIView (NearestViewController)
- (UIViewController *)nearestViewController;
@end

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

@interface YTMWatchViewController : UIViewController
@property (nonatomic, weak, readwrite) YTPlayerViewController *playerViewController;
@end

@interface YTMNowPlayingViewController : UIViewController
@property (nonatomic, weak, readwrite) YTMWatchViewController *parentViewController;
@end

@interface YTAlertView : UIView
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *subtitle;
+ (instancetype)infoDialog;
+ (instancetype)confirmationDialogWithAction:(void (^)(void))action actionTitle:(NSString *)actionTitle;
- (void)show;
@end

// Add new button to YTM player action bar
// Credits to @BandarHL
@interface YTCommonColorPalette : NSObject
- (UIColor *)textPrimary;
@end

@interface YTPageStyleController : NSObject
+ (YTCommonColorPalette *)currentColorPalette;
+ (NSInteger)pageStyle;
@property (nonatomic, assign, readwrite) NSInteger appThemeSetting;
@property (nonatomic, assign, readonly) NSInteger pageStyle;
@end

@interface QTMIcon: NSObject
+ (UIImage *)imageWithName:(NSString *)name color:(UIColor *)color;
+ (UIImage *)tintImage:(UIImage *)image color:(UIColor *)color;
@end

@interface YTIFormattedString : NSObject
+ (id)formattedStringWithString:(id)arg1;
@end

@interface YTIBrowseEndpoint: NSObject
@property (nonatomic, copy, readwrite) NSString *browseId;
@end

@interface YTICommand: NSObject
@property (nonatomic, readwrite, strong) YTIBrowseEndpoint *browseEndpoint;
@end

@interface YTIAccessibilityData: NSObject
@property (nonatomic, copy, readwrite) NSString *label;
@end

@interface YTIAccessibilitySupportedDatas: NSObject
@property (nonatomic, strong, readwrite) YTIAccessibilityData *accessibilityData;
@end

@interface YTIIcon: NSObject
@property (nonatomic, assign, readwrite) int iconType;
@property (nonatomic, assign, readwrite) BOOL hasIconType;
@end

@interface YTIButtonRenderer: NSObject
@property (nonatomic, assign, readwrite) int style;
@property (nonatomic, assign, readwrite) int size;
@property (nonatomic, strong, readwrite) YTIIcon *icon;
@property (nonatomic, readwrite, strong) YTIFormattedString *text;
@property (nonatomic, strong, readwrite) YTIAccessibilityData *accessibility;
@property (nonatomic, strong, readwrite) YTIAccessibilitySupportedDatas *accessibilityData;
@property (nonatomic, strong, readwrite) YTICommand *command;
@end

@interface YTIPlayerOverlayActionSupportedRenderers: NSObject
@property (nonatomic, strong, readwrite) YTIButtonRenderer *buttonRenderer;
@end

@interface YTIPlayerOverlayRenderer: NSObject
@property (nonatomic, strong, readwrite) NSMutableArray *actionsArray;
@end

@interface MDCButton: UIButton
@end

@interface YTMActionRowView: UIView
{
	UIScrollView *_scrollView;
	NSMutableArray *_actionButtons;
	NSMutableArray *_actionButtonsFromRenderers;
}

- (void)ytmuButtonAction:(MDCButton *)sender;
- (void)downloadAudio;
- (void)downloadCoverImage;
@end

@interface YTActionSheetAction : NSObject
+ (instancetype)actionWithTitle:(NSString *)title iconImage:(UIImage *)image style:(NSInteger)style handler:(void (^)(void))handler;
@end

@interface YTActionSheetController : NSObject
- (void)addAction:(YTActionSheetAction *)action;
- (void)addHeaderWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
- (void)presentFromViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void(^)(void))completion;
@end

@interface YTMActionSheetController : YTActionSheetController
+ (instancetype)musicActionSheetController;
@end
