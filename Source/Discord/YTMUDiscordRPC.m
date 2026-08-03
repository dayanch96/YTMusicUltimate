#import "YTMUDiscordRPC.h"
#import "YTMUDiscordAuth.h"
#import "YTMUDiscordExternalAssets.h"
#import "YTMUDiscordGateway.h"
#import "YTMUDiscordPresence.h"
#import "YTMUDiscordTokenStore.h"

// Refresh the access token when it has less than an hour left on it.
static NSTimeInterval const kTokenRefreshWindow = 3600.0;
// Start timestamps wobble by a fraction of a second between lock screen
// refreshes; anything past this is a real seek and worth republishing.
static long long const kSeekToleranceMs = 3000;
// How long to leave a failing cover art URL alone before trying it again.
static NSTimeInterval const kArtworkRetryDelay = 30.0;

static NSString *YTMUDiscordTemplateOrDefault(NSString *key, NSString *fallback) {
    NSString *value = YTMUDiscordPrefString(key);
    return value.length > 0 ? value : fallback;
}

@implementation YTMUDiscordTrack

- (id)copyWithZone:(NSZone *)zone {
    YTMUDiscordTrack *copy = [[[self class] allocWithZone:zone] init];
    copy.videoID = self.videoID;
    copy.title = self.title;
    copy.artist = self.artist;
    copy.album = self.album;
    copy.artworkURL = self.artworkURL;
    copy.duration = self.duration;
    copy.elapsed = self.elapsed;
    copy.playing = self.playing;

    return copy;
}

- (BOOL)isUsable {
    return self.title.length > 0;
}

@end

@interface YTMUDiscordRPC () <YTMUDiscordGatewayDelegate>

@property (nonatomic, strong) YTMUDiscordGateway *gateway;
@property (nonatomic, strong) dispatch_queue_t queue;

@property (atomic, copy, nullable) NSString *accessToken;
@property (nonatomic, assign) YTMUDiscordConnectionState connectionState;
@property (nonatomic, copy, nullable) NSString *username;
@property (nonatomic, copy, nullable) NSString *lastErrorMessage;

@property (nonatomic, copy, nullable) YTMUDiscordTrack *currentTrack;
@property (nonatomic, copy, nullable) NSString *lastPresenceSignature;
@property (nonatomic, assign) long long lastSentStartTimestamp;
@property (nonatomic, assign) BOOL refreshInFlight;

// Cover art resolution is slow enough that it always lands after the first
// presence goes out, so the result is kept here and folded into every
// subsequent activity for the same image.
@property (nonatomic, copy, nullable) NSString *resolvedArtworkURL;
@property (nonatomic, copy, nullable) NSString *resolvedArtworkPath;
@property (nonatomic, copy, nullable) NSString *pendingArtworkURL;
@property (nonatomic, copy, nullable) NSString *failedArtworkURL;
@property (nonatomic, assign) NSTimeInterval failedArtworkAt;

@end

@implementation YTMUDiscordRPC

+ (YTMUDiscordRPC *)sharedInstance {
    static YTMUDiscordRPC *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.ginsu.ytmusicultimate.discord.rpc", DISPATCH_QUEUE_SERIAL);
        _connectionState = YTMUDiscordConnectionStateDisconnected;

        _gateway = [[YTMUDiscordGateway alloc] init];
        _gateway.delegate = self;

        __weak __typeof(self) weakSelf = self;
        _gateway.tokenProvider = ^NSString *{
            NSString *token = weakSelf.accessToken;
            return token.length > 0 ? [@"Bearer " stringByAppendingString:token] : nil;
        };
    }

    return self;
}

- (BOOL)hasStoredCredentials {
    return YTMUDiscordTokenStore.accessToken.length > 0;
}

#pragma mark - Connection

- (void)synchronizeConnection {
    dispatch_async(self.queue, ^{
        if (!YTMUDiscordIsEnabled()) {
            [self teardownConnection];
            return;
        }

        NSString *storedToken = YTMUDiscordTokenStore.accessToken;
        if (storedToken.length == 0) {
            [self teardownConnection];
            return;
        }

        // Already connected or mid-reconnect: leave it alone rather than
        // bouncing a healthy socket every time the app comes to the front.
        if (self.gateway.isActive || self.refreshInFlight) return;

        self.accessToken = storedToken;
        [self setConnectionState:YTMUDiscordConnectionStateConnecting];

        NSString *refreshToken = YTMUDiscordTokenStore.refreshToken;
        NSTimeInterval expiresAt = YTMUDiscordTokenStore.expiresAt;
        BOOL expiringSoon = expiresAt > 0 && (expiresAt - [[NSDate date] timeIntervalSince1970]) < kTokenRefreshWindow;

        if (refreshToken.length > 0 && expiringSoon) {
            [self refreshTokenAndReconnect];
            return;
        }

        [self.gateway connect];
    });
}

