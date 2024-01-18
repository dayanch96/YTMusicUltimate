#import <Foundation/Foundation.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

@interface YTMBackgroundUpsellNotificationController : NSObject
- (void)removePendingBackgroundNotifications;
@end

%hook YTMBackgroundUpsellNotificationController
- (id)upsellNotificationTriggerOnBackground {
    return YTMU(@"YTMUltimateIsEnabled") && YTMU(@"backgroundPlayback") ? nil : %orig;
}

- (void)maybeScheduleBackgroundUpsellNotification {
    %orig;
    if (YTMU(@"YTMUltimateIsEnabled") && YTMU(@"backgroundPlayback")) [self removePendingBackgroundNotifications];
}
%end

%hook YTPlayerStatus
- (id)initWithExternalPlayback:(_Bool)arg1 backgroundPlayback:(_Bool)arg2 inlinePlaybackActive:(_Bool)arg3 cardboardModeActive:(_Bool)arg4 layout:(int)arg5 userAudioOnlyModeActive:(_Bool)arg6 blackoutActive:(_Bool)arg7 clipID:(id)arg8 accountLinkState:(id)arg9 muted:(_Bool)arg10 pictureInPicture:(_Bool)arg11 {
    if (YTMU(@"YTMUltimateIsEnabled") && YTMU(@"backgroundPlayback")) {
        arg1 = YES; arg2 = YES; arg3 = YES; arg6 = YES; arg7 = YES;
    }

    return %orig(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11);
}
%end

%hook YTIPlayabilityStatus
- (BOOL)isPlayableInBackground{
    return YTMU(@"YTMUltimateIsEnabled") && YTMU(@"backgroundPlayback") ? YES : %orig;
}

- (void)setIsPlayableInBackground:(BOOL)backgroundable {
    YTMU(@"YTMUltimateIsEnabled") && YTMU(@"backgroundPlayback") ? %orig(YES) : %orig;
}
%end

%hook YTMMusicAppMetadata
- (BOOL)canPlayBackgroundableContent {
    return YTMU(@"YTMUltimateIsEnabled") && YTMU(@"backgroundPlayback") ? YES : %orig;
}
%end

%ctor {
    NSMutableDictionary *YTMUltimateDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"]];

    NSArray *keys = @[@"YTMUltimateIsEnabled", @"backgroundPlayback", @"noAds", @"premiumWorkaround"];
    for (NSString *key in keys) {
        if (!YTMUltimateDict[key]) {
            [YTMUltimateDict setObject:@(1) forKey:key];
            [[NSUserDefaults standardUserDefaults] setObject:YTMUltimateDict forKey:@"YTMUltimate"];
        }
    }
}