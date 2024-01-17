#import <Foundation/Foundation.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

%hook MDXFeatureFlags

- (BOOL)isCastCloudDiscoveryEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsCastCloudDiscoveryEnabled:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}

- (BOOL)isCastToNativeEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsCastToNativeEnabled:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}

- (BOOL)isCastEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsCastEnabled:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}
%end

%hook YTColdConfig
- (BOOL)isCastToNativeEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsCastToNativeEnabled:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}

- (BOOL)isPersistentCastIconEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsPersistentCastIconEnabled:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}

- (BOOL)musicEnableSuggestedCastDevices {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setMusicEnableSuggestedCastDevices:(BOOL)suggest {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}

- (BOOL)musicClientConfigEnableCastButtonOnPlayerHeader {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setMusicClientConfigEnableCastButtonOnPlayerHeader:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}

- (BOOL)musicClientConfigEnableAudioOnlyCastingForNonMusicAudio {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setMusicClientConfigEnableAudioOnlyCastingForNonMusicAudio:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}
%end

%hook YTMCastSessionController
- (id)premiumUpgradeAction {
    return YTMU(@"YTMUltimateIsEnabled") ? nil : %orig;
}

- (void)showAudioCastUpsellDialog {
    if (!YTMU(@"YTMUltimateIsEnabled")) return %orig;
}

- (BOOL)isFreeTierAudioCastEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? NO : %orig;
}

- (void)setIsFreeTierAudioCastEnabled:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(NO) : %orig;
}

- (void)openMusicPremiumLandingPage {
    if (!YTMU(@"YTMUltimateIsEnabled")) return %orig;
}
%end

%hook YTMMusicAppMetadata
- (BOOL)isAudioCastEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsAudioCastEnabled:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}

- (BOOL)isMATScreenedCastEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsMATScreenedCastEnabled:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}
%end

%hook YTMSettings
- (BOOL)isAudioCastEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (BOOL)isGcmEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}
%end

%hook YTGlobalConfig
- (BOOL)isAudioCastEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (BOOL)isGcmEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}
%end

%hook YTMQueueConfig
- (BOOL)isMobileAudioTierScreenedCastEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}
%end

%hook GHCCDeviceCapabilities
- (BOOL)audioSupported {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (BOOL)hasAudioSupported {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (BOOL)hasVideoSupported {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (BOOL)videoSupported {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}
%end
