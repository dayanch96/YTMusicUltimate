#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [dict[key] boolValue];
}

@interface YTMAppDelegate : UIResponder
- (void)autoClearCache;
@end

%hook YTMAppDelegate

%new
- (void)autoClearCache {
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:cachePath error:nil];
    for (NSString *file in files) {
        NSString *fullPath = [cachePath stringByAppendingPathComponent:file];
        [fileManager removeItemAtPath:fullPath error:nil];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    BOOL result = %orig;
    if (YTMU(@"YTMUltimateIsEnabled") && YTMU(@"YTMAutoClearCache")) {
        // Clear cache on app launch
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self autoClearCache];
        });
    }
    return result;
}

%end