// Must run on self.queue.
- (void)teardownConnection {
    [self.gateway disconnect];
    self.currentTrack = nil;
    self.lastPresenceSignature = nil;
    self.lastSentStartTimestamp = 0;
    self.pendingArtworkURL = nil;
    [self setConnectionState:YTMUDiscordConnectionStateDisconnected];
}

// Must run on self.queue.
- (void)refreshTokenAndReconnect {
    if (self.refreshInFlight) return;

    NSString *refreshToken = YTMUDiscordTokenStore.refreshToken;
    if (refreshToken.length == 0) {
        [self handleUnrecoverableAuthFailure];
        return;
    }

    self.refreshInFlight = YES;

    __weak __typeof(self) weakSelf = self;
    [[YTMUDiscordAuth sharedInstance] refreshWithToken:refreshToken completion:^(NSString *accessToken, NSString *newRefreshToken, NSTimeInterval expiresIn, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        dispatch_async(strongSelf.queue, ^{
            strongSelf.refreshInFlight = NO;

            if (error) {
                if (error.code == YTMUDiscordAuthErrorInvalidGrant) {
                    [strongSelf handleUnrecoverableAuthFailure];
                } else {
                    strongSelf.lastErrorMessage = error.localizedDescription;
                    [strongSelf setConnectionState:YTMUDiscordConnectionStateDisconnected];
                }
                return;
            }

            [YTMUDiscordTokenStore storeAccessToken:accessToken refreshToken:newRefreshToken expiresIn:expiresIn];
            strongSelf.accessToken = accessToken;
            [strongSelf.gateway connect];
        });
    }];
}

// Must run on self.queue.
- (void)handleUnrecoverableAuthFailure {
    self.lastErrorMessage = @"Discord sign-in expired";
    [self performLogout];
}

- (void)authorizeFromViewController:(UIViewController *)viewController
                         completion:(void (^)(BOOL, NSError *))completion {
    __weak __typeof(self) weakSelf = self;
    [[YTMUDiscordAuth sharedInstance] authorizeFromViewController:viewController
                                                       completion:^(NSString *accessToken, NSString *refreshToken, NSTimeInterval expiresIn, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        if (error) {
            strongSelf.lastErrorMessage = error.localizedDescription;
            [strongSelf postStateChange];
            if (completion) completion(NO, error);
            return;
        }

        [YTMUDiscordTokenStore storeAccessToken:accessToken refreshToken:refreshToken expiresIn:expiresIn];
        strongSelf.lastErrorMessage = nil;

        dispatch_async(strongSelf.queue, ^{
            strongSelf.accessToken = accessToken;
            [strongSelf setConnectionState:YTMUDiscordConnectionStateConnecting];
            [strongSelf.gateway connect];
        });

        if (completion) completion(YES, nil);
    }];
}

- (void)logout {
    dispatch_async(self.queue, ^{
        self.lastErrorMessage = nil;
        [self performLogout];
    });
}

// Must run on self.queue.
- (void)performLogout {
    [self.gateway disconnect];
    [YTMUDiscordTokenStore clear];
    [YTMUDiscordExternalAssets clearCache];
    YTMUDiscordResetSuperProperties();

    self.accessToken = nil;
    self.username = nil;
    self.currentTrack = nil;
    self.lastPresenceSignature = nil;
    self.lastSentStartTimestamp = 0;

    // External assets belong to the application the tokens were issued for.
    self.resolvedArtworkURL = nil;
    self.resolvedArtworkPath = nil;
    self.pendingArtworkURL = nil;
    self.failedArtworkURL = nil;

    [self setConnectionState:YTMUDiscordConnectionStateDisconnected];
}

#pragma mark - Presence

- (void)invalidateCachedPresence {
    dispatch_async(self.queue, ^{
        self.lastPresenceSignature = nil;
        self.lastSentStartTimestamp = 0;

        YTMUDiscordTrack *track = self.currentTrack;
        if (track) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateWithTrack:track];
            });
        }
    });
}

- (void)updateWithTrack:(YTMUDiscordTrack *)track {
    if (!track.isUsable) return;

    YTMUDiscordTrack *snapshot = [track copy];

    dispatch_async(self.queue, ^{
        if (!YTMUDiscordIsEnabled()) return;

        self.currentTrack = snapshot;

        if (!snapshot.isPlaying && YTMUDiscordPrefBool(YTMUDiscordPrefClearWhenPaused)) {
            [self sendClear];
            return;
        }

        // The lock screen republishes the same track every few seconds. Those
        // repeats must not reach Discord, or each one would overwrite the
        // presence with a copy that has not had its cover art attached yet.
        [self sendActivityIfChanged:[self activityForTrack:snapshot]];
        [self resolveArtworkForTrack:snapshot];
    });
}

