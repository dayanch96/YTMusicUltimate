#import "Imports.h"

%group SettingsPage
%hook YTMAvatarAccountView
%property(nonatomic,strong) YTMUltimateSettingsController *YTMUltimateController;

- (void)setAccountMenuUpperButtons:(id)arg1 lowerButtons:(id)arg2 {

    UIImage *icon;
    if (@available(iOS 13, *)) {
        icon = [UIImage systemImageNamed:@"flame"];
    } else {
        icon = nil;
    }
    
    //Create the YTMusicUltimate button
    YTMAccountButton *button = [[%c(YTMAccountButton) alloc] initWithTitle:@"YTMusicUltimate" identifier:@"ytmult" icon:icon actionBlock:^(BOOL arg4){
        //Push YTMusicUltimate view controller.

        self.YTMUltimateController = [[YTMUltimateSettingsController alloc] init];
        [self._viewControllerForAncestor presentViewController:self.YTMUltimateController animated:YES completion:nil];
    }];

    button.tintColor = [UIColor redColor];

    //Add our custom button to the list.
    NSMutableArray *arrDown = [[NSMutableArray alloc] init];
    [arrDown addObjectsFromArray:arg2];
    [arrDown addObject:button];

    //Remove the subscribe to premium button.
    NSMutableArray *arrUp = [[NSMutableArray alloc] init];
    for (YTMAccountButton *yt_button in arg1) {
        if (![[yt_button.titleLabel text] containsString:@"Premium"]) {
            [arrUp addObject:yt_button];
        }
    }

    //Continue the function with our own parameters.
    %orig(arrUp, arrDown);
}
%end
%end

#pragma mark - Fix sideloading issues
%group SideloadingFixes
//Fix login - thanks poomsmart & julioverne
%hook SSOService
+ (id)fetcherWithRequest:(NSMutableURLRequest *)request configuration:(id)configuration {
    if ([request isKindOfClass:[NSMutableURLRequest class]] && request.HTTPBody) {
        NSError *error = nil;
        NSMutableDictionary *body = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:NSJSONReadingMutableContainers error:&error];
        if (!error && [body isKindOfClass:[NSMutableDictionary class]]) {
            [body removeObjectForKey:@"device_challenge_request"];
            request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error];
        }
    }
    return %orig;
}
%end

%hook SSOKeychain
//Thanks to jawshoeadan for this hook.
+ (id)accessGroup {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status != errSecSuccess)
            return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    
    return accessGroup;
}

+ (id)sharedAccessGroup {
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (__bridge NSString *)kSecClassGenericPassword, (__bridge NSString *)kSecClass,
                           @"bundleSeedID", kSecAttrAccount,
                           @"", kSecAttrService,
                           (id)kCFBooleanTrue, kSecReturnAttributes,
                           nil];
    CFDictionaryRef result = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    if (status == errSecItemNotFound)
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status != errSecSuccess)
            return nil;
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    
    return accessGroup;
}
%end

%hook YTMBackgroundUpsellNotificationController
- (id)upsellNotificationTriggerOnBackground {
    return nil;
}

- (void)appDidEnterBackground:(id)arg1 {
    return;
}

- (void)maybeScheduleBackgroundUpsellNotification {
    %orig;
    [self removePendingBackgroundNotifications];
}
%end
%end

#pragma mark - Enabling cast
%group Cast
%hook MDXFeatureFlags
- (BOOL)isCastCloudDiscoveryEnabled {
    return YES;
}

- (void)setIsCastCloudDiscoveryEnabled:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)isCastToNativeEnabled {
    return YES;
}

- (void)setIsCastToNativeEnabled:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)isCastEnabled {
    return YES;
}

- (void)setIsCastEnabled:(BOOL)enabled {
    %orig(YES);
}
%end

%hook YTColdConfig
- (BOOL)isCastToNativeEnabled {
    return YES;
}

- (void)setIsCastToNativeEnabled:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)isPersistentCastIconEnabled {
    return YES;
}

