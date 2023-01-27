#import <UIKit/UIKit.h>

static BOOL didFinishLaunching;

%hook YTAppDelegate
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey, id> *)launchOptions {
    didFinishLaunching = %orig;

    if (IsEnabled(@"flex_enabled")) {
        [[FLEXManager sharedManager] showExplorer];
    }

    return didFinishLaunching;
}
- (void)appWillResignActive:(id)arg1 {
    %orig;
        if (IsEnabled(@"flex_enabled")) {
        [[FLEXManager sharedManager] showExplorer];
    }
}
%end
%end

%ctor{

    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL selectableLyrics = ([[NSUserDefaults standardUserDefaults] objectForKey:@"flex_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"flex_enabled"] : NO;
    
    if (isEnabled){
        if (FLEX) {
            %init(FLEX);
        }
    }
}