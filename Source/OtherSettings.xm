#import "OtherSettings.h"

static BOOL removeTab(NSString *key) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

static NSInteger selectedTab() {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"startupPage"];
}

// Headers stuff
%group DontStickHeaders
%hook YTLightweightCollectionController
- (void)setUseStickyHeaders:(bool)arg1 {
	arg1 = NO;
	%orig;
}
%end

%hook YTMSearchTabViewController
- (bool)shouldUseStickyHeaders {
	return NO;
}
%end

%hook YTMTabViewController
- (bool)shouldUseStickyHeaders {
	return NO;
}
%end

// Make chip clouds (aka headers) background transparent
%hook YTMChipCloudView
- (void)setBackgroundColor:(UIColor *)backgroundColor {
    UIColor *newBackgroundColor = [backgroundColor colorWithAlphaComponent:0.0];
    %orig(newBackgroundColor);
}
%end
%end

// Tab bar stuff
BOOL hasHomeBar = NO;
CGFloat pivotBarViewHeight;

%group RemoveTabBarLabels
%hook YTPivotBarView
- (void)layoutSubviews {
    %orig;
    pivotBarViewHeight = self.frame.size.height;
}
%end

%hook YTPivotBarItemView
- (void)layoutSubviews {
    %orig;

    CGFloat pivotBarAccessibilityControlWidth;

    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"YTPivotBarItemViewAccessibilityControl")]) {
            pivotBarAccessibilityControlWidth = CGRectGetWidth(subview.frame);
            break;
        }
    }

    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"YTQTMButton")]) {
            for (UIView *buttonSubview in subview.subviews) {
                if ([buttonSubview isKindOfClass:[UILabel class]]) {
                    [buttonSubview removeFromSuperview];
                    break;
                }
            }

            UIImageView *imageView = nil;
            for (UIView *buttonSubview in subview.subviews) {
                if ([buttonSubview isKindOfClass:[UIImageView class]]) {
                    imageView = (UIImageView *)buttonSubview;
                    break;
                }
            }

            if (imageView) {
                CGFloat imageViewHeight = imageView.image.size.height;
                CGFloat imageViewWidth = imageView.image.size.width;
                CGRect buttonFrame = subview.frame;

                if (@available(iOS 13.0, *)) {
                    UIWindowScene *mainWindowScene = (UIWindowScene *)[[[UIApplication sharedApplication] connectedScenes] anyObject];
                    if (mainWindowScene) {
                        UIEdgeInsets safeAreaInsets = mainWindowScene.windows.firstObject.safeAreaInsets;
                        if (safeAreaInsets.bottom > 0) {
                            hasHomeBar = YES;
                        }
                    }
                }

                CGFloat yOffset = hasHomeBar ? 15.0 : 0.0;
                CGFloat xOffset = (pivotBarAccessibilityControlWidth - imageViewWidth) / 2.0;

                buttonFrame.origin.y = (pivotBarViewHeight - imageViewHeight - yOffset) / 2.0;
                buttonFrame.origin.x = xOffset;

                buttonFrame.size.height = imageViewHeight;
                buttonFrame.size.width = imageViewWidth;

                subview.frame = buttonFrame;
                subview.bounds = CGRectMake(0, 0, imageViewWidth, imageViewHeight);
            }
        }
    }
}
%end
%end

// Remove tabs
%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];

    NSDictionary *identifiersToRemove = @{
        @"FEmusic_home": @(removeTab(@"hideHomeTab")),
        @"FEmusic_immersive": @(removeTab(@"hideSamplesTab")),
        @"FEmusic_explore": @(removeTab(@"hideExploreTab")),
        @"FEmusic_library_landing": @(removeTab(@"hideLibraryTab"))
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
            default:
                return;
        }
        [self selectItemWithPivotIdentifier:pivotIdentifier];
        isTabSelected = YES;
    }
}
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL noStickyHeaders = [[NSUserDefaults standardUserDefaults] boolForKey:@"noStickyHeaders_enabled"];
    BOOL noTabBarLabels = [[NSUserDefaults standardUserDefaults] boolForKey:@"noTabBarLabels_enabled"];

    if (isEnabled) {
        %init;
        if (noStickyHeaders) {
            %init(DontStickHeaders);
        }
        if (noTabBarLabels) {
            %init(RemoveTabBarLabels)
        }
    }
}