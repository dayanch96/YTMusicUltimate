#import <Foundation/Foundation.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static BOOL isDisableAutoRadio = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"disableAutoRadio");

// To respect users autoplay switch status
%hook YTDefaultQueueConfig
- (BOOL)autoplayEnabled {
    return isDisableAutoRadio ? NO : %orig;
}
%end

%hook YTQueueController
- (BOOL)isAutoplaySupported {
    return isDisableAutoRadio ? NO : %orig;
}
%end

%hook YTMQueueConfig
- (BOOL)autoplayEnabled {
    return isDisableAutoRadio ? NO : %orig;
}
%end

%hook YTMQueueConfigImpl
- (BOOL)autoplayEnabled {
    return isDisableAutoRadio ? NO : %orig;
}
%end

%hook YTMSettings
- (BOOL)autoplayEnabled {
    return isDisableAutoRadio ? NO : %orig;
}
%end

%hook YTMSettingsImpl
- (BOOL)autoplayEnabled {
    return isDisableAutoRadio ? NO : %orig;
}
- (void)setAutoplayEnabled:(BOOL)arg { isDisableAutoRadio ? %orig(NO) : %orig; }
%end

%hook YTUserDefaults
- (BOOL)autoplayEnabled {
    return isDisableAutoRadio ? NO : %orig;
}
- (void)setAutoplayEnabled:(BOOL)arg { isDisableAutoRadio ? %orig(NO) : %orig; }
%end

%hook YTMPlaybackQueueAutoplayHeaderReusableView
- (BOOL)isAutoplayEnabled {
    return isDisableAutoRadio ? NO : %orig;
}
- (void)setAutoplayEnabled:(BOOL)arg { isDisableAutoRadio ? %orig(NO) : %orig; }
- (void)setMDXAutoplayEnabled:(BOOL)arg { isDisableAutoRadio ? %orig(NO) : %orig; }
%end

%hook MDXBaseScreen
- (BOOL)isAutoplayEnabled {
    return isDisableAutoRadio ? NO : %orig;
}
%end

%hook MDXSessionImpl
- (BOOL)isAutoplayEnabled {
    return isDisableAutoRadio ? NO : %orig;
}
%end