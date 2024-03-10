#import <UIKit/UIKit.h>

@interface YTMChipCloudView : UIView
@property (nonatomic, strong) UIColor *backgroundColor;
@end

@interface YTPivotBarView : UIView
@end

@interface YTQTMButton : UIButton
- (void)setSizeWithPaddingAndInsets:(BOOL)sizeWithPaddingAndInsets;
@end

@interface YTPivotBarItemView : UIView
@property (nonatomic, strong, readwrite) YTQTMButton *navigationButton;
@end

@interface YTPivotBarViewController : UIViewController
- (void)selectItemWithPivotIdentifier:(id)pivotIndentifier;
@end

@interface YTIPivotBarItemRenderer : NSObject
@property(copy, nonatomic) NSString *pivotIdentifier;
- (NSString *)pivotIdentifier;
@end

@interface YTIPivotBarSupportedRenderers : NSObject
@property(retain, nonatomic) YTIPivotBarItemRenderer *pivotBarItemRenderer;
- (YTIPivotBarItemRenderer *)pivotBarItemRenderer;
@end

@interface YTIPivotBarRenderer : NSObject
- (NSMutableArray <YTIPivotBarSupportedRenderers *> *)itemsArray;
@end

@interface YTPlayabilityResolutionUserActionUIController : NSObject
- (void)confirmAlertDidPressConfirm;
@end
