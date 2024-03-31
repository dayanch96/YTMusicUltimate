#import <UIKit/UIKit.h>

@interface YTAlertView : UIView
@property (nonatomic, copy, readwrite) UIImage *icon;
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *subtitle;
@property (nonatomic, strong, readwrite) UIView *customContentView;
@property (nonatomic, assign, readwrite) UIEdgeInsets customContentViewInsets; //(8, 24, 0, 24) by default
- (CGRect)frameForDialog;
- (void)show;

+ (instancetype)infoDialog;
+ (instancetype)confirmationDialogWithAction:(void (^)(void))action actionTitle:(NSString *)actionTitle;
@end