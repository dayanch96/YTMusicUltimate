#import <Foundation/Foundation.h>
#import <rootless.h>

static inline NSBundle *YTMusicUltimateBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTMusicUltimate" ofType:@"bundle"];
        NSString *rootlessBundlePath = ROOT_PATH_NS(@"/Library/Application Support/YTMusicUltimate.bundle");

        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: rootlessBundlePath];
    });

    return bundle;
}

static inline NSString *LOC(NSString *key) {
    return [YTMusicUltimateBundle() localizedStringForKey:key value:nil table:nil];
}

@interface ABCSwitch : UIControl
@property (nonatomic, strong) UIColor *onTintColor;
@property (nonatomic, assign, readwrite, getter=isOn) BOOL on;
@end

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