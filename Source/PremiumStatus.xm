#import <Foundation/Foundation.h>

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

%group EnsurePremiumStatus
%hook MDXFeatureFlags
- (BOOL)areMementoPromotionsEnabled {
    return NO;
}

- (void)setAreMementoPromotionsEnabled:(BOOL)enabled {
    %orig(NO);
}
%end

%hook YTColdConfig
- (BOOL)isPassiveSignInUniquePremiumValuePropEnabled {
    return YES;
}

- (void)setIsPassiveSignInUniquePremiumValuePropEnabled:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)musicClientConfigIosEnableMobileAudioTierLockscreenControls {
    return YES;
}
%end

%hook YTIPlayabilityStatus
- (id)backgroundUpsell {
    return nil;
}

- (id)offlineUpsell {
    return nil;
}
%end

%hook YTMAppDelegate
- (void)showUpsellAlertWithTitle:(id)arg1 subtitle:(id)arg2 upgradeButtonTitle:(id)arg3 upsellURLString:(id)arg4 sourceApplication:(id)arg5 {
    return;
}
%end

%hook MDXPromotionManager
- (void)presentMementoPromotionIfTriggerConditionsAreSatisfied {
    return;
}

- (void)presentMementoPromotion:(long long)arg1 {
    return;
}
%end

%hook YTPlayerPromoController
- (void)showBackgroundabilityUpsell {
    return;
}

- (void)showBackgroundOnboardingHint {
    return;
}

- (void)showPipOnboardingHint {
    return;
}
%end

%hook YTMMusicAppMetadata
- (BOOL)isPremiumSubscriber{
    return YES;
}

- (void)setIsPremiumSubscriber:(BOOL)premium {
    %orig(YES);
}

- (id)sidePanelPromo{
    return nil;
}

- (id)unlimitedSettingsButton {
    return nil;
}

- (BOOL)isMobileAudioTier {
    return YES;
}
%end

%hook YTPivotBarView
- (void)setRenderer:(YTIPivotBarRenderer *)renderer {
    NSMutableArray <YTIPivotBarSupportedRenderers *> *items = [renderer itemsArray];

    NSUInteger index = [items indexOfObjectPassingTest:^BOOL(YTIPivotBarSupportedRenderers *renderers, NSUInteger idx, BOOL *stop) {
        return [[[renderers pivotBarItemRenderer] pivotIdentifier] isEqualToString:@"SPunlimited"];
    }];
    if (index != NSNotFound) [items removeObjectAtIndex:index];
    %orig;
}
%end

%hook YTIShowFullscreenInterstitialCommand
- (BOOL)shouldThrottleInterstitial{
    return YES;
}

- (void)setShouldThrottleInterstitial:(BOOL)throttle {
    %orig(YES);
}
%end

%hook YTMAppResponder
- (void)presentInterstitialPromoForEvent:(id)event{
    return;
}

- (void)presentFullscreenPromoForEvent:(id)event{
    return;
}

- (void)presentInterstitialGridPromoForEvent:(id)event{
    return;
}
%end

%hook YTPromosheetController
- (void)presentPromosheetWithEvent:(id)event{
    return;
}
%end

%hook YTMCarPlayController
- (BOOL)isPremiumSubscriber{
    return YES;
}

- (void)setIsPremiumSubscriber:(BOOL)premium {
    %orig(YES);
}
%end

%hook YTMYPCGetOfflineUpsellEndpointCommandHandler
- (BOOL)isPremiumSubscriber{
    return YES;
}

- (void)setIsPremiumSubscriber:(BOOL)premium {
    %orig(YES);
}
%end

%hook YTMWAWatchAppConfig
- (BOOL)isCurrentUserPremium {
    return YES;
}

- (BOOL)isCurrentUserMobileAudioTier {
    return YES;
}
%end

%hook YTMWatchViewController
- (id)init {
    self = %orig;
    if (self) {
        [self setValue:[NSNumber numberWithBool:YES] forKey:@"_isMobileAudioTierMode"];
    }
    return self;
}
%end

%hook YTMQueueCollectionViewController
- (BOOL)isMobileAudioTierQueue {
    return YES;
}
%end

%hook YTUserDefaults

- (BOOL)hasOnboarded {
    return YES;
}

%end
%end

%ctor {
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;

    if (isEnabled){
        %init(EnsurePremiumStatus);
    }
}
