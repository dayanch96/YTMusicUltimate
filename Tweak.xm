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
%end

#pragma mark - Removing premium promos
%group EnsurePremiumStatus
%hook YTMMusicAppMetadata
- (BOOL)isPremiumSubscriber{
    return YES;
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

%hook YTCarPlayController
-(BOOL)isPremiumSubscriber{
    return YES;
}
%end

%hook YTHotConfig
-(BOOL)isPremiumBrandEnabled{
    return YES;
}
%end

%hook YTMYPCGetOfflineUpsellEndpointCommand
-(bool)isPremiumSubscriber{
    return YES;
}
%end
%end

#pragma mark - Background playback
%group BackgroundPlayback
%hook YTIPlayabilityStatus
- (BOOL)isPlayableInBackground{
    return YES;
}
%end

%hook YTSingleVideo
- (BOOL)isPlayableInBackground{
    return YES;
}
%end

%hook YTIPlaybackData
- (BOOL)isPlayableInBackground{
    return YES;
}
%end

%hook YTIPlayerResponse
-(bool)isPlayableInBackground{
    return YES;
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
-(BOOL)ytm_isAudioOnlyPlayable{
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
%end

%hook YTDefaultQueueConfig
- (_Bool)isAudioVideoModeSupported {
    return YES;
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

%ctor{

    //Get / read values
    BOOL isEnabled = ([[NSUserDefaults standardUserDefaults] objectForKey:@"YTMUltimateIsEnabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"YTMUltimateIsEnabled"] : YES;
    BOOL oledDarkTheme = ([[NSUserDefaults standardUserDefaults] objectForKey:@"oledDarkTheme_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"oledDarkTheme_enabled"] : NO;
    BOOL oledDarkKeyboard = ([[NSUserDefaults standardUserDefaults] objectForKey:@"oledDarkKeyboard_enabled"] != nil) ? [[NSUserDefaults standardUserDefaults] boolForKey:@"oledDarkKeyboard_enabled"] : NO;
    
    //Parse values to YTMUltimatePrefs for easy access.
    [[YTMUltimatePrefs sharedInstance] setIsEnabled:isEnabled];
    [[YTMUltimatePrefs sharedInstance] setOledDarkTheme:oledDarkTheme];
    [[YTMUltimatePrefs sharedInstance] setOledDarkKeyboard:oledDarkKeyboard];

    //Apply patches
    %init(SideloadingFixes);
    %init(SettingsPage);
    
    if (isEnabled){
        %init(EnsurePremiumStatus);
        %init(BackgroundPlayback);
        %init(RemoveAds);
        %init(VideoAndAudioModePatches);

        if (oledDarkTheme) {
            %init(oledTheme);
        }

        if (oledDarkKeyboard) {
            %init(oledKB);
        }
    }
}
