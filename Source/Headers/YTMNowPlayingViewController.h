#import "YTMWatchViewController.h"

@interface YTMNowPlayingViewController : UIViewController
@property (nonatomic, weak, readwrite) YTMWatchViewController *parentViewController;

- (void)didTapNextButton;
- (void)didTapPrevButton;
- (void)didTapSeekForwardButton;
- (void)didTapSeekBackwardButton;
- (void)longPressPrev:(UILongPressGestureRecognizer *)gesture;
- (void)longPressNext:(UILongPressGestureRecognizer *)gesture;
@end