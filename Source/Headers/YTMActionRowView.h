#import <UIKit/UIKit.h>
#import "YTMNowPlayingViewController.h"
#import "Headers/MDCButton.h"

@interface YTMActionRowView : UIView {
	UIScrollView *_scrollView;
	NSMutableArray *_actionButtons;
	NSMutableArray *_actionButtonsFromRenderers;
}

@property (nonatomic, weak, readonly) YTMNowPlayingViewController *parentResponder;

- (void)ytmuButtonAction:(MDCButton *)sender;
- (void)downloadAudio;
- (void)downloadCoverImage;
@end