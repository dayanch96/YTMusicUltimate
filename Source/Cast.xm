#import <Foundation/Foundation.h>

@interface MDXFeatureFlags : NSObject
@end

%group Cast
%hook MDXFeatureFlags

- (BOOL)isCastCloudDiscoveryEnabled {
    return YES;
}

- (void)setIsCastCloudDiscoveryEnabled:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)isCastToNativeEnabled {
    return YES;
}

- (void)setIsCastToNativeEnabled:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)isCastEnabled {
    return YES;
}

- (void)setIsCastEnabled:(BOOL)enabled {
    %orig(YES);
}
%end

%hook YTColdConfig
- (BOOL)isCastToNativeEnabled {
    return YES;
}

- (void)setIsCastToNativeEnabled:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)isPersistentCastIconEnabled {
    return YES;
}

- (void)setIsPersistentCastIconEnabled:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)musicEnableSuggestedCastDevices {
    return YES;
}

- (void)setMusicEnableSuggestedCastDevices:(BOOL)suggest {
    %orig(YES);
}

- (BOOL)musicClientConfigEnableCastButtonOnPlayerHeader {
    return YES;
}

- (void)setMusicClientConfigEnableCastButtonOnPlayerHeader:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)musicClientConfigEnableAudioOnlyCastingForNonMusicAudio {
    return YES;
}

- (void)setMusicClientConfigEnableAudioOnlyCastingForNonMusicAudio:(BOOL)enabled {
    %orig(YES);
}
%end

%hook YTMCastSessionController
- (id)premiumUpgradeAction {
    return nil;
}

- (void)showAudioCastUpsellDialog {
    return;
}

- (BOOL)isFreeTierAudioCastEnabled {
    return NO;
}

- (void)setIsFreeTierAudioCastEnabled:(BOOL)enabled {
    %orig(NO);
}

- (void)openMusicPremiumLandingPage {
    return;
}
%end

%hook YTMMusicAppMetadata
- (BOOL)isAudioCastEnabled {
    return YES;
}

- (void)setIsAudioCastEnabled:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)isMATScreenedCastEnabled {
    return YES;
}

- (void)setIsMATScreenedCastEnabled:(BOOL)enabled {
    %orig(YES);
}
%end

%hook YTMSettings
- (BOOL)isAudioCastEnabled {
    return YES;
}

- (BOOL)isGcmEnabled {
    return YES;
}
%end

%hook YTGlobalConfig
- (BOOL)isAudioCastEnabled {
    return YES;
}

- (BOOL)isGcmEnabled {
    return YES;
}
%end

%hook YTMQueueConfig
- (BOOL)isMobileAudioTierScreenedCastEnabled {
    return YES;
}
%end

%hook GHCCDeviceCapabilities
- (BOOL)audioSupported {
    return YES;
}

- (BOOL)hasAudioSupported {
    return YES;
}

- (BOOL)hasVideoSupported {
    return YES;
}

- (BOOL)videoSupported {
    return YES;
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;

    if (isEnabled){
        %init(Cast);
    }
}