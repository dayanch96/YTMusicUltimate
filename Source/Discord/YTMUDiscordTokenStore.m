#import <Security/Security.h>
#import "YTMUDiscordTokenStore.h"
#import "YTMUDiscordDefaults.h"

static NSString *const kKeychainService = @"com.ginsu.ytmusicultimate.discord";
static NSString *const kAccessTokenAccount = @"access_token";
static NSString *const kRefreshTokenAccount = @"refresh_token";
static NSString *const kExpiresAtKey = @"discordTokenExpiresAt";
static NSString *const kDeviceVendorIDKey = @"discordDeviceVendorID";
static NSString *const kClientUUIDKey = @"discordClientUUID";

@implementation YTMUDiscordTokenStore

#pragma mark - Keychain

+ (NSMutableDictionary *)queryForAccount:(NSString *)account {
    return [@{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kKeychainService,
        (__bridge id)kSecAttrAccount: account
    } mutableCopy];
}

+ (nullable NSString *)valueForAccount:(NSString *)account {
    NSMutableDictionary *query = [self queryForAccount:account];
    query[(__bridge id)kSecReturnData] = (__bridge id)kCFBooleanTrue;
    query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;

    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess || result == NULL) return nil;

    NSData *data = (__bridge_transfer NSData *)result;
    if (data.length == 0) return nil;

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (void)setValue:(nullable NSString *)value forAccount:(NSString *)account {
    NSMutableDictionary *query = [self queryForAccount:account];

    if (value.length == 0) {
        SecItemDelete((__bridge CFDictionaryRef)query);
        return;
    }

    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *attributes = @{(__bridge id)kSecValueData: data};

    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributes);
    if (status == errSecItemNotFound) {
        query[(__bridge id)kSecValueData] = data;
        query[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlock;
        SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    }
}

#pragma mark - Tokens

+ (NSString *)accessToken {
    return [self valueForAccount:kAccessTokenAccount];
}

+ (NSString *)refreshToken {
    return [self valueForAccount:kRefreshTokenAccount];
}

+ (NSTimeInterval)expiresAt {
    return [YTMUDiscordPrefString(kExpiresAtKey) doubleValue];
}

+ (void)storeAccessToken:(NSString *)accessToken
            refreshToken:(NSString *)refreshToken
               expiresIn:(NSTimeInterval)expiresIn {
    [self setValue:accessToken forAccount:kAccessTokenAccount];

    if (refreshToken.length > 0) {
        [self setValue:refreshToken forAccount:kRefreshTokenAccount];
    }

    if (expiresIn > 0) {
        NSTimeInterval expiresAt = [[NSDate date] timeIntervalSince1970] + expiresIn;
        YTMUDiscordSetPref(kExpiresAtKey, [NSString stringWithFormat:@"%f", expiresAt]);
    }
}

+ (void)updateAccessToken:(NSString *)accessToken {
    [self setValue:accessToken forAccount:kAccessTokenAccount];
}

+ (void)clear {
    [self setValue:nil forAccount:kAccessTokenAccount];
    [self setValue:nil forAccount:kRefreshTokenAccount];
    YTMUDiscordSetPref(kExpiresAtKey, nil);
    YTMUDiscordSetPref(kDeviceVendorIDKey, nil);
    YTMUDiscordSetPref(kClientUUIDKey, nil);
}

#pragma mark - Client identifiers

+ (NSString *)identifierForKey:(NSString *)key {
    @synchronized (self) {
        NSString *existing = YTMUDiscordPrefString(key);
        if (existing.length > 0) return existing;

        NSString *identifier = [[NSUUID UUID] UUIDString];
        YTMUDiscordSetPref(key, identifier);

        return identifier;
    }
}

+ (NSString *)deviceVendorID {
    return [self identifierForKey:kDeviceVendorIDKey];
}

+ (NSString *)clientUUID {
    return [self identifierForKey:kClientUUIDKey];
}

@end
