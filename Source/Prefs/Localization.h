#import <Foundation/Foundation.h>
#import <rootless.h>

static inline NSBundle *YTMusicUltimateBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTMusicUltimate" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS(@"/Library/Application Support/YTMusicUltimate.bundle")];
    });
    return bundle;
}

static inline NSString *LOC(NSString *key) {
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    return [tweakBundle localizedStringForKey:key value:nil table:nil];
}
