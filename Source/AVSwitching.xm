#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static int YTMUint(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] integerValue];
}

// Remove popup reminder 
%hook YTMPlayerHeaderViewController
- (bool)shouldDisplayHintForAudioVideoSwitch {
	return YTMU(@"YTMUltimateIsEnabled") ? 0 : %orig;
}
%end

%hook YTIPlayerResponse
- (id)ytm_audioOnlyUpsell {
    return YTMU(@"YTMUltimateIsEnabled") ? nil : %orig;
}

- (BOOL)ytm_isAudioOnlyPlayable {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (BOOL)isAudioOnlyAvailabilityBlocked {
    return YTMU(@"YTMUltimateIsEnabled") ? NO : %orig;
}

- (void)setIsAudioOnlyAvailabilityBlocked:(BOOL)blocked{
    YTMU(@"YTMUltimateIsEnabled") ? %orig(NO) : %orig;
}

- (void)setYtm_isAudioOnlyPlayable:(BOOL)playable{
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}
%end

%hook YTMAudioVideoModeController
- (BOOL)isAudioOnlyBlocked {
    return YTMU(@"YTMUltimateIsEnabled") ? NO : %orig;
}

- (void)setIsAudioOnlyBlocked:(BOOL)blocked {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(NO) : %orig;
}

- (void)setSwitchAvailability:(NSInteger)arg1 {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(1) : %orig;
}
%end

%hook YTMQueueConfig
- (BOOL)isAudioVideoModeSupported {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsAudioVideoModeSupported:(BOOL)supported {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}

/*
- (BOOL)noVideoModeEnabled {
    return YES;
}

- (void)setNoVideoModeEnabled:(BOOL)enabled {
    %orig(YES);
}
*/
%end

%hook YTMAudioVideoModeControllerInternalImpl
- (void)setSwitchAvailability:(NSInteger)arg1 { YTMU(@"YTMUltimateIsEnabled") ? %orig(1) : %orig; }
- (NSInteger)switchAvailability { return YTMU(@"YTMUltimateIsEnabled") ? 1 : %orig; }
- (BOOL)isAudioOnlyBlocked { return YTMU(@"YTMUltimateIsEnabled") ? NO : %orig; }
%end

%hook YTVideoQualitySwitchRedesignedController
- (void)setAllowAudioOnlyManualQualitySelection:(BOOL)arg1 { YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig; }
- (BOOL)allowAudioOnlyManualQualitySelection { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
%end

%hook YTVideoQualitySwitchOriginalController
- (void)setAllowAudioOnlyManualQualitySelection:(BOOL)arg1 { YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig; }
- (BOOL)allowAudioOnlyManualQualitySelection { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
%end

%hook YTDefaultQueueConfig
- (BOOL)isAudioVideoModeSupportedForNonPodcasts {
    return YTMU(@"YTMUltimateIsEnabled") ?: %orig;
}

- (BOOL)isAudioVideoModeSupported {
    return YTMU(@"YTMUltimateIsEnabled") ?: %orig;
}

- (void)setIsAudioVideoModeSupported:(BOOL)supported {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}
%end

%hook YTMSettings
- (BOOL)allowAudioOnlyManualQualitySelection {
    return YTMU(@"YTMUltimateIsEnabled") ?: %orig;
}
%end

%hook YTIAudioOnlyPlayabilityRenderer
- (BOOL)audioOnlyPlayability {
    return YTMU(@"YTMUltimateIsEnabled") ?: %orig;
}

- (int)audioOnlyAvailability {
    return YTMU(@"YTMUltimateIsEnabled") ? 1 : %orig;
}

- (void)setAudioOnlyPlayability:(BOOL)playability {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}

- (id)infoRenderer {
    return YTMU(@"YTMUltimateIsEnabled") ? nil : %orig;
}

- (BOOL)hasInfoRenderer {
    return YTMU(@"YTMUltimateIsEnabled") ? NO : %orig;
}
%end

%hook YTIAudioOnlyPlayabilityRenderer_AudioOnlyPlayabilityInfoSupportedRenderers
- (id)upsellDialogRenderer {
    return YTMU(@"YTMUltimateIsEnabled") ? nil : %orig;
}

- (void)setUpsellDialogRenderer:(id)renderer {
    if (!YTMU(@"YTMUltimateIsEnabled")) return %orig;
}
%end

%hook YTQueueItem
- (BOOL)supportsAudioVideoSwitching {
    return YTMU(@"YTMUltimateIsEnabled") ?: %orig;
}

- (void)setSupportsAudioVideoSwitching:(BOOL)arg1 {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}
%end

%hook YTMMusicAppMetadata
- (BOOL)isAudioOnlyButtonVisible {
    return YTMU(@"YTMUltimateIsEnabled") ?: %orig;
}
%end

%hook YTMQueueConfig
- (bool)noVideoModeEnabledForMusic {
	return YTMUint(@"audioVideoMode") == 0 ? 1 : %orig;
}

- (bool)noVideoModeEnabledForPodcasts {
	return YTMUint(@"audioVideoMode") == 0 ? 1 : %orig;
}
%end

%hook YTQueueController
- (bool)noVideoModeEnabled:(id)arg1 {
	return YTMUint(@"audioVideoMode") == 0 ? 1 : %orig;
}

- (BOOL)isAudioVideoModeSupportedForVideo:(id)video { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
%end

// %group AVSwitchForAds
// %hook YTDefaultQueueConfig
// - (bool)noVideoModeEnabledForMusic {
// 	return 1;
// }

// - (bool)noVideoModeEnabledForPodcasts {
// 	return 1;
// }
// %end

// %hook YTUserDefaults
// - (BOOL)noVideoModeEnabled {
//     return YES;
// }

// - (void)setNoVideoModeEnabled:(BOOL)enabled {
//     %orig(YES);
// }
// %end

// %hook YTIAudioConfig
// - (BOOL)hasPlayAudioOnly {
//     return YES;
// }

// - (BOOL)playAudioOnly {
//     return YES;
// }
// %end

// %hook YTMSettings
// - (BOOL)initialFormatAudioOnly {
//     return YES;
// }

// - (BOOL)noVideoModeEnabled{
//     return YES;
// }

// - (void)setNoVideoModeEnabled:(BOOL)enabled {
//     %orig(YES);
// }
// %end
// %end

%ctor {
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];

    NSArray *intKeys = @[@"audioVideoMode"];
    for (NSString *key in intKeys) {
        if (!YTMUltimateDict[key]) {
            [YTMUltimateDict setObject:@(0) forKey:key];
            [[NSUserDefaults standardUserDefaults] setObject:YTMUltimateDict forKey:@"YTMUltimate"];
        }
    }
}