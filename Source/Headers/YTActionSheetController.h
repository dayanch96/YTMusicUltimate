#import "YTActionSheetAction.h"

@interface YTActionSheetController : NSObject
@property (nonatomic, strong, readwrite) UIView *sourceView;
- (void)addAction:(YTActionSheetAction *)action;
- (void)addHeaderWithTitle:(NSString *)title subtitle:(NSString *)subtitle;
- (void)presentFromViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void(^)(void))completion;
@end