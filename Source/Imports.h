#include "Prefs/YTMUltimatePrefs.h"
#include "Prefs/YTMUltimateSettingsController.h"
#import <UIKit/UIKit.h>

@interface UIView (Private)
- (UIViewController *)_viewControllerForAncestor;
@end

@interface YTFormattedStringLabel: UILabel
@property (nonatomic, strong) UITextView *lyricsTextView;
- (BOOL)isLyricsView;
@end

@interface YTIPivotBarItemRenderer : NSObject
 @property(copy, nonatomic) NSString *pivotIdentifier;
 - (NSString *)pivotIdentifier;
 @end

 @interface YTIPivotBarIconOnlyItemRenderer : NSObject
 - (NSString *)pivotIdentifier;
 @end

 @interface YTIPivotBarSupportedRenderers : NSObject
 @property(retain, nonatomic) YTIPivotBarItemRenderer *pivotBarItemRenderer;
 - (YTIPivotBarItemRenderer *)pivotBarItemRenderer;
 - (YTIPivotBarIconOnlyItemRenderer *)pivotBarIconOnlyItemRenderer;
 @end

 @interface YTIPivotBarRenderer : NSObject
 - (NSMutableArray <YTIPivotBarSupportedRenderers *> *)itemsArray;
 @end

@interface YTMAccountButton : UIButton
- (void)didTap;
- (id)initWithTitle:(id)arg1 identifier:(id)arg2 icon:(id)arg3 actionBlock:(void (^)(BOOL finished))arg4;
@end

@interface GOOHeaderViewController : UIViewController
@end

@interface YTPivotBarItemView : UIView
@property(retain, nonatomic) UIView *navigationButton;
@end

@interface YTMAvatarAccountView : UIView
@property(nonatomic,strong) YTMUltimateSettingsController *YTMUltimateController;
@end

@interface SSOConfiguration : NSObject
@end

// Color
@interface YTCommonColorPalette : NSObject
@property(readonly, nonatomic) long long pageStyle;
@end
@interface YTMPlayerPageColorScheme : NSObject
- (void)setPlayButtonColor:(UIColor *)color;
@end

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