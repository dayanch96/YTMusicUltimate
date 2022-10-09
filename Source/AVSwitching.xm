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

%hook YTMSettings
- (BOOL)noVideoModeEnabled{
    return NO;
}

- (void)setNoVideoModeEnabled:(BOOL)enabled {
    %orig(NO);
}
%end

%hook YTUserDefaults
- (BOOL)noVideoModeEnabled{
    return NO;
}

- (void)setNoVideoModeEnabled:(BOOL)enabled {
    %orig(NO);
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
%end

%hook YTDefaultQueueConfig
- (BOOL)isAudioVideoModeSupported {
    return YES;
}

- (void)setIsAudioVideoModeSupported:(BOOL)supported {
    %orig(YES);
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;

    if (isEnabled){
        %init(VideoAndAudioModePatches);
    }
}