#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Keychain backed storage for the Discord OAuth2 tokens. The tokens grant
// presence access to somebody's Discord account, so they never touch
// NSUserDefaults.
@interface YTMUDiscordTokenStore : NSObject

@property (class, nonatomic, copy, readonly, nullable) NSString *accessToken;
@property (class, nonatomic, copy, readonly, nullable) NSString *refreshToken;

// Absolute expiry of the access token, in seconds since 1970. Zero when unknown.
@property (class, nonatomic, readonly) NSTimeInterval expiresAt;

+ (void)storeAccessToken:(NSString *)accessToken
            refreshToken:(nullable NSString *)refreshToken
               expiresIn:(NSTimeInterval)expiresIn;
+ (void)updateAccessToken:(NSString *)accessToken;
+ (void)clear;

// Stable per-install identifiers sent as Discord client super properties.
@property (class, nonatomic, copy, readonly) NSString *deviceVendorID;
@property (class, nonatomic, copy, readonly) NSString *clientUUID;

@end

NS_ASSUME_NONNULL_END
