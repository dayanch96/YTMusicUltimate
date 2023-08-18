#import <Foundation/Foundation.h>

extern NSBundle *YTMusicUltimateBundle();

static inline NSString *LOC(NSString *key) {
    NSBundle *tweakBundle = YTMusicUltimateBundle();
    return [tweakBundle localizedStringForKey:key value:nil table:nil];
}
