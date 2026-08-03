#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const YTMUDiscordAuthErrorDomain;

typedef NS_ENUM(NSInteger, YTMUDiscordAuthError) {
    YTMUDiscordAuthErrorCancelled = 1,
    YTMUDiscordAuthErrorStateMismatch,
    YTMUDiscordAuthErrorMissingCode,
    YTMUDiscordAuthErrorInvalidGrant,
    YTMUDiscordAuthErrorNetwork,
    YTMUDiscordAuthErrorMissingAppID
};

typedef void (^YTMUDiscordAuthCompletion)(NSString *_Nullable accessToken,
                                          NSString *_Nullable refreshToken,
                                          NSTimeInterval expiresIn,
                                          NSError *_Nullable error);

// Authorization code + PKCE flow against Discord, run in an
// ASWebAuthenticationSession so the custom callback scheme resolves without
// having to register it in the host app's Info.plist.
@interface YTMUDiscordAuth : NSObject

+ (instancetype)sharedInstance;

- (void)authorizeFromViewController:(UIViewController *)viewController
                         completion:(YTMUDiscordAuthCompletion)completion;
- (void)refreshWithToken:(NSString *)refreshToken completion:(YTMUDiscordAuthCompletion)completion;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
