#import <Foundation/Foundation.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static BOOL isDisableAutoRadio = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"disableAutoRadio");

// To respect users autoplay switch status
%hook YTDefaultQueueConfig
- (bool)autoplayEnabled {
    return isDisableAutoRadio ? 0 : %orig;
}
%end

%hook YTQueueController
- (bool)isAutoplaySupported {
    return isDisableAutoRadio ? 0 : %orig;
}
%end

%hook YTMQueueConfig
- (bool)autoplayEnabled {
    return isDisableAutoRadio ? 0 : %orig;
}
%end

%hook YTMSettings
- (bool)autoplayEnabled {
    return isDisableAutoRadio ? 0 : %orig;
}
%end

%hook YTUserDefaults
- (bool)autoplayEnabled {
    return isDisableAutoRadio ? 0 : %orig;
}
%end
