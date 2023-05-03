#import <Foundation/Foundation.h>

%group RemoveAds
%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1{
    return;
}
%end

%hook YTDataUtils
+ (id)spamSignalsDictionary {
    return NULL;
}
%end

%hook YTIPlayerResponse
- (BOOL)isMonetized {
    return false;
}

- (id)paidContentOverlayElementRendererOptions {
    return nil;
}

- (BOOL)isCuepointAdsEnabled {
    return NO;
}

- (id)adIntroRenderer {
    return nil;
}

- (BOOL)isDAIEnabledPlayback {
    return YES;
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL noAds = ([[NSUserDefaults standardUserDefaults] objectForKey:@"noAds_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"noAds_enabled"] : YES;

    // To turn on by default    
    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"noAds_enabled"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"noAds_enabled"]; 
    }

    if (isEnabled && noAds) {
        %init(RemoveAds);
    }
}