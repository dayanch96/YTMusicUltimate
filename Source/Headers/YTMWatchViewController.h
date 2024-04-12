#import "YTPlayerViewController.h"

@interface YTMWatchViewController : UIViewController
@property (nonatomic, weak, readwrite) YTPlayerViewController *playerViewController;

- (void)resetMiniplayerRestrictions;
@end