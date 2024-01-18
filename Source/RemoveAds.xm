#import <Foundation/Foundation.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static BOOL removeAds = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"noAds");

%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1{
    if (!removeAds) return %orig;
}
%end

%hook YTDataUtils
+ (id)spamSignalsDictionary {
    return removeAds ? NULL : %orig;
}
%end

%hook YTIPlayerResponse
- (BOOL)isMonetized {
    return removeAds ? false : %orig;
}

- (id)paidContentOverlayElementRendererOptions {
    return removeAds ? nil : %orig;
}

- (BOOL)isCuepointAdsEnabled {
    return removeAds ? NO : %orig;
}

- (id)adIntroRenderer {
    return removeAds ? nil : %orig;
}

- (BOOL)isDAIEnabledPlayback {
    return removeAds ? YES : %orig;
}
%end
