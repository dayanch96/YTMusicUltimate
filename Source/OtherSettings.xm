#import "Headers/YTPivotBarItemView.h"
#import "Headers/YTIPivotBarRenderer.h"
#import "Headers/YTMWatchViewController.h"
#import "Headers/YTPivotBarViewController.h"
#import "Headers/YTPlayabilityResolutionUserActionUIController.h"

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

// Headers stuff
%hook YTLightweightCollectionController
- (void)setUseStickyHeaders:(BOOL)arg1 {
	YTMU(@"YTMUltimateIsEnabled") && YTMU(@"noStickyHeaders") ? %orig(NO) : %orig;
}
%end

%hook YTMSearchTabViewController
- (bool)shouldUseStickyHeaders {
	return YTMU(@"YTMUltimateIsEnabled") && YTMU(@"noStickyHeaders") ? NO : %orig;
}
%end

%hook YTMTabViewController
- (bool)shouldUseStickyHeaders {
	return YTMU(@"YTMUltimateIsEnabled") && YTMU(@"noStickyHeaders") ? NO : %orig;
}
%end

// Make chip clouds (aka headers) background transparent
%hook YTMChipCloudView
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    YTMU(@"YTMUltimateIsEnabled") && YTMU(@"noStickyHeaders") ? %orig([UIColor clearColor]) : %orig;
}
%end

// Tab bar stuff
%hook YTPivotBarItemView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    %orig;

    if (YTMU(@"YTMUltimateIsEnabled") && YTMU(@"noTabBarLabels")) {
        [self.navigationButton setTitle:@"" forState:UIControlStateNormal];
        [self.navigationButton setSizeWithPaddingAndInsets:NO];
    }
}
%end

// Remove tabs
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];

    NSDictionary *identifiersToRemove = @{
        @"FEmusic_home": @(YTMU(@"hideHomeTab")),
        @"FEmusic_immersive": @(YTMU(@"hideSamplesTab")),
        @"FEmusic_explore": @(YTMU(@"hideExploreTab")),
        @"FEmusic_library_landing": @(YTMU(@"hideLibraryTab"))
    };

    for (NSString *identifier in identifiersToRemove) {
        BOOL shouldRemoveItem = [identifiersToRemove[identifier] boolValue];
        NSUInteger index = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
            return shouldRemoveItem && [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:identifier];
        }];

        if (index != NSNotFound) {
            [items removeObjectAtIndex:index];
        }
    }

    %orig;
}
%end

// Startup bar
BOOL isTabSelected = NO;

%hook YTPivotBarViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;

    if (!isTabSelected) {
        NSArray *pivotIdentifiers = @[@"FEmusic_home", @"FEmusic_immersive", @"FEmusic_explore", @"FEmusic_library_landing", @"BHdownloadsVC"];

        NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
        [self selectItemWithPivotIdentifier:pivotIdentifiers[[YTMUltimateDict[@"startupPage"] integerValue]]];

        isTabSelected = YES;
    }
}
%end

%hook YTPlayabilityResolutionUserActionUIController
- (void)showConfirmAlert {
    YTMU(@"YTMUltimateIsEnabled") && YTMU(@"skipWarning") ? [self confirmAlertDidPressConfirm] : %orig;
}
%end

%hook YTMWatchViewController
- (void)playbackControllerStateDidChange {
    %orig;

    //Reset all miniplayer restrictions
    if ([self respondsToSelector:@selector(resetMiniplayerRestrictions)]) {
        [self resetMiniplayerRestrictions];
    }

    //Disable auto-pause when player minimized to miniplayer
    [self setValue:@(NO) forKey:@"_pauseOnMinimize"];
}
%end