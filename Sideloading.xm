#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <rootless.h>
#import "Source/Headers/YTAlertView.h"
#import "Source/Headers/Localization.h"

#define YT_BUNDLE_ID @"com.google.ios.youtubemusic"
#define YT_BUNDLE_NAME @"YouTubeMusic"
#define YT_NAME @"YouTube Music"

@interface InitWorkaround : UIViewController
@property (nonatomic, copy) void (^completion)(void);
@end

@interface SFAuthenticationViewController : UIViewController
- (void)remoteViewControllerWillDismiss:(id)remoteVC;
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
    if (status == errSecItemNotFound) {
        status = SecItemAdd((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
        if (status != errSecSuccess) {
            return nil;
        }
    }
    NSString *accessGroup = [(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kSecAttrAccessGroup];
    return accessGroup;
}

// Fix login (2) - Ginsu & AhmedBakfir
// %hook SSOSafariSignIn
// - (void)signInWithURL:(id)arg1 presentationAnchor:(id)arg2 completionHandler:(id)arg3 {
//     NSURL *origURL = arg1;
//     NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:origURL resolvingAgainstBaseURL:NO];
//     NSMutableArray *newQueryItems = [urlComponents.queryItems mutableCopy];
//     for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
//         if ([queryItem.name isEqualToString:@"system_version"]
//             || [queryItem.name isEqualToString:@"app_version"]
//             || [queryItem.name isEqualToString:@"kdlc"]
//             || [queryItem.name isEqualToString:@"kss"]
//             || [queryItem.name isEqualToString:@"lib_ver"]
//             || [queryItem.name isEqualToString:@"device_model"]) {
//             [newQueryItems removeObject:queryItem];
//         }
//     }
//     urlComponents.queryItems = [newQueryItems copy];
//     %orig(urlComponents.URL, arg2, arg3);
// }
// %end

// Force enable safari sign-in
%hook SSOConfiguration
- (BOOL)shouldEnableSafariSignIn { return YES; }
- (BOOL)temporarilyDisableSafariSignIn { return NO; }
- (void)setTemporarilyDisableSafariSignIn:(BOOL)arg1 { return %orig(NO); }
%end

%hook SSOKeychainHelper
- (id)accessGroup { return accessGroupID(); }
- (id)sharedAccessGroup { return accessGroupID(); }
%end

// Thanks to jawshoeadan for this hook.
%hook SSOKeychainCore
- (id)accessGroup { return accessGroupID(); }
- (id)sharedAccessGroup { return accessGroupID(); }
%end

%hook SSOBundleIdServiceImpl
- (id)bundleId { return YT_BUNDLE_ID; }
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
- (id)appName { return YT_NAME; }
- (id)appID { return YT_BUNDLE_ID; }
%end

%hook CHRAppState
- (id)appName { return YT_NAME; }
%end

%hook GCKBUtils
- (id)appIdentifier { return YT_BUNDLE_ID; }
%end

%hook FIRInstallationsIIDTokenStore
- (id)IIDAppIdentifier { return YT_BUNDLE_ID; }
%end

%hook GPCDeviceInfo
- (id)bundleId { return YT_BUNDLE_ID; }
%end

%hook OGLBundle
- (id)shortAppName { return YT_NAME; }
%end

%hook GVROverlayView
- (id)appName { return YT_NAME; }
%end

%hook OGLGM2AccountSelectorViewController 
- (id)shortAppName { return YT_NAME; }
%end

%hook OGLPhenotypeFlagServiceImpl
- (NSString *)bundleId { return YT_BUNDLE_ID; }
%end

%hook APMAEU
- (BOOL)isFAS { return YES; }
%end

%hook ASWApp
- (id)bundleIdentifier { return YT_BUNDLE_ID; }
- (id)exp_productionBundleIdentifier { return YT_BUNDLE_ID; }
%end

%hook GULAppEnvironmentUtil
- (BOOL)isFromAppStore { return YES; }
%end

%hook APMIdentity
- (BOOL)isFromAppStore { return YES; }
%end

%hook SSOConfiguration
- (id)initWithClientID:(id)clientID supportedAccountServices:(id)supportedAccountServices {
    self = %orig;
    [self setValue:YT_NAME forKey:@"_shortAppName"];
    [self setValue:YT_BUNDLE_ID forKey:@"_applicationIdentifier"];
    return self;
}
- (void)setShortAppName:(id)appName { %orig(YT_NAME); }
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
- (id)productionBundleIdentifier { return YT_BUNDLE_ID; }
- (id)lowercaseProductionBundleIdentifier { return YT_BUNDLE_ID; }
%end

%hook EXPApp
- (id)bundleIdentifier { return YT_BUNDLE_ID; }
%end

%hook CHRInfoPlistUtil
- (id)mainAppBundleID { return YT_BUNDLE_ID; }
%end

%hook FIROptions
- (id)bundleID { return YT_BUNDLE_ID; }
%end

%hook FIRApp
- (id)actualBundleID { return YT_BUNDLE_ID; }
%end

%hook GAZAppInfo
- (id)currentBundleIdentifier { return YT_BUNDLE_ID; }
%end

NSDictionary *(*orig_infoDictionary)(id self, SEL _cmd);
NSDictionary *replaceInfoDict(id self, SEL _cmd) {
    NSDictionary *originalInfoDictionary = orig_infoDictionary(self, _cmd);
    NSString *bundleIdentifier = originalInfoDictionary[@"CFBundleIdentifier"];
    if (![bundleIdentifier isEqualToString:YT_BUNDLE_ID]) {
        NSMutableDictionary *newInfoDictionary = [NSMutableDictionary dictionaryWithDictionary:originalInfoDictionary];
        [newInfoDictionary setValue:YT_BUNDLE_ID forKey:@"CFBundleIdentifier"];
        return newInfoDictionary;
    }
    return originalInfoDictionary;
}

BOOL isFirstTime = YES;

@implementation InitWorkaround
- (void)viewDidLoad {
    [super viewDidLoad]
    isFirstTime = NO;
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    activityIndicator.color = [UIColor whiteColor];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MSHookMessageEx(objc_getClass("NSBundle"), @selector(infoDictionary), (IMP)replaceInfoDict, (IMP *)&orig_infoDictionary);
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.completion) {
                self.completion();
            }
        }];
    });
}

@end

%hook SFAuthenticationViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if (isFirstTime) {
        InitWorkaround *workaround = [[InitWorkaround alloc] init];
        workaround.completion = ^{
            [self dismissViewControllerAnimated:YES completion:^{
                if ([self respondsToSelector:@selector(remoteViewControllerWillDismiss:)]) {
                    [self performSelector:@selector(remoteViewControllerWillDismiss:)];
                }
                YTAlertView *alertView = [%c(YTAlertView) infoDialog];
                alertView.title = LOC(@"WARNING");
                alertView.subtitle = LOC(@"RETRY_LOGIN");
                [alertView show];
            }];
        };
        [self presentViewController:workaround animated:YES completion:nil];
    }
}
%end

%hook YTMFirstTimeSignInViewController
- (void)viewDidDisappear:(bool)arg1 {
    %orig;
    YTAlertView *alertView = [%c(YTAlertView) infoDialog];
    alertView.title = LOC(@"WARNING");
    alertView.subtitle = LOC(@"LOGIN_INFO");
    [alertView show];
}
%end