// Must run on self.queue. Publishes only when the activity actually differs
// from the one Discord is already showing.
- (void)sendActivityIfChanged:(YTMUDiscordActivity *)activity {
    // Timestamps are compared separately: they move continuously while the
    // rest of the payload stands still, so they cannot go in the signature.
    NSMutableDictionary *payload = [[activity JSONObject] mutableCopy];
    [payload removeObjectForKey:@"timestamps"];

    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingSortedKeys error:nil];
    NSString *signature = data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;

    BOOL contentChanged = signature == nil || ![signature isEqualToString:self.lastPresenceSignature];
    BOOL seeked = llabs(activity.startTimestamp - self.lastSentStartTimestamp) > kSeekToleranceMs;
    if (!contentChanged && !seeked) return;

    self.lastPresenceSignature = signature;
    self.lastSentStartTimestamp = activity.startTimestamp;

    [self sendActivity:activity];
}

// Must run on self.queue.
- (void)resolveArtworkForTrack:(YTMUDiscordTrack *)track {
    if (!YTMUDiscordPrefBool(YTMUDiscordPrefShowArtwork)) return;

    NSString *artworkURL = track.artworkURL;
    if (artworkURL.length == 0) return;

    // Already resolved, already in flight, or recently rejected by Discord.
    if ([artworkURL isEqualToString:self.resolvedArtworkURL] && self.resolvedArtworkPath.length > 0) return;
    if ([artworkURL isEqualToString:self.pendingArtworkURL]) return;
    if ([artworkURL isEqualToString:self.failedArtworkURL]
        && ([[NSDate date] timeIntervalSince1970] - self.failedArtworkAt) < kArtworkRetryDelay) return;

    NSString *token = self.accessToken;
    if (token.length == 0) return;

    self.pendingArtworkURL = artworkURL;

    __weak __typeof(self) weakSelf = self;
    [YTMUDiscordExternalAssets resolveImageURL:artworkURL
                                 applicationID:YTMUDiscordApplicationID()
                                   bearerToken:[@"Bearer " stringByAppendingString:token]
                                    completion:^(NSString *assetPath) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        dispatch_async(strongSelf.queue, ^{
            // A newer track started while this was in flight.
            if (![artworkURL isEqualToString:strongSelf.pendingArtworkURL]) return;
            strongSelf.pendingArtworkURL = nil;

            if (assetPath.length == 0) {
                strongSelf.failedArtworkURL = artworkURL;
                strongSelf.failedArtworkAt = [[NSDate date] timeIntervalSince1970];
                return;
            }

            strongSelf.resolvedArtworkURL = artworkURL;
            strongSelf.resolvedArtworkPath = assetPath;
            strongSelf.failedArtworkURL = nil;

            YTMUDiscordTrack *current = strongSelf.currentTrack;
            if (![current.artworkURL isEqualToString:artworkURL]) return;

            [strongSelf sendActivityIfChanged:[strongSelf activityForTrack:current]];
        });
    }];
}

- (void)clearPresence {
    dispatch_async(self.queue, ^{
        self.currentTrack = nil;
        [self sendClear];
    });
}

// Must run on self.queue.
- (void)sendClear {
    self.lastPresenceSignature = nil;
    self.lastSentStartTimestamp = 0;
    self.pendingArtworkURL = nil;

    NSString *json = [YTMUDiscordPresence presenceUpdateJSONWithActivities:@[] status:@"online"];
    if (json) [self.gateway sendPresenceUpdate:json];
}

// Must run on self.queue.
- (void)sendActivity:(YTMUDiscordActivity *)activity {
    NSString *json = [YTMUDiscordPresence presenceUpdateJSONWithActivities:@[activity] status:@"online"];
    if (json) [self.gateway sendPresenceUpdate:json];
}

