#import "YTMUltimatePrefs.h"
#import "YTMUltimateSettingsController.h"
#import <UIKit/UIKit.h>

@interface UIView (Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface YTMSettings : NSObject
@property(nonatomic, getter=isNerdStatsEnabled) _Bool nerdStatsEnabled;
@end

@interface YTMSettingsCell : UIView
@end

@interface YTASyncCollectionView : UIView
@end

@interface YTMNowPlayingView : UIView
@end

@interface YTPivotBarItemView : UIView
@property(retain, nonatomic) UIView *navigationButton;
@end

@interface YTMAccountButton : UIButton
- (void)didTap;
- (id)initWithTitle:(id)arg1 identifier:(id)arg2 icon:(id)arg3 actionBlock:(void (^)(BOOL finished))arg4;
@end

@interface GOOHeaderViewController : UIViewController
@end

@interface YTMAvatarAccountView : UIView
@property(nonatomic,strong) YTMUltimateSettingsController *YTMUltimateController;
@end

// Color
@interface UIKeyboardDockView : UIView
@end

@interface UIKeyboardLayoutStar : UIView
@end

@interface YTPivotBarView : UIView
@end

@interface YTMMusicMenuTitleView : UIView
@end

@interface MDCSnackbarMessageView : UIView
@end

@interface UIPredictionViewController : UIViewController
@end

@interface UICandidateViewController : UIViewController
@end

@interface YTMBackgroundUpsellNotificationController : NSObject
- (void)removePendingBackgroundNotifications;
@end