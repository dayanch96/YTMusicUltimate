#import "OtherSettings.h"

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

static NSInteger selectedTab() {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[@"startupPage"] integerValue];
}

static BOOL stickyHeaders = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"noStickyHeaders");
static BOOL noTabBarLabels = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"noTabBarLabels");
static BOOL skipWarning = YTMU(@"YTMUltimateIsEnabled") && YTMU(@"skipWarning");

// Headers stuff
%hook YTLightweightCollectionController
- (void)setUseStickyHeaders:(bool)arg1 {
	stickyHeaders ? %orig(NO) : %orig;
}
%end

%hook YTMSearchTabViewController
- (bool)shouldUseStickyHeaders {
	return stickyHeaders ? NO : %orig;
}
%end

%hook YTMTabViewController
- (bool)shouldUseStickyHeaders {
	return stickyHeaders ? NO : %orig;
}
%end

// Make chip clouds (aka headers) background transparent
%hook YTMChipCloudView
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    stickyHeaders ? %orig([UIColor clearColor]) : %orig;
}
%end

// Tab bar stuff
BOOL hasHomeBar = NO;
CGFloat pivotBarViewHeight;

%hook YTPivotBarView
- (void)layoutSubviews {
    %orig;
    pivotBarViewHeight = self.frame.size.height;
}
%end

%hook YTPivotBarItemView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    %orig;

    if (noTabBarLabels) {
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
    } %orig;
}
%end

// Startup bar
BOOL isTabSelected = NO;

%hook YTPivotBarViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig();

    if (!isTabSelected) {
        NSString *pivotIdentifier;
        switch (selectedTab()) {
            case 0:
                pivotIdentifier = @"FEmusic_home";
                break;
            case 1:
                pivotIdentifier = @"FEmusic_immersive";
                break;
            case 2:
                pivotIdentifier = @"FEmusic_explore";
                break;
            case 3:
                pivotIdentifier = @"FEmusic_library_landing";
                break;
            case 4:
                pivotIdentifier = @"BHdownloadsVC";
                break;
            default:
                return;
        }
        [self selectItemWithPivotIdentifier:pivotIdentifier];
        isTabSelected = YES;
    }
}
%end

%hook YTPlayabilityResolutionUserActionUIController
- (void)showConfirmAlert { skipWarning ? [self confirmAlertDidPressConfirm] : %orig; }
%end
