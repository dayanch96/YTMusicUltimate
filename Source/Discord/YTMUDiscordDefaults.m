#import <UIKit/UIKit.h>
#import "YTMUDiscordDefaults.h"
#import "YTMUDiscordTokenStore.h"

NSString *const YTMUDiscordGatewayURL = @"wss://gateway.discord.gg/?v=10&encoding=json";
NSString *const YTMUDiscordAPIBase = @"https://discord.com/api";
NSString *const YTMUDiscordOAuthAuthorizeURL = @"https://discord.com/oauth2/authorize";
NSString *const YTMUDiscordOAuthTokenURL = @"https://discord.com/api/v10/oauth2/token";
NSString *const YTMUDiscordOAuthScopes = @"openid sdk.social_layer_presence";
// Matches the redirect registered on the default application below. Changing
// one without the other gets you "invalid oauth2 redirect_uri" from Discord.
NSString *const YTMUDiscordCallbackScheme = @"metrolistdiscord";
NSString *const YTMUDiscordCallbackURL = @"metrolistdiscord://oauth2/callback";
NSString *const YTMUDiscordWatchURLPrefix = @"https://music.youtube.com/watch?v=";
NSString *const YTMUDiscordSourceURL = @"https://github.com/dayanch96/YTMusicUltimate";

NSString *const YTMUDiscordStateDidChangeNotification = @"YTMUDiscordStateDidChangeNotification";

NSString *const YTMUDiscordPrefEnabled = @"discordRPC";
NSString *const YTMUDiscordPrefAppID = @"discordAppID";
NSString *const YTMUDiscordPrefActivityType = @"discordActivityType";
NSString *const YTMUDiscordPrefNameFromSong = @"discordNameFromSong";
NSString *const YTMUDiscordPrefActivityName = @"discordActivityName";
NSString *const YTMUDiscordPrefDetailsTemplate = @"discordDetailsTemplate";
NSString *const YTMUDiscordPrefStateTemplate = @"discordStateTemplate";
NSString *const YTMUDiscordPrefShowArtwork = @"discordShowArtwork";
NSString *const YTMUDiscordPrefShowTimestamps = @"discordShowTimestamps";
NSString *const YTMUDiscordPrefShowListenButton = @"discordShowListenButton";
NSString *const YTMUDiscordPrefShowTweakButton = @"discordShowTweakButton";

// Replaced by the pair above, kept only to carry the old choice across.
static NSString *const kLegacyShowButtonsKey = @"discordShowButtons";
NSString *const YTMUDiscordPrefClearWhenPaused = @"discordClearWhenPaused";

static NSString *const kPrefsDomain = @"YTMUltimate";
static NSString *const kMasterSwitchKey = @"YTMUltimateIsEnabled";

static NSDictionary *YTMUDiscordPrefs(void) {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:kPrefsDomain] ?: @{};
}

BOOL YTMUDiscordPrefBool(NSString *key) {
    return [YTMUDiscordPrefs()[key] boolValue];
}

NSInteger YTMUDiscordPrefInteger(NSString *key) {
    return [YTMUDiscordPrefs()[key] integerValue];
}

NSString *YTMUDiscordPrefString(NSString *key) {
    id value = YTMUDiscordPrefs()[key];
    return [value isKindOfClass:[NSString class]] ? value : nil;
}

void YTMUDiscordSetPref(NSString *key, id value) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:kPrefsDomain]];

    if (value == nil) {
        [prefs removeObjectForKey:key];
    } else {
        [prefs setObject:value forKey:key];
    }

    [defaults setObject:prefs forKey:kPrefsDomain];
}

void YTMUDiscordRegisterDefaults(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:kPrefsDomain]];

    NSDictionary *initialValues = @{
        YTMUDiscordPrefEnabled: @(NO),
        YTMUDiscordPrefActivityType: @(0),
        YTMUDiscordPrefNameFromSong: @(YES),
        YTMUDiscordPrefActivityName: @"YouTube Music",
        YTMUDiscordPrefDetailsTemplate: @"{song.name}",
        YTMUDiscordPrefStateTemplate: @"{artist.name}",
        YTMUDiscordPrefShowArtwork: @(YES),
        YTMUDiscordPrefShowTimestamps: @(YES),
        YTMUDiscordPrefShowListenButton: @(YES),
        YTMUDiscordPrefShowTweakButton: @(NO),
        YTMUDiscordPrefClearWhenPaused: @(NO)
    };

    BOOL changed = NO;
    for (NSString *key in initialValues) {
        if (prefs[key] == nil) {
            prefs[key] = initialValues[key];
            changed = YES;
        }
    }

    // The two button switches replaced a single one. Somebody who had turned
    // that off wanted no buttons, so do not hand them back a new default.
    id legacyShowButtons = prefs[kLegacyShowButtonsKey];
    if (legacyShowButtons != nil) {
        if (![legacyShowButtons boolValue]) {
            prefs[YTMUDiscordPrefShowListenButton] = @(NO);
            prefs[YTMUDiscordPrefShowTweakButton] = @(NO);
        }
        [prefs removeObjectForKey:kLegacyShowButtonsKey];
        changed = YES;
    }

    if (changed) [defaults setObject:prefs forKey:kPrefsDomain];
}

