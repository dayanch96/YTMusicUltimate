#import "NSBundle+YTMU.h"

@implementation NSBundle (YTMusicUltimate)

+ (NSBundle *)ytmu_defaultBundle {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTMusicUltimate" ofType:@"bundle"];
        NSString *rootlessBundlePath = ROOT_PATH_NS(@"/Library/Application Support/YTMusicUltimate.bundle");

        bundle = [NSBundle bundleWithPath:tweakBundlePath ?: rootlessBundlePath];
    });

    return bundle;
}

@end