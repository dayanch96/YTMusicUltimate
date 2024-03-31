#import <Foundation/Foundation.h>
#import <rootless.h>
#import "ABCSwitch.h"

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
