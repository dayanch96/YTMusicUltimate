#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <rootless.h>

#define YT_BUNDLE_ID @"com.google.ios.youtubemusic"
#define YT_BUNDLE_NAME @"YouTubeMusic"
#define YT_NAME @"YouTube Music"
#define YTMULoginAlert @"YTMULoginAlert"
#define LOC(x) [tweakBundle localizedStringForKey:x value:nil table:nil]

NSBundle *YTMusicUltimateBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YTMusicUltimate" ofType:@"bundle"];
        if (tweakBundlePath)
            bundle = [NSBundle bundleWithPath:tweakBundlePath];
        else
            bundle = [NSBundle bundleWithPath:ROOT_PATH_NS("/Library/Application Support/YTMusicUltimate.bundle")];
    });
    return bundle;
}

@interface YTAlertView : UIView
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *subtitle;
+ (instancetype)infoDialog;
- (void)show;
@end

@interface SSOConfiguration : NSObject
@end

static NSString *accessGroupID() {
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

%group SideloadingFixes
//Fix login (2) - Ginsu & AhmedBakfir
%hook SSOSafariSignIn
- (void)signInWithURL:(id)arg1 presentationAnchor:(id)arg2 completionHandler:(id)arg3 {
    NSURL *origURL = arg1;

    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:origURL resolvingAgainstBaseURL:NO];
    NSMutableArray *newQueryItems = [urlComponents.queryItems mutableCopy];
    for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
        if ([queryItem.name isEqualToString:@"system_version"]
            || [queryItem.name isEqualToString:@"app_version"]
            || [queryItem.name isEqualToString:@"kdlc"]
            || [queryItem.name isEqualToString:@"kss"]
            || [queryItem.name isEqualToString:@"lib_ver"]
            || [queryItem.name isEqualToString:@"device_model"]) {
            [newQueryItems removeObject:queryItem];
        }
    }
    urlComponents.queryItems = [newQueryItems copy];
    %orig(urlComponents.URL, arg2, arg3);
}
%end

//Force enable safari sign-in
%hook SSOConfiguration
- (BOOL)shouldEnableSafariSignIn {
    return YES;
}
%end

%hook SSOKeychainHelper
+ (id)accessGroup {
    return accessGroupID();
}

+ (id)sharedAccessGroup {
    return accessGroupID();
}
%end

%hook SSOKeychainCore
//Thanks to jawshoeadan for this hook.
+ (id)accessGroup {
    return accessGroupID();
}

+ (id)sharedAccessGroup {
    return accessGroupID();
}
%end

%hook NSFileManager
- (NSURL *)containerURLForSecurityApplicationGroupIdentifier:(NSString *)groupIdentifier {
    if (groupIdentifier != nil) {
        NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
        NSURL *documentsURL = [paths lastObject];
        return [documentsURL URLByAppendingPathComponent:@"AppGroup"];
    }
    return %orig(groupIdentifier);
}
%end

#pragma mark - Thanks PoomSmart for the following hooks
/* IAmYouTube + Extra hooks for ytmusic */
%hook YTVersionUtils
+ (NSString *)appName {
    return YT_NAME;
}

+ (NSString *)appID {
    return YT_BUNDLE_ID;
}
%end

%hook GCKBUtils
+ (NSString *)appIdentifier {
    return YT_BUNDLE_ID;
}
%end

%hook GPCDeviceInfo
+ (NSString *)bundleId {
    return YT_BUNDLE_ID;
}
%end

%hook OGLBundle
+ (NSString *)shortAppName {
    return YT_NAME;
}
%end

%hook GVROverlayView
+ (NSString *)appName {
    return YT_NAME;
}
%end

%hook OGLPhenotypeFlagServiceImpl
- (NSString *)bundleId {
    return YT_BUNDLE_ID;
}
%end

%hook APMAEU
+ (BOOL)isFAS {
    return YES;
}
%end

%hook GULAppEnvironmentUtil
+ (BOOL)isFromAppStore {
    return YES;
}
%end

%hook SSOConfiguration
- (id)initWithClientID:(id)clientID supportedAccountServices:(id)supportedAccountServices {
    self = %orig;
    [self setValue:YT_NAME forKey:@"_shortAppName"];
    [self setValue:YT_BUNDLE_ID forKey:@"_applicationIdentifier"];
    return self;
}
%end

%hook NSBundle
- (NSString *)bundleIdentifier {
    NSArray *address = [NSThread callStackReturnAddresses];
    Dl_info info = {0};
    if (dladdr((void *)[address[2] longLongValue], &info) == 0)
        return %orig;
    NSString *path = [NSString stringWithUTF8String:info.dli_fname];
    if ([path hasPrefix:NSBundle.mainBundle.bundlePath])
        return YT_BUNDLE_ID;
    return %orig;
}

- (id)objectForInfoDictionaryKey:(NSString *)key {
    if ([key isEqualToString:@"CFBundleIdentifier"])
        return YT_BUNDLE_ID;
    if ([key isEqualToString:@"CFBundleDisplayName"])
        return YT_NAME;
    if ([key isEqualToString:@"CFBundleName"])
        return YT_BUNDLE_NAME;
    return %orig;
}
%end
/*IAmYouTube end */

%hook ASWUtilities
+ (NSString *)productionBundleIdentifier {
    return YT_BUNDLE_ID;
}

+ (NSString *)lowercaseProductionBundleIdentifier {
    return YT_BUNDLE_ID;
}
%end

%hook GAZAppInfo
- (NSString *)currentBundleIdentifier {
    return YT_BUNDLE_ID;
}
%end
%end

%group gWhyNot
%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSDictionary *originalInfoDictionary = %orig;

    NSString *bundleIdentifier = originalInfoDictionary[@"CFBundleIdentifier"];
    if (![bundleIdentifier isEqualToString:YT_BUNDLE_ID]) {
        if ([bundleIdentifier hasPrefix:@"com.google.ios.youtube."] || ![bundleIdentifier hasPrefix:@"com.google"]) {
            NSMutableDictionary *newInfoDictionary = [NSMutableDictionary dictionaryWithDictionary:originalInfoDictionary];
            [newInfoDictionary setValue:YT_BUNDLE_ID forKey:@"CFBundleIdentifier"];
            return newInfoDictionary;
        }
    } return originalInfoDictionary;
}
%end
%end

%hook SSOSafariSignIn
+ (void)initialize {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        %init(gWhyNot);
    });
}
%end

%hook YTMFirstTimeSignInViewController
- (void)viewDidDisappear:(bool)arg1 {
    %orig;

    NSBundle *tweakBundle = YTMusicUltimateBundle();
    YTAlertView *alertView = [%c(YTAlertView) infoDialog];
    alertView.title = LOC(@"WARNING");
    alertView.subtitle = LOC(@"LOGIN_INFO");
    [alertView show];
}
%end

%ctor {
    %init;
    %init(SideloadingFixes);
}