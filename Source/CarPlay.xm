#import <Foundation/Foundation.h>

%group CarPlay
%hook YTIMusicColdConfig
- (BOOL)iosEnableCarplayLastplayedUpdates {
    return YES;
}

- (BOOL)hasIosEnableCarplayLastplayedUpdates {
    return YES;
}
%end

%hook YTIMusicIntegrationsColdConfig
- (BOOL)hasMusicIosCarplayEnableSdkLogic {
    return YES;
}

- (BOOL)musicIosCarplayEnableSdkLogic {
    return YES;
}
%end

%hook YTINotificationRegistration_APNSRegistration_EnabledSettings
- (BOOL)hasCarPlay {
    return YES;
}
%end

%hook YTMModularWatchViewController
- (BOOL)isCarPlayActive {
    return YES;
}
%end

%hook YTNowPlayingInfoCenterPlaybackObserver
- (BOOL)isCarPlayActive {
    return YES;
}
%end

%hook CHMApplePermissions
- (int)carPlaySetting {
    return 1;
}

- (BOOL)hasCarPlaySetting {
    return YES;
}

- (int)authorizationStatus {
    return 1;
}

- (BOOL)hasAuthorizationStatus {
    return YES;
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;

    if (isEnabled){
        %init(CarPlay);
    }
}