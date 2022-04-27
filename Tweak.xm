#import "Imports.h"

%group ui

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
        self.YTMUltimateController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        self.YTMUltimateController.modalPresentationStyle = UIModalPresentationFullScreen;
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


%group hack

#pragma mark - Fix sideloading issues (Thanks jawshoeadan)
%hook SSOKeychain
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

#pragma mark - Showing status bar in the player
%hook YTMWatchViewController
-(BOOL)prefersStatusBarHidden{
    if ([[YTMUltimatePrefs sharedInstance] showStatusBarInPlayer]){
        return NO;
    } else {
        return %orig;
    }
}
%end

#pragma mark - Removing premium promos
%hook YTIShowFullscreenInterstitialCommand
-(BOOL)shouldThrottleInterstitial{
    return YES;
}
%end

%hook YTMAppResponder
-(void)presentInterstitialPromoForEvent:(id)event{
    return;
}
%end

%hook YTPromosheetController
-(void)presentPromosheetWithEvent:(id)event{
    return;
}
%end

#pragma mark - Enabling premium features
%hook YTIPlayabilityStatus
-(bool)isPlayableInBackground{
    return YES;
}
%end

%hook YTSingleVideo
-(bool)isPlayableInBackground{
    return YES;
}
%end

%hook YTIPlaybackData
-(bool)isPlayableInBackground{
    return YES;
}
%end

%hook YTIPlayerResponse
-(bool)isPlayableInBackground{
    return YES;
}

-(bool)ytm_isAudioOnlyPlayable{
    return YES;
}

-(id)ytm_audioOnlyPlayabilityRenderer{
    return %orig;
}
%end

%hook YTMSettings

-(_Bool)noVideoModeEnabled{
    return NO;
}
%end

%hook YTUserDefaults
-(_Bool)noVideoModeEnabled{
    return NO;
}
%end

#pragma mark - AV Switch
%hook YTMAudioVideoModeController
- (_Bool)isAudioOnlyBlocked {
    return NO;
}

- (void)setSwitchAvailability:(long long)arg1 {
    %orig(1);
}
%end

%hook YTMQueueConfig
- (_Bool)isAudioVideoModeSupported {
    return YES;
}

- (_Bool)isMobileAudioTierScreenedCastEnabled {
    return YES;
}
%end

%hook YTDefaultQueueConfig
- (_Bool)isAudioVideoModeSupported {
    return YES;
}
%end

%hook YTHotConfig
-(BOOL)isPremiumBrandEnabled{
    return YES;
}
%end

%hook YTOfflineVideo
- (_Bool)isPlayableForStatusWithUpsell:(id *)arg1{
    return YES;
}
- (_Bool)isPlayableForPlayabilityStatusWithUpsell:(id *)arg1{
    return YES;
}
- (_Bool)isPlayableForOfflineActionWithUpsell:(id *)arg1{
    return YES;
}
- (_Bool)isPlayableForManualDeletionCheckWithUpsell:(id *)arg1{
    return YES;
}
- (_Bool)isPlayableOfflineWithUpsell:(id *)arg1{
    return YES;
}
- (_Bool)isPlayableOfflineWithReason:(id *)arg1{
    return YES;
}
%end

%hook YTCarPlayController
-(bool)isPremiumSubscriber{
    return YES;
}
%end

%hook YTMMusicAppMetadata
-(bool)isPremiumSubscriber{
    return YES;
}

-(id)sidePanelPromo{
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

%hook YTMYPCGetOfflineUpsellEndpointCommand
-(bool)isPremiumSubscriber{
    return YES;
}
%end

%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1{
    return;
}
%end

%hook MDXDIALScreen

- (_Bool)castSupported {
    return YES;
}
%end

%hook HookName

%end

%end

%ctor{
    //Get values
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    
    BOOL showStatusBarInPlayer = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateShowStatusBarInPlayer"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateShowStatusBarInPlayer"] : NO;
    
    //Apply
    [[YTMUltimatePrefs sharedInstance] setIsEnabled:isEnabled];
    [[YTMUltimatePrefs sharedInstance] setShowStatusBarInPlayer:showStatusBarInPlayer];
    
    %init(ui);
    
    if ([[YTMUltimatePrefs sharedInstance] isEnabled]){
        %init(hack);
    }
    
}
