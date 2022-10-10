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
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;

    if (isEnabled){
        %init(RemoveAds);
    }
}