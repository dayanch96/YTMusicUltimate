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
// Upper bound on alternative images tried for one track, so a track Discord
// simply will not take does not turn into a run of pointless requests. High
// enough to still reach the plain thumbnail names after the player's own
// list, since those are the likeliest to be accepted.
static NSUInteger const kMaxArtworkCandidates = 6;
// Discord rate limits presence updates, and skipping through a queue can
// produce them far faster than this. Bursts are coalesced to this interval,
// with the last state always sent once it expires.
static NSTimeInterval const kMinimumSendInterval = 2.0;
// Stands in for "no activity" in the delivered-state comparison, kept distinct
// from a real serialised activity so the two can never collide.
static NSString *const kClearedSignature = @"\x01cleared";

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
    copy.artworkCandidates = self.artworkCandidates;
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
@property (nonatomic, assign) BOOL refreshInFlight;

// What Discord is believed to be showing. Only written once the gateway has
// accepted the frame, so an update that never made it off the device is
// retried rather than deduplicated away.
@property (nonatomic, copy, nullable) NSString *deliveredSignature;
@property (nonatomic, assign) long long deliveredStartTimestamp;
@property (nonatomic, assign) NSTimeInterval lastSendAt;
@property (nonatomic, assign) BOOL flushScheduled;

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
    self.deliveredSignature = nil;
    self.deliveredStartTimestamp = 0;
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
    self.deliveredSignature = nil;
    self.deliveredStartTimestamp = 0;

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
        self.deliveredSignature = nil;
        self.deliveredStartTimestamp = 0;
        [self publishCurrentActivity];
    });
}

- (void)updateWithTrack:(YTMUDiscordTrack *)track {
    if (!track.isUsable) return;

    YTMUDiscordTrack *snapshot = [track copy];

    dispatch_async(self.queue, ^{
        if (!YTMUDiscordIsEnabled()) return;

        self.currentTrack = snapshot;
        [self publishCurrentActivity];
        [self resolveArtworkForTrack:snapshot];
    });
}

// Must run on self.queue. Brings Discord in line with self.currentTrack,
// sending only when it is actually out of date. The lock screen calls this
// every few seconds, which doubles as the retry driver for anything that
// previously failed to go out.
- (void)publishCurrentActivity {
    YTMUDiscordTrack *track = self.currentTrack;
    if (!track.isUsable) return;

    if (!track.isPlaying && YTMUDiscordPrefBool(YTMUDiscordPrefClearWhenPaused)) {
        [self sendClear];
        return;
    }

    YTMUDiscordActivity *activity = [self activityForTrack:track];
    NSString *signature = [self signatureForActivity:activity];

    BOOL contentChanged = signature == nil || ![signature isEqualToString:self.deliveredSignature];
    BOOL seeked = llabs(activity.startTimestamp - self.deliveredStartTimestamp) > kSeekToleranceMs;
    if (!contentChanged && !seeked) return;

    // Skipping through a queue can change the track faster than Discord will
    // accept updates. Hold the burst back, but always schedule the trailing
    // send so the track that is actually playing is the one that lands.
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval sinceLastSend = now - self.lastSendAt;
    if (self.lastSendAt > 0 && sinceLastSend < kMinimumSendInterval) {
        [self scheduleFlushAfter:(kMinimumSendInterval - sinceLastSend)];
        return;
    }

    // Only record it as delivered if the gateway actually took it, otherwise
    // the next call retries instead of assuming Discord is up to date.
    if (![self sendActivity:activity]) return;

    self.deliveredSignature = signature;
    self.deliveredStartTimestamp = activity.startTimestamp;
    self.lastSendAt = now;
}

// Must run on self.queue.
- (void)scheduleFlushAfter:(NSTimeInterval)delay {
    if (self.flushScheduled) return;
    self.flushScheduled = YES;

    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), self.queue, ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        strongSelf.flushScheduled = NO;
        [strongSelf publishCurrentActivity];
    });
}

// Timestamps are excluded: they advance continuously while the rest of the
// payload stands still, so they are compared separately against a tolerance.
- (nullable NSString *)signatureForActivity:(YTMUDiscordActivity *)activity {
    NSMutableDictionary *payload = [[activity JSONObject] mutableCopy];
    [payload removeObjectForKey:@"timestamps"];

    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:NSJSONWritingSortedKeys error:nil];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
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

    NSArray<NSString *> *candidates = track.artworkCandidates.count > 0 ? track.artworkCandidates : @[artworkURL];

    self.pendingArtworkURL = artworkURL;
    [self resolveCandidates:candidates
                    atIndex:0
              forArtworkURL:artworkURL
                bearerToken:[@"Bearer " stringByAppendingString:token]];
}

