#import "YTPlayerViewController.h"

@interface YTPlayerView : UIView
@property (nonatomic, assign, readwrite) UIViewController *viewDelegate;
@property (nonatomic, assign, readwrite) YTPlayerViewController *playerViewDelegate;
- (void)prepareForDownloading:(UILongPressGestureRecognizer *)sender;
@end