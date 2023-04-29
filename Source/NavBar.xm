#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static BOOL buttonEnabled(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

@interface QTMButton : UIButton
@property (nonatomic, copy, readwrite) NSString *accessibilityIdentifier;
@end

@interface YTMSortFilterButton : UIButton
@end

%group NavBarItems
%hook QTMButton
- (void)layoutSubviews {
    %orig;
    if (buttonEnabled(@"hideHistoryButton_enabled")) {
        if ([self.accessibilityIdentifier isEqualToString:@"id.navigation.history.button"]) {
            self.hidden = YES;
        }
    }
    if (buttonEnabled(@"hideCastButton_enabled")) {
        if ([self.accessibilityIdentifier isEqualToString:@"id.mdx.playbackroute.button"]) {
            self.hidden = YES;
        }
    }
}
%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;

    if (isEnabled) {
        %init(NavBarItems);
    }
}