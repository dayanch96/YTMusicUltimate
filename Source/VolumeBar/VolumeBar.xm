#include "GSVolBar.h"

@interface YTMWatchView: UIView
@property (readonly, nonatomic) BOOL isExpanded;
@property (nonatomic) long long currentLayout;
@property (nonatomic, strong) GSVolBar *volumeBar;
- (void)updateVolBarVisibility;
@end

%group VolumeBar
%hook YTMWatchView
%property (nonatomic, strong) GSVolBar *volumeBar;

- (instancetype)initWithColorScheme:(id)scheme {
    self = %orig;
    if (self) {
        UIView *container = [self valueForKey:@"_centerContentContainerView"];
        self.volumeBar = [[GSVolBar alloc] initWithFrame:CGRectMake(container.frame.size.width / 2 - (container.frame.size.width / 2) / 2, 0, container.frame.size.width / 2, 25)];
        [container addSubview:self.volumeBar];
    }
    return self;
}

- (void)layoutSubviews {
    %orig;
    UIView *container = [self valueForKey:@"_centerContentContainerView"];
    self.volumeBar.frame = CGRectMake(self.frame.size.width / 2 - (self.frame.size.width / 2) / 2, container.frame.size.height - 27, self.frame.size.width / 2, 25);
}

- (void)updateColorsAfterLayoutChangeTo:(long long)arg1 {
    %orig(arg1);
    [self updateVolBarVisibility];
}

- (void)updateColorsBeforeLayoutChangeTo:(long long)arg1 {
    %orig(arg1);
    self.volumeBar.hidden = YES;
}

%new
- (void)updateVolBarVisibility {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.volumeBar.hidden = !(self.isExpanded && self.currentLayout == 2);
    });
}

%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL volBar = ([[NSUserDefaults standardUserDefaults] objectForKey:@"VolBar_Enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"VolBar_Enabled"] : NO;
    
    if (isEnabled){
        if (volBar) {
            %init(VolumeBar);
        }
    }
}