// Must run on self.queue.
- (YTMUDiscordActivity *)activityForTrack:(YTMUDiscordTrack *)track {
    NSString *title = track.title ?: @"";
    NSString *artist = track.artist ?: @"";
    NSString *album = track.album;

    YTMUDiscordActivity *activity = [[YTMUDiscordActivity alloc] init];
    activity.type = YTMUDiscordActivityTypeForIndex(YTMUDiscordPrefInteger(YTMUDiscordPrefActivityType));

    NSString *name = YTMUDiscordRenderTemplate(YTMUDiscordPrefString(YTMUDiscordPrefActivityName) ?: @"",
                                               title, artist, album, track.videoID);
    activity.name = name.length > 0 ? name : (artist.length > 0 ? artist : @"YouTube Music");

    activity.details = YTMUDiscordRenderTemplate(YTMUDiscordTemplateOrDefault(YTMUDiscordPrefDetailsTemplate, @"{song.name}"),
                                                 title, artist, album, track.videoID);
    activity.state = YTMUDiscordRenderTemplate(YTMUDiscordTemplateOrDefault(YTMUDiscordPrefStateTemplate, @"{artist.name}"),
                                               title, artist, album, track.videoID);

    if (YTMUDiscordPrefBool(YTMUDiscordPrefShowArtwork)) {
        activity.largeText = album.length > 0 ? album : title;

        // Present only once -resolveArtworkForTrack: has been round the
        // external-assets endpoint for this exact image.
        if (track.artworkURL.length > 0 && [track.artworkURL isEqualToString:self.resolvedArtworkURL]) {
            activity.largeImage = self.resolvedArtworkPath;
        }
    }

    // Discord renders elapsed/remaining from these, so a paused track gets no
    // timestamps at all rather than a bar that keeps running.
    if (YTMUDiscordPrefBool(YTMUDiscordPrefShowTimestamps) && track.isPlaying && track.duration > 0) {
        NSTimeInterval elapsed = MAX(0.0, MIN(track.elapsed, track.duration));
        long long startMs = (long long)(([[NSDate date] timeIntervalSince1970] - elapsed) * 1000.0);
        activity.startTimestamp = startMs;
        activity.endTimestamp = startMs + (long long)(track.duration * 1000.0);
    }

    if (YTMUDiscordPrefBool(YTMUDiscordPrefShowButtons)) {
        NSMutableArray<NSArray<NSString *> *> *buttons = [NSMutableArray array];
        if (track.videoID.length > 0) {
            [buttons addObject:@[@"Listen on YouTube Music",
                                 [YTMUDiscordWatchURLPrefix stringByAppendingString:track.videoID]]];
        }
        [buttons addObject:@[@"YTMusicUltimate", YTMUDiscordSourceURL]];
        activity.buttons = buttons;
    }

    return activity;
}

#pragma mark - Current user

- (void)fetchCurrentUser {
    NSString *token = self.accessToken;
    if (token.length == 0) return;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/v10/users/@me", YTMUDiscordAPIBase]]];
    [request setValue:[@"Bearer " stringByAppendingString:token] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    __weak __typeof(self) weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || error || data.length == 0) return;

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (![json isKindOfClass:[NSDictionary class]]) return;

        NSString *username = json[@"global_name"];
        if (![username isKindOfClass:[NSString class]] || username.length == 0) username = json[@"username"];
        if (![username isKindOfClass:[NSString class]] || username.length == 0) return;

        strongSelf.username = username;
        [strongSelf postStateChange];
    }] resume];
}

#pragma mark - State

- (void)setConnectionState:(YTMUDiscordConnectionState)connectionState {
    if (_connectionState == connectionState) return;

    _connectionState = connectionState;
    [self postStateChange];
}

- (void)postStateChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:YTMUDiscordStateDidChangeNotification object:self];
    });
}

#pragma mark - YTMUDiscordGatewayDelegate

- (void)gatewayDidBecomeReady:(YTMUDiscordGateway *)gateway {
    dispatch_async(self.queue, ^{
        self.lastErrorMessage = nil;
        [self setConnectionState:YTMUDiscordConnectionStateConnected];
        [self fetchCurrentUser];
        [self resendCurrentPresence];
    });
}

- (void)gatewayDidResume:(YTMUDiscordGateway *)gateway {
    dispatch_async(self.queue, ^{
        self.lastErrorMessage = nil;
        [self setConnectionState:YTMUDiscordConnectionStateConnected];
        [self resendCurrentPresence];
    });
}

- (void)gateway:(YTMUDiscordGateway *)gateway didDisconnectWithCode:(NSInteger)code reason:(NSString *)reason {
    dispatch_async(self.queue, ^{
        [self setConnectionState:YTMUDiscordConnectionStateDisconnected];
    });
}

- (void)gatewayRequiresTokenRefresh:(YTMUDiscordGateway *)gateway {
    dispatch_async(self.queue, ^{
        [self refreshTokenAndReconnect];
    });
}

// Must run on self.queue.
- (void)resendCurrentPresence {
    YTMUDiscordTrack *track = self.currentTrack;
    if (!track) return;

    self.lastPresenceSignature = nil;
    self.lastSentStartTimestamp = 0;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateWithTrack:track];
    });
}

@end
