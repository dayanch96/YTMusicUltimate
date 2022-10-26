#import <Foundation/Foundation.h>

%group VideoAndAudioModePatches
%hook YTIPlayerResponse
- (id)ytm_audioOnlyPlayabilityRenderer {
    return nil;
}

- (id)ytm_audioOnlyUpsell {
    return nil;
}

- (BOOL)ytm_isAudioOnlyPlayable {
    return YES;
}

- (BOOL)isAudioOnlyAvailabilityBlocked {
    return NO;
}

- (void)setIsAudioOnlyAvailabilityBlocked:(BOOL)blocked{
    %orig(NO);
}

- (void)setYtm_isAudioOnlyPlayable:(BOOL)playable{
    %orig(YES);
}
%end

%hook YTMAudioVideoModeController
- (BOOL)isAudioOnlyBlocked {
    return NO;
}

- (void)setIsAudioOnlyBlocked:(BOOL)blocked {
    %orig(NO);
}

- (void)setSwitchAvailability:(long long)arg1 {
    %orig(1);
}
%end

%hook YTMQueueConfig
- (BOOL)isAudioVideoModeSupported {
    return YES;
}

- (void)setIsAudioVideoModeSupported:(BOOL)supported {
    %orig(YES);
}

- (BOOL)noVideoModeEnabled {
    return YES;
}
%end

%hook YTDefaultQueueConfig
- (BOOL)isAudioVideoModeSupported {
    return YES;
}

- (void)setIsAudioVideoModeSupported:(BOOL)supported {
    %orig(YES);
}
%end

%hook YTMSettings
- (BOOL)allowAudioOnlyManualQualitySelection {
    return YES;
}

- (BOOL)initialFormatAudioOnly {
    return YES;
}

- (BOOL)noVideoModeEnabled{
    return YES;
}

- (void)setNoVideoModeEnabled:(BOOL)enabled {
    %orig(YES);
}
%end

%hook YTIAudioConfig
- (BOOL)hasPlayAudioOnly {
    return YES;
}

- (BOOL)playAudioOnly {
    return YES;
}
%end

%hook YTIAudioOnlyPlayabilityRenderer
- (BOOL)audioOnlyPlayability {
    return YES;
}
%end

%hook YTIAudioOnlyPlayabilityRenderer_AudioOnlyPlayabilityInfoSupportedRenderers
- (id)upsellDialogRenderer {
    return nil;
}
%end

%hook YTUserDefaults
- (BOOL)noVideoModeEnabled {
    return YES;
}

- (void)setNoVideoModeEnabled:(BOOL)enabled {
    %orig(YES);
}
%end

%hook YTQueueItem
- (BOOL)supportsAudioVideoSwitching {
    return YES;
}
%end

%hook YTIMusicHotConfig
- (BOOL)enableAudioVideoSwitching {
    return YES;
}

- (BOOL)hasEnableAudioVideoSwitching {
    return YES;
}
%end

%hook YTVideoQualitySwitchRedesignedController
- (BOOL)isQualitySwitchEnabled {
    return YES;
}

- (BOOL)isQualitySwitchAvailable {
    return YES;
}

- (BOOL)allowAudioOnlyManualQualitySelection {
    return YES;
}
%end

%hook YTVideoQualitySwitchOriginalController
- (BOOL)isQualitySwitchEnabled {
    return YES;
}

- (BOOL)isQualitySwitchAvailable {
    return YES;
}

- (BOOL)allowAudioOnlyManualQualitySelection {
    return YES;
}
%end

%hook YTPlayerViewControllerConfig
- (BOOL)allowAudioOnlyManualQualitySelection {
    return YES;
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;

    if (isEnabled){
        %init(VideoAndAudioModePatches);
    }
}