#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Discord application (client) id used for the OAuth2 flow and for uploading
// external assets. Defaults to Metrolist's application, whose registered
// redirect URI is the one in YTMUDiscordCallbackURL. Override per build with
// `make DISCORD_APP_ID=1234567890`, or per install from the settings page —
// but an application of your own also needs that redirect URI registered on
// it, otherwise Discord rejects the authorize request.
#ifndef YTMU_DISCORD_APP_ID
#define YTMU_DISCORD_APP_ID 1447278780795064401
#endif

#define YTMU_DISCORD_STR_(x) #x
#define YTMU_DISCORD_STR(x) YTMU_DISCORD_STR_(x)

extern NSString *const YTMUDiscordGatewayURL;
extern NSString *const YTMUDiscordAPIBase;
extern NSString *const YTMUDiscordOAuthAuthorizeURL;
extern NSString *const YTMUDiscordOAuthTokenURL;
extern NSString *const YTMUDiscordOAuthScopes;
extern NSString *const YTMUDiscordCallbackScheme;
extern NSString *const YTMUDiscordCallbackURL;
extern NSString *const YTMUDiscordWatchURLPrefix;
extern NSString *const YTMUDiscordSourceURL;

// Posted on the main thread whenever the connection state or the signed in
// user changes, so the settings page can refresh itself.
extern NSString *const YTMUDiscordStateDidChangeNotification;

// Preference keys inside the shared `YTMUltimate` defaults dictionary.
extern NSString *const YTMUDiscordPrefEnabled;
extern NSString *const YTMUDiscordPrefAppID;
extern NSString *const YTMUDiscordPrefActivityType;
extern NSString *const YTMUDiscordPrefNameFromSong;
extern NSString *const YTMUDiscordPrefActivityName;
extern NSString *const YTMUDiscordPrefDetailsTemplate;
extern NSString *const YTMUDiscordPrefStateTemplate;
extern NSString *const YTMUDiscordPrefShowArtwork;
extern NSString *const YTMUDiscordPrefShowTimestamps;
extern NSString *const YTMUDiscordPrefShowListenButton;
extern NSString *const YTMUDiscordPrefShowTweakButton;
extern NSString *const YTMUDiscordPrefClearWhenPaused;

typedef NS_ENUM(NSInteger, YTMUDiscordConnectionState) {
    YTMUDiscordConnectionStateDisconnected = 0,
    YTMUDiscordConnectionStateConnecting,
    YTMUDiscordConnectionStateConnected
};

// Discord activity types, as sent in the `type` field of an activity object.
typedef NS_ENUM(NSInteger, YTMUDiscordActivityType) {
    YTMUDiscordActivityTypePlaying = 0,
    YTMUDiscordActivityTypeStreaming = 1,
    YTMUDiscordActivityTypeListening = 2,
    YTMUDiscordActivityTypeWatching = 3,
    YTMUDiscordActivityTypeCustom = 4,
    YTMUDiscordActivityTypeCompeting = 5
};

BOOL YTMUDiscordPrefBool(NSString *key);
NSInteger YTMUDiscordPrefInteger(NSString *key);
NSString *_Nullable YTMUDiscordPrefString(NSString *key);
void YTMUDiscordSetPref(NSString *key, id _Nullable value);
void YTMUDiscordRegisterDefaults(void);

// YES when the master tweak switch, the rich presence switch and a usable
// application id are all in place.
BOOL YTMUDiscordIsEnabled(void);
NSString *YTMUDiscordApplicationID(void);

// Maps the segmented control index used by the settings page onto the Discord
// activity type that goes on the wire.
YTMUDiscordActivityType YTMUDiscordActivityTypeForIndex(NSInteger index);

// Substitutes {song.name}, {artist.name}, {album.name} and {song.id}.
NSString *YTMUDiscordRenderTemplate(NSString *format,
                                    NSString *_Nullable title,
                                    NSString *_Nullable artist,
                                    NSString *_Nullable album,
                                    NSString *_Nullable videoID);

// Headers Discord's own clients send alongside REST calls. Only needed for the
// external-assets endpoint.
NSString *YTMUDiscordUserAgent(void);
NSString *YTMUDiscordSuperPropertiesBase64(void);
void YTMUDiscordResetSuperProperties(void);

NS_ASSUME_NONNULL_END
