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