NSString *YTMUDiscordApplicationID(void) {
    NSString *appID = [YTMUDiscordPrefString(YTMUDiscordPrefAppID) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (appID.length > 0) return appID;

    NSString *bakedIn = @(YTMU_DISCORD_STR(YTMU_DISCORD_APP_ID));
    return bakedIn.length > 0 ? bakedIn : @"";
}

BOOL YTMUDiscordIsEnabled(void) {
    return YTMUDiscordPrefBool(kMasterSwitchKey)
        && YTMUDiscordPrefBool(YTMUDiscordPrefEnabled)
        && YTMUDiscordApplicationID().length > 0;
}

YTMUDiscordActivityType YTMUDiscordActivityTypeForIndex(NSInteger index) {
    switch (index) {
        case 1: return YTMUDiscordActivityTypePlaying;
        case 2: return YTMUDiscordActivityTypeWatching;
        case 3: return YTMUDiscordActivityTypeCompeting;
        default: return YTMUDiscordActivityTypeListening;
    }
}

NSString *YTMUDiscordRenderTemplate(NSString *format, NSString *title, NSString *artist, NSString *album, NSString *videoID) {
    NSMutableString *result = [NSMutableString stringWithString:format ?: @""];

    NSDictionary *replacements = @{
        @"{song.name}": title ?: @"",
        @"{artist.name}": artist ?: @"",
        @"{album.name}": album ?: @"",
        @"{song.id}": videoID ?: @""
    };

    for (NSString *placeholder in replacements) {
        [result replaceOccurrencesOfString:placeholder
                                withString:replacements[placeholder]
                                   options:NSLiteralSearch
                                     range:NSMakeRange(0, result.length)];
    }

    return [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

#pragma mark - Client identification

static NSString *const kClientVersion = @"301.0";
static NSInteger const kClientBuildNumber = 301000;
static NSString *const kReleaseChannel = @"appStore";

static NSString *sSuperPropertiesBase64 = nil;
static NSString *sLaunchID = nil;
static NSString *const sSuperPropertiesLock = @"YTMUDiscordSuperPropertiesLock";

NSString *YTMUDiscordUserAgent(void) {
    return [NSString stringWithFormat:@"Discord-iOS/%ld;RNA", (long)kClientBuildNumber];
}

NSString *YTMUDiscordSuperPropertiesBase64(void) {
    @synchronized (sSuperPropertiesLock) {
        if (sSuperPropertiesBase64) return sSuperPropertiesBase64;

        if (!sLaunchID) sLaunchID = [[NSUUID UUID] UUIDString];

        NSDictionary *properties = @{
            @"os": @"iOS",
            @"browser": @"Discord iOS",
            @"device": [[UIDevice currentDevice] model] ?: @"iPhone",
            @"system_locale": [[NSLocale currentLocale] localeIdentifier] ?: @"en-US",
            @"client_version": kClientVersion,
            @"release_channel": kReleaseChannel,
            @"device_vendor_id": [YTMUDiscordTokenStore deviceVendorID],
            @"client_uuid": [YTMUDiscordTokenStore clientUUID],
            @"client_launch_id": sLaunchID,
            @"os_version": [[UIDevice currentDevice] systemVersion] ?: @"",
            @"client_build_number": @(kClientBuildNumber),
            @"client_event_source": [NSNull null],
            @"design_id": @(0)
        };

        NSData *json = [NSJSONSerialization dataWithJSONObject:properties options:0 error:nil];
        sSuperPropertiesBase64 = [json base64EncodedStringWithOptions:0] ?: @"";

        return sSuperPropertiesBase64;
    }
}

void YTMUDiscordResetSuperProperties(void) {
    @synchronized (sSuperPropertiesLock) {
        sSuperPropertiesBase64 = nil;
        sLaunchID = nil;
    }
}
