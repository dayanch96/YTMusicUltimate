#import <Foundation/Foundation.h>

%group iPadStyle
%hook UIDevice
- (long long)userInterfaceIdiom {
    return YES;
} 
%end
%hook UIStatusBarStyleAttributes
- (long long)idiom {
    return NO;
} 
%end
%hook UIKBTree
- (long long)nativeIdiom {
    return NO;
} 
%end
%hook UIKBRenderer
- (long long)assetIdiom {
    return NO;
} 
%end
%end

%ctor{

    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL iPadStyle = ([[NSUserDefaults standardUserDefaults] objectForKey:@"iPadStyle_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"iPadStyle_enabled"] : NO;
    
    if (isEnabled){
        if (iPadStyle) {
            %init(iPadStyle);
        }
    }
}