- (void)setIsPersistentCastIconEnabled:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)musicEnableSuggestedCastDevices {
    return YES;
}

- (void)setMusicEnableSuggestedCastDevices:(BOOL)suggest {
    %orig(YES);
}

- (BOOL)musicClientConfigEnableCastButtonOnPlayerHeader {
    return YES;
}

- (void)setMusicClientConfigEnableCastButtonOnPlayerHeader:(BOOL)enabled {
    %orig(YES);
}

- (BOOL)musicClientConfigEnableAudioOnlyCastingForNonMusicAudio {
    return YES;
}

- (void)setMusicClientConfigEnableAudioOnlyCastingForNonMusicAudio:(BOOL)enabled {
    %orig(YES);
}
%end

%hook YTMCastSessionController
- (id)premiumUpgradeAction {
    return nil;
}

- (void)showAudioCastUpsellDialog {
    return;
}

- (BOOL)isFreeTierAudioCastEnabled {
    return YES;
}

- (void)setIsFreeTierAudioCastEnabled:(BOOL)enabled {
    %orig(YES);
}

- (void)openMusicPremiumLandingPage {
    return;
}
%end

%hook YTMMusicAppMetadata
- (BOOL)isAudioCastEnabled {
    return YES;
}

- (void)setIsAudioCastEnabled:(BOOL)enabled {
    %orig(YES);
}
%end
%end

#pragma mark - Removing premium promos
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
%end

%hook YTPivotBarView
-(YTPivotBarItemView *)itemView4{
    YTPivotBarItemView *view = %orig;
    view.navigationButton.hidden = YES;
    return nil;
}
%end

