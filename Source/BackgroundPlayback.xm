#import <Foundation/Foundation.h>
#include "Imports.h"

%group BackgroundPlayback
%hook YTMBackgroundUpsellNotificationController
- (id)upsellNotificationTriggerOnBackground {
    return nil;
}

- (void)maybeScheduleBackgroundUpsellNotification {
    %orig;
    [self removePendingBackgroundNotifications];
}
%end

%hook YTColdConfig
- (BOOL)disablePlaybackLockScreenController {
    return NO;
}

- (void)setDisablePlaybackLockScreenController:(BOOL)enabled {
    %orig(NO);
}

- (BOOL)enableIMPBackgroundableAudio {
    return YES;
}

- (void)setEnableIMPBackgroundableAudio:(BOOL)enabled {
    %orig(YES);
}
%end

%hook YTMMusicAppMetadata
- (BOOL)canPlayBackgroundableContent {
    return YES;
}

- (void)setCanPlayBackgroundableContent:(BOOL)playable {
    %orig(YES);
}
%end

%hook HAMPlayer
- (BOOL)allowsBackgroundPlayback {
    return YES;
}

- (void)setAllowsBackgroundPlayback:(BOOL)allow {
    %orig(YES);
}
%end

%hook YTPlayerStatus
- (id)initWithExternalPlayback:(_Bool)arg1 backgroundPlayback:(_Bool)arg2 inlinePlaybackActive:(_Bool)arg3 cardboardModeActive:(_Bool)arg4 layout:(int)arg5 userAudioOnlyModeActive:(_Bool)arg6 blackoutActive:(_Bool)arg7 clipID:(id)arg8 accountLinkState:(id)arg9 muted:(_Bool)arg10 pictureInPicture:(_Bool)arg11 {
    return %orig(YES, YES, YES, YES, arg5, NO, YES, arg8, arg9, arg10, arg11);
}

- (BOOL)backgroundPlayback {
    return YES;
}

- (void)setBackgroundPlayback:(BOOL)backgroundable {
    %orig(YES);
}
%end

%hook YTPlaybackData
- (BOOL)isPlayable {
    return YES;
}

- (BOOL)isPlayableInBackground {
    return YES;
}

- (void)setIsPlayableInBackground:(BOOL)playable {
    %orig(YES);
}
%end

%hook YTPlaybackBackgroundTaskController
- (BOOL)isContentPlayableInBackground {
    return YES;
}

- (void)setIsContentPlayableInBackground:(BOOL)playable {
    %orig(YES);
}
%end

%hook YTLocalPlaybackController
- (void)stopBackgroundPlayback {
    return;
}

- (void)updateForceDisableBackgroundingForVideo:(id)arg1 {
    return;
}

- (void)maybeStopBackgroundPlayback {
    return;
}

- (BOOL)isPlaybackBackgroundable {
    return YES;
}

- (void)setIsPlaybackBackgroundable:(BOOL)playable {
    %orig(YES);
}
%end

%hook YTIPlayabilityStatus
- (BOOL)isPlayable {
    return YES;
}

- (BOOL)isPlayableInBackground{
    return YES;
}

- (void)setIsPlayableInBackground:(BOOL)backgroundable {
    %orig(YES);
}
%end

%hook YTSingleVideo
- (BOOL)isPlayableInBackground{
    return YES;
}

- (void)setIsPlayableInBackground:(BOOL)backgroundable {
    %orig(YES);
}
%end

%hook YTIBackgroundabilityRenderer
- (id)backgroundUpsell {
    return nil;
}

- (BOOL)backgroundable {
    return YES;
}

- (BOOL)hasBackgroundable {
    return YES;
}

- (BOOL)hasBackgroundPlaybackControls {
    return YES;
}
%end

%hook YTIPlayerResponse
- (BOOL)hasBackgroundability {
    return YES;
}

- (BOOL)hasPlayableInBackground {
    return YES;
}

- (BOOL)isDAIEnabledPlayback {
    return YES;
}

- (BOOL)isPlayableInBackground{
    return YES;
}

- (void)setIsPlayableInBackground:(BOOL)backgroundable {
    %orig(YES);
}
%end

%hook YTMIntentHandler
- (BOOL)isBackgroundPlaybackEnabled {
    return YES;
}

- (void)setIsBackgroundPlaybackEnabled:(BOOL)backgroundable {
    %orig(YES);
}
%end

%hook YTMSettings
- (BOOL)backgroundPlaybackModeModified {
    return NO;
}

- (void)setBackgroundPlaybackModeModified:(BOOL)modified {
    %orig(NO);
}

- (void)setBackgroundPlaybackMode:(long long)mode {
    %orig(1);
}

- (long long)backgroundPlaybackMode {
    return 1;
}
%end

%hook YTIMainAppColdConfig
- (BOOL)iosEnableImpBackgroundableAudio {
    return YES;
}

- (BOOL)hasIosEnableImpBackgroundableAudio {
    return YES;
}
%end

%hook YTDataUtils
- (BOOL)isPlayableInBackground {
    return YES;
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;

    if (isEnabled){
        %init(BackgroundPlayback);
    }
}