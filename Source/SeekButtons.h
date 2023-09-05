#import <UIKit/UIKit.h>

@interface YTMPlayerControlsView : UIView
@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *nextButton;
- (void)didTapPrevButton;
- (void)didTapNextButton;
- (void)didTapSeekBackwardButton;
- (void)didTapSeekForwardButton;
@end
