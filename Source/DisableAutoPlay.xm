#import <Foundation/Foundation.h>

// To respect users autoplay switch status
%hook YTDefaultQueueConfig
- (bool)autoplayEnabled {
    return 0;
}
%end

%group DisableAutoRadio
%hook YTQueueController
- (bool)isAutoplaySupported {
    return 0;
}
%end

%hook YTMQueueConfig
- (bool)autoplayEnabled {
    return 0;
}
%end

%hook YTMSettings
- (bool)autoplayEnabled {
    return 0;
}
%end

%hook YTUserDefaults
- (bool)autoplayEnabled {
    return 0;
}
%end
%end

%ctor {

    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL disableAutoRadio = ([[NSUserDefaults standardUserDefaults] objectForKey:@"disableAutoRadio_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"disableAutoRadio_enabled"] : NO;

    %init;
    if (isEnabled && disableAutoRadio) {
        %init(DisableAutoRadio);
    }

}