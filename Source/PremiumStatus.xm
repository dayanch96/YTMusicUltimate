#import <Foundation/Foundation.h>

static BOOL YTMU(NSString *key) {
    NSDictionary *YTMUltimateDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"YTMUltimate"];
    return [YTMUltimateDict[key] boolValue];
}

@interface YTIPivotBarItemRenderer : NSObject
@property(copy, nonatomic) NSString *pivotIdentifier;
- (NSString *)pivotIdentifier;
@end

@interface YTIPivotBarSupportedRenderers : NSObject
@property(retain, nonatomic) YTIPivotBarItemRenderer *pivotBarItemRenderer;
- (YTIPivotBarItemRenderer *)pivotBarItemRenderer;
@end

@interface YTIPivotBarRenderer : NSObject
- (NSMutableArray <YTIPivotBarSupportedRenderers *> *)itemsArray;
@end

@interface YTMWatchViewController : NSObject
@end

%hook MDXFeatureFlags
- (BOOL)areMementoPromotionsEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? NO : %orig;
}

- (void)setAreMementoPromotionsEnabled:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(NO) : %orig;
}
%end

%hook YTColdConfig
- (BOOL)isPassiveSignInUniquePremiumValuePropEnabled {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsPassiveSignInUniquePremiumValuePropEnabled:(BOOL)enabled {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}

- (BOOL)musicClientConfigIosEnableMobileAudioTierLockscreenControls {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}
%end

%hook YTIPlayabilityStatus
- (id)backgroundUpsell {
    return YTMU(@"YTMUltimateIsEnabled") ? nil : %orig;
}

- (id)offlineUpsell {
    return YTMU(@"YTMUltimateIsEnabled") ? nil : %orig;
}
%end

%hook YTMAppDelegate
- (void)showUpsellAlertWithTitle:(id)arg1 subtitle:(id)arg2 upgradeButtonTitle:(id)arg3 upsellURLString:(id)arg4 sourceApplication:(id)arg5 {
    if (!YTMU(@"YTMUltimateIsEnabled")) %orig;
}
%end

%hook MDXPromotionManager
- (void)presentMementoPromotionIfTriggerConditionsAreSatisfied {
    if (!YTMU(@"YTMUltimateIsEnabled")) %orig;
}

- (void)presentMementoPromotion:(long long)arg1 {
    if (!YTMU(@"YTMUltimateIsEnabled")) %orig;
}
%end

%hook YTPlayerPromoController
- (void)showBackgroundabilityUpsell {
    if (!YTMU(@"YTMUltimateIsEnabled")) %orig;
}

- (void)showBackgroundOnboardingHint {
    if (!YTMU(@"YTMUltimateIsEnabled")) %orig;
}

- (void)showPipOnboardingHint {
    if (!YTMU(@"YTMUltimateIsEnabled")) %orig;
}
%end

%hook YTMMusicAppMetadata
- (BOOL)isPremiumSubscriber{
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsPremiumSubscriber:(BOOL)premium {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}

- (id)sidePanelPromo{
    return YTMU(@"YTMUltimateIsEnabled") ? nil : %orig;
}

- (id)unlimitedSettingsButton {
    return YTMU(@"YTMUltimateIsEnabled") ? nil : %orig;
}

- (BOOL)isMobileAudioTier {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}
%end

%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];

    NSUInteger index = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
        return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"SPunlimited"];
    }];

    if (index != NSNotFound && YTMU(@"YTMUltimateIsEnabled")) [items removeObjectAtIndex:index];

    %orig;
}
%end

%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial{
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setShouldThrottleInterstitial:(BOOL)throttle {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}
%end

%hook YTMAppResponder
- (void)presentInterstitialPromoForEvent:(id)event{
    if (!YTMU(@"YTMUltimateIsEnabled")) %orig;
}

- (void)presentFullscreenPromoForEvent:(id)event{
    if (!YTMU(@"YTMUltimateIsEnabled")) %orig;
}

- (void)presentInterstitialGridPromoForEvent:(id)event{
    if (!YTMU(@"YTMUltimateIsEnabled")) %orig;
}
%end

%hook YTPromosheetController
- (void)presentPromosheetWithEvent:(id)event{
    if (!YTMU(@"YTMUltimateIsEnabled")) %orig;
}
%end

%hook YTMCarPlayController
- (BOOL)isPremiumSubscriber{
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsPremiumSubscriber:(BOOL)premium {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}
%end

%hook YTMYPCGetOfflineUpsellEndpointCommandHandler
- (BOOL)isPremiumSubscriber{
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (void)setIsPremiumSubscriber:(BOOL)premium {
    YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig;
}
%end

%hook YTMWAWatchAppConfig
- (BOOL)isCurrentUserPremium {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}

- (BOOL)isCurrentUserMobileAudioTier {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}
%end

%hook YTMWatchViewController
- (id)init {
    self = %orig;
    if (self && YTMU(@"YTMUltimateIsEnabled")) {
        [self setValue:[NSNumber numberWithBool:YES] forKey:@"_isMobileAudioTierMode"];
    }
    return self;
}
%end

%hook YTMQueueCollectionViewController
- (BOOL)isMobileAudioTierQueue {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}
%end

%hook YTUserDefaults
- (BOOL)hasOnboarded {
    return YTMU(@"YTMUltimateIsEnabled") ? YES : %orig;
}
%end

%hook YTCommonUtils
+ (BOOL)isInternallyDistributedBuild { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
+ (BOOL)isOfflineToDownloadsEnabled { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
+ (BOOL)isUnitOrFunctionalTesting { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
+ (BOOL)isEarlGreyV2FunctionalTesting { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
+ (BOOL)isUnitTesting { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
+ (BOOL)isFunctionalTesting { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
+ (BOOL)isDistributedBuild { return YTMU(@"YTMUltimateIsEnabled") ? NO : %orig; }
%end

%hook YTMYPCGetOfflineUpsellEndpointCommandHandlerImpl
- (BOOL)isPremiumSubscriber { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
%end

%hook YTMCarPlayControllerImpl
- (BOOL)isPremiumSubscriber { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
- (void)setPremiumSubscriber:(BOOL)arg1 { return YTMU(@"YTMUltimateIsEnabled") ? %orig(YES) : %orig; }
%end

%hook YTMMusicAppMetadataImpl
- (BOOL)isPremiumSubscriber { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
- (BOOL)isMobileAudioTier { return YTMU(@"YTMUltimateIsEnabled") ?: %orig; }
%end

// Unlimited listening - YouAreThere (https://github.com/PoomSmart/YouAreThere)
%hook YTColdConfig
- (BOOL)enableYouthereCommandsOnIos { return YTMU(@"YTMUltimateIsEnabled") ? NO : %orig; }
%end

%hook YTYouThereController
- (BOOL)shouldShowYouTherePrompt { return YTMU(@"YTMUltimateIsEnabled") ? NO : %orig; }
%end