%hook YTIShowFullscreenInterstitialCommand
-(BOOL)shouldThrottleInterstitial{
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
%end

#pragma mark - Background playback
%group BackgroundPlayback
%hook YTPlaybackData
- (bool)isPlayableInBackground{
    return YES;
}

- (void)setIsPlayableInBackground:(BOOL)backgroundable {
    %orig(YES);
}

- (bool)isPlayable {
 return YES;
}
%end

%hook YTIPlayabilityStatus
- (bool)isPlayable {
 return YES;
}
%end

%hook YTIPlayerResponse
- (bool)isAudioOnlyAvailabilityBlocked {
 return NO;
}

- (bool)isDAIEnabledPlayback {
 return YES;
}
%end

%hook HAMPlayer
- (bool)allowsBackgroundPlayback{
    return YES;
}

- (void)setAllowsBackgroundPlayback:(bool)arg1 {
    %orig(YES);
}
%end
%end

#pragma mark - Removing ads
%group RemoveAds
%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1{
    return;
}
%end
%end

#pragma mark - Video/Audio switching
%group VideoAndAudioModePatches
%hook YTIPlayerResponse
- (BOOL)ytm_isAudioOnlyPlayable{
    return YES;
}

- (void)setYtm_isAudioOnlyPlayable:(BOOL)playable{
    %orig(YES);
}
%end

%hook YTMSettings
- (BOOL)noVideoModeEnabled{
    return NO;
}

- (void)setNoVideoModeEnabled:(BOOL)enabled {
    %orig(NO);
}
%end

%hook YTUserDefaults
- (BOOL)noVideoModeEnabled{
    return NO;
}

- (void)setNoVideoModeEnabled:(BOOL)enabled {
    %orig(NO);
}
%end

%hook YTMAudioVideoModeController
- (BOOL)isAudioOnlyBlocked {
    return NO;
}

- (void)setIsAudioOnlyBlocked:(BOOL)blocked {
    %orig(NO);
}

- (void)setSwitchAvailability:(long long)arg1 {
    %orig(1);
}
%end

%hook YTMQueueConfig
- (BOOL)isAudioVideoModeSupported {
    return YES;
}

- (void)setIsAudioVideoModeSupported:(BOOL)supported {
    %orig(YES);
}
%end

%hook YTDefaultQueueConfig
- (BOOL)isAudioVideoModeSupported {
    return YES;
}

- (void)setIsAudioVideoModeSupported:(BOOL)supported {
    %orig(YES);
}
%end
%end

#pragma mark - OLED Theme
%group oledTheme
%hook YTCommonColorPalette
- (UIColor *)brandBackgroundSolid { return [UIColor blackColor]; }
- (UIColor *)brandBackgroundPrimary { return [UIColor blackColor]; }
%end

%hook YTPivotBarView
- (void)didMoveToWindow {
    self.subviews[0].backgroundColor = [UIColor blackColor];
    %orig;
}
%end

%hook YTMMusicMenuTitleView
- (void)didMoveToWindow {
    self.backgroundColor = [UIColor blackColor];
    %orig;
}
%end

%hook MDCSnackbarMessageView
- (void)didMoveToWindow {
    self.backgroundColor = [UIColor blackColor];
    %orig;
}
%end
%end

#pragma mark - OLED Keyboard
%group oledKB
%hook UIPredictionViewController // support prediction bar - @ichitaso: http://gist.github.com/ichitaso/935100fd53a26f18a9060f7195a1be0e
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UICandidateViewController // support prediction bar - @ichitaso:http://gist.github.com/ichitaso/935100fd53a26f18a9060f7195a1be0e
- (void)loadView {
    %orig;
    [self.view setBackgroundColor:[UIColor blackColor]];
}
%end

%hook UIKBRenderConfig // Prediction text color
- (void)setLightKeyboard:(BOOL)arg1 { %orig(NO); }
%end

%hook UIKeyboardDockView
- (void)didMoveToWindow {
    self.backgroundColor = [UIColor blackColor];
    %orig;
}
%end

%hook UIKeyboardLayoutStar 
- (void)didMoveToWindow {
    self.backgroundColor = [UIColor blackColor];
    %orig;
}
%end
%end

%group RateController
%hook YTMModularNowPlayingViewController
- (BOOL)playbackRateButtonEnabled {
    return YES;
}

- (void)setPlaybackRateButtonEnabled:(BOOL)enabled {
    %orig(YES);
}
%end

%hook YTMPlayerControlsView
- (BOOL)playbackRateButtonEnabled {
    return YES;
}

- (void)setPlaybackRateButtonEnabled:(BOOL)enabled {
    %orig(YES);
}
%end
%end

%ctor{

    //Get / read values
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL oledDarkTheme = ([[NSUserDefaults standardUserDefaults] objectForKey:@"oledDarkTheme_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"oledDarkTheme_enabled"] : NO;
    BOOL oledDarkKeyboard = ([[NSUserDefaults standardUserDefaults] objectForKey:@"oledDarkKeyboard_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"oledDarkKeyboard_enabled"] : NO;
    BOOL playbackRateButton = ([[NSUserDefaults standardUserDefaults] objectForKey:@"playbackRateButton_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"playbackRateButton_enabled"] : NO;

    //Parse values to YTMUltimatePrefs for easy access.
    [[YTMUltimatePrefs sharedInstance] setIsEnabled:isEnabled];
    [[YTMUltimatePrefs sharedInstance] setOledDarkTheme:oledDarkTheme];
    [[YTMUltimatePrefs sharedInstance] setOledDarkKeyboard:oledDarkKeyboard];
    [[YTMUltimatePrefs sharedInstance] setPlaybackRateButton:playbackRateButton];

    //Apply patches
    %init(SideloadingFixes);
    %init(SettingsPage);
    
    if (isEnabled){
        %init(Cast);
        %init(BackgroundPlayback);
        %init(EnsurePremiumStatus);
        %init(RemoveAds);
        %init(VideoAndAudioModePatches);

        if (oledDarkTheme) {
            %init(oledTheme);
        }

        if (oledDarkKeyboard) {
            %init(oledKB);
        }

        if (playbackRateButton) {
            %init(RateController);
        }
    }
}
