#import <UIKit/UIKit.h>

@interface YTMChipCloudView : UIView
@property (nonatomic, strong) UIColor *backgroundColor;
@end

@interface YTPivotBarView : UIView
@end

@interface YTPivotBarItemView : UIView
@end

@interface YTQTMButton : UIButton
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