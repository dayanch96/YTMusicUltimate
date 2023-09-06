#import <UIKit/UIKit.h>

@interface UIView (NearestViewController)
- (UIViewController *)nearestViewController;
@end

@interface YTMNowPlayingViewController : UIViewController
- (void)didTapPrevButton;
- (void)didTapNextButton;
@end

@interface YTMPlayerControlsView : UIView
@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *nextButton;
- (UIViewController *)nearestViewController;
- (void)didTapSeekBackwardButton;
- (void)didTapSeekForwardButton;
- (void)longPressPrev:(UILongPressGestureRecognizer *)gesture;
- (void)longPressNext:(UILongPressGestureRecognizer *)gesture;
@end
