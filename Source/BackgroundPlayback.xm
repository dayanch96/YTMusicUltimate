#import <Foundation/Foundation.h>

@interface YTMBackgroundUpsellNotificationController : NSObject
- (void)removePendingBackgroundNotifications;
@end

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

%hook YTPlayerStatus
- (id)initWithExternalPlayback:(_Bool)arg1 backgroundPlayback:(_Bool)arg2 inlinePlaybackActive:(_Bool)arg3 cardboardModeActive:(_Bool)arg4 layout:(int)arg5 userAudioOnlyModeActive:(_Bool)arg6 blackoutActive:(_Bool)arg7 clipID:(id)arg8 accountLinkState:(id)arg9 muted:(_Bool)arg10 pictureInPicture:(_Bool)arg11 {
    return %orig(YES, YES, YES, arg4, arg5, YES, YES, arg8, arg9, arg10, arg11);
}
%end

%hook YTIPlayabilityStatus
- (BOOL)isPlayableInBackground{
    return YES;
}

- (void)setIsPlayableInBackground:(BOOL)backgroundable {
    %orig(YES);
}
%end

%hook YTIPlayerResponse
- (BOOL)isDAIEnabledPlayback {
    return YES;
}
%end

%hook YTMMusicAppMetadata
- (BOOL)canPlayBackgroundableContent {
    return YES;
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL backgroundPlayback = ([[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundPlayback_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"backgroundPlayback_enabled"] : YES;

    // To turn on by default
    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"backgroundPlayback_enabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"backgroundPlayback_enabled"]; 
    }

    if (isEnabled && backgroundPlayback) {
        %init(BackgroundPlayback);
    }
}