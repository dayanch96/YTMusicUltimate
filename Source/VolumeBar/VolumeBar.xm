#include "GSVolBar.h"

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static BOOL volumeBar = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"volBar");

@interface YTMWatchView: UIView
@property (readonly, nonatomic) BOOL isExpanded;
@property (nonatomic) long long currentLayout;
@property (nonatomic, strong) GSVolBar *volumeBar;
- (void)updateVolBarVisibility;
@end

%hook YTMWatchView
%property (nonatomic, strong) GSVolBar *volumeBar;

- (instancetype)initWithColorScheme:(id)scheme {
    self = %orig;
    if (self && volumeBar) {
        UIView *container = [self valueForKey:@"_centerContentContainerView"];
        self.volumeBar = [[GSVolBar alloc] initWithFrame:CGRectMake(container.frame.size.width / 2 - (container.frame.size.width / 2) / 2, 0, container.frame.size.width / 2, 25)];
        [container addSubview:self.volumeBar];
    }
    return self;
}

- (void)layoutSubviews {
    %orig;
    if (volumeBar) {
        UIView *container = [self valueForKey:@"_centerContentContainerView"];
        self.volumeBar.frame = CGRectMake(self.frame.size.width / 2 - (self.frame.size.width / 2) / 2, container.frame.size.height - 19, self.frame.size.width / 2, 25);
    }
}

- (void)updateColorsAfterLayoutChangeTo:(long long)arg1 {
    %orig(arg1);
    if (volumeBar) [self updateVolBarVisibility];
}

- (void)updateColorsBeforeLayoutChangeTo:(long long)arg1 {
    %orig(arg1);
    if (volumeBar) self.volumeBar.hidden = YES;
}

%new
- (void)updateVolBarVisibility {
    if (volumeBar) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            self.volumeBar.hidden = !(self.isExpanded && self.currentLayout == 2);
        });
    }
}

%end