// Must run on self.queue. Discord silently refuses some perfectly reachable
// images, so the alternatives are tried in turn rather than giving up on the
// first refusal.
- (void)resolveCandidates:(NSArray<NSString *> *)candidates
                  atIndex:(NSUInteger)index
            forArtworkURL:(NSString *)artworkURL
              bearerToken:(NSString *)bearerToken {
    if (index >= candidates.count || index >= kMaxArtworkCandidates) {
        if ([artworkURL isEqualToString:self.pendingArtworkURL]) {
            self.pendingArtworkURL = nil;
            self.failedArtworkURL = artworkURL;
            self.failedArtworkAt = [[NSDate date] timeIntervalSince1970];
        }
        return;
    }

    __weak __typeof(self) weakSelf = self;
    [YTMUDiscordExternalAssets resolveImageURL:candidates[index]
                                 applicationID:YTMUDiscordApplicationID()
                                   bearerToken:bearerToken
                                    completion:^(NSString *assetPath) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        dispatch_async(strongSelf.queue, ^{
            // A newer track started while this was in flight.
            if (![artworkURL isEqualToString:strongSelf.pendingArtworkURL]) return;

            if (assetPath.length == 0) {
                [strongSelf resolveCandidates:candidates
                                      atIndex:index + 1
                                forArtworkURL:artworkURL
                                  bearerToken:bearerToken];
                return;
            }

            strongSelf.pendingArtworkURL = nil;
            strongSelf.resolvedArtworkURL = artworkURL;
            strongSelf.resolvedArtworkPath = assetPath;
            strongSelf.failedArtworkURL = nil;

            YTMUDiscordTrack *current = strongSelf.currentTrack;
            if (![current.artworkURL isEqualToString:artworkURL]) return;

            [strongSelf publishCurrentActivity];
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
    // Pausing keeps the lock screen ticking, so without this the clear would
    // be resent every few seconds for as long as playback stays paused.
    if ([self.deliveredSignature isEqualToString:kClearedSignature]) return;

    NSString *json = [YTMUDiscordPresence presenceUpdateJSONWithActivities:@[] status:@"online"];
    if (!json) return;

    // An empty activity list is a state like any other, so record it only once
    // the gateway takes it and leave the retry to the next update otherwise.
    if (![self.gateway sendPresenceUpdate:json]) return;

    self.deliveredSignature = kClearedSignature;
    self.deliveredStartTimestamp = 0;
    self.lastSendAt = [[NSDate date] timeIntervalSince1970];
    self.pendingArtworkURL = nil;
}

// Must run on self.queue.
- (BOOL)sendActivity:(YTMUDiscordActivity *)activity {
    NSString *json = [YTMUDiscordPresence presenceUpdateJSONWithActivities:@[activity] status:@"online"];
    return json ? [self.gateway sendPresenceUpdate:json] : NO;
}

// Must run on self.queue.
- (YTMUDiscordActivity *)activityForTrack:(YTMUDiscordTrack *)track {
    NSString *title = track.title ?: @"";
    NSString *artist = track.artist ?: @"";
    NSString *album = track.album;

    YTMUDiscordActivity *activity = [[YTMUDiscordActivity alloc] init];
    activity.type = YTMUDiscordActivityTypeForIndex(YTMUDiscordPrefInteger(YTMUDiscordPrefActivityType));

    if (YTMUDiscordPrefBool(YTMUDiscordPrefNameFromSong)) {
        // Built directly rather than through a template so a missing artist
        // does not leave a dangling separator.
        activity.name = artist.length > 0 ? [NSString stringWithFormat:@"%@ - %@", title, artist] : title;
    } else {
        NSString *name = YTMUDiscordRenderTemplate(YTMUDiscordPrefString(YTMUDiscordPrefActivityName) ?: @"",
                                                   title, artist, album, track.videoID);
        activity.name = name.length > 0 ? name : (artist.length > 0 ? artist : @"YouTube Music");
    }

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

    NSMutableArray<NSArray<NSString *> *> *buttons = [NSMutableArray array];

    if (YTMUDiscordPrefBool(YTMUDiscordPrefShowListenButton) && track.videoID.length > 0) {
        [buttons addObject:@[@"Listen on YouTube Music",
                             [YTMUDiscordWatchURLPrefix stringByAppendingString:track.videoID]]];
    }

    if (YTMUDiscordPrefBool(YTMUDiscordPrefShowTweakButton)) {
        [buttons addObject:@[@"YTMusicUltimate", YTMUDiscordSourceURL]];
    }

    activity.buttons = buttons;

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
    // A new session starts with no presence at all, so whatever Discord was
    // showing before the drop no longer counts as delivered.
    self.deliveredSignature = nil;
    self.deliveredStartTimestamp = 0;
    self.lastSendAt = 0;

    [self publishCurrentActivity];
}

@end
