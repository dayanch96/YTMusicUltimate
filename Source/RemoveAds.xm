#import <Foundation/Foundation.h>

%group RemoveAds
%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1{
    return;
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;

    if (isEnabled){
        %init(RemoveAds);
    }
}