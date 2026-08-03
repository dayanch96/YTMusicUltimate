#import <math.h>
#import "YTMUDiscordGateway.h"
#import "YTMUDiscordDefaults.h"

// Closing with 1000 tells Discord to drop the session for good; any other code
// leaves it resumable.
static NSURLSessionWebSocketCloseCode const kResumableCloseCode = (NSURLSessionWebSocketCloseCode)4000;

typedef NS_ENUM(NSInteger, YTMUDiscordOpcode) {
    YTMUDiscordOpcodeDispatch = 0,
    YTMUDiscordOpcodeHeartbeat = 1,
    YTMUDiscordOpcodeIdentify = 2,
    YTMUDiscordOpcodePresenceUpdate = 3,
    YTMUDiscordOpcodeResume = 6,
    YTMUDiscordOpcodeReconnect = 7,
    YTMUDiscordOpcodeInvalidSession = 9,
    YTMUDiscordOpcodeHello = 10,
    YTMUDiscordOpcodeHeartbeatAck = 11
};

typedef NS_ENUM(NSInteger, YTMUDiscordReconnectAction) {
    YTMUDiscordReconnectActionResume = 0,
    YTMUDiscordReconnectActionReidentify,
    YTMUDiscordReconnectActionRefreshToken,
    YTMUDiscordReconnectActionFatal
};

static NSInteger const kMaxReconnectAttempts = 7;
static NSTimeInterval const kBaseReconnectDelay = 1.0;
static NSTimeInterval const kMaxReconnectDelay = 64.0;
static NSTimeInterval const kDefaultHeartbeatInterval = 41.25;

@interface YTMUDiscordGateway () <NSURLSessionWebSocketDelegate>

@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong, nullable) NSURLSessionWebSocketTask *task;
@property (nonatomic, strong, nullable) dispatch_source_t heartbeatTimer;

@property (nonatomic, copy) NSString *gatewayURL;
@property (nonatomic, copy, nullable) NSString *sessionID;
@property (nonatomic, assign) NSInteger sequence;
@property (nonatomic, assign) NSInteger reconnectAttempts;
@property (nonatomic, assign) NSUInteger generation;

@property (nonatomic, assign) BOOL open;
@property (nonatomic, assign, getter=isReady) BOOL ready;
@property (atomic, assign, getter=isActive) BOOL active;
@property (nonatomic, assign) BOOL stopped;
@property (nonatomic, assign) BOOL awaitingHeartbeatAck;

@end

@implementation YTMUDiscordGateway

- (instancetype)init {
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("com.ginsu.ytmusicultimate.discord.gateway", DISPATCH_QUEUE_SERIAL);
        _gatewayURL = YTMUDiscordGatewayURL;
        _stopped = YES;

        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.maxConcurrentOperationCount = 1;
        delegateQueue.underlyingQueue = _queue;

        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 30.0;
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:delegateQueue];
    }

    return self;
}

#pragma mark - Connection lifecycle

- (void)connect {
    self.active = YES;

    dispatch_async(self.queue, ^{
        self.stopped = NO;
        [self openSocket];
    });
}

- (void)disconnect {
    self.active = NO;

    dispatch_async(self.queue, ^{
        self.stopped = YES;
        self.sessionID = nil;
        self.sequence = 0;
        self.reconnectAttempts = 0;
        self.gatewayURL = YTMUDiscordGatewayURL;
        [self teardownSocketWithCloseCode:NSURLSessionWebSocketCloseCodeNormalClosure];
    });
}

// Must run on self.queue.
- (void)openSocket {
    [self teardownSocketWithCloseCode:kResumableCloseCode];

    NSURL *url = [NSURL URLWithString:self.gatewayURL];
    if (!url) {
        self.gatewayURL = YTMUDiscordGatewayURL;
        url = [NSURL URLWithString:self.gatewayURL];
    }

    self.generation++;
    self.awaitingHeartbeatAck = NO;

    NSURLSessionWebSocketTask *task = [self.session webSocketTaskWithURL:url];
    self.task = task;
    [task resume];

    [self receiveNextMessageForGeneration:self.generation];
}

// Must run on self.queue.
- (void)teardownSocketWithCloseCode:(NSURLSessionWebSocketCloseCode)closeCode {
    [self stopHeartbeat];

    self.open = NO;
    self.ready = NO;

    NSURLSessionWebSocketTask *task = self.task;
    self.task = nil;
    [task cancelWithCloseCode:closeCode reason:nil];
}

#pragma mark - Receiving

- (void)receiveNextMessageForGeneration:(NSUInteger)generation {
    NSURLSessionWebSocketTask *task = self.task;
    if (!task) return;

    __weak __typeof(self) weakSelf = self;
    [task receiveMessageWithCompletionHandler:^(NSURLSessionWebSocketMessage *message, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        dispatch_async(strongSelf.queue, ^{
            if (generation != strongSelf.generation) return;

            if (error) {
                [strongSelf handleCloseWithCode:4000 reason:error.localizedDescription generation:generation];
                return;
            }

            if (message.type == NSURLSessionWebSocketMessageTypeString && message.string) {
                [strongSelf handleFrame:message.string];
            }

            [strongSelf receiveNextMessageForGeneration:generation];
        });
    }];
}

// Must run on self.queue.
- (void)handleFrame:(NSString *)text {
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *frame = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
    if (![frame isKindOfClass:[NSDictionary class]]) return;

    NSInteger op = [frame[@"op"] integerValue];
    id payload = frame[@"d"];
    NSDictionary *payloadDictionary = [payload isKindOfClass:[NSDictionary class]] ? payload : nil;

    id sequenceValue = frame[@"s"];
    if ([sequenceValue isKindOfClass:[NSNumber class]]) {
        NSInteger sequence = [sequenceValue integerValue];
        if (sequence > 0) self.sequence = sequence;
    }

    switch (op) {
        case YTMUDiscordOpcodeHello: {
            NSTimeInterval interval = [payloadDictionary[@"heartbeat_interval"] doubleValue] / 1000.0;
            if (interval <= 0) interval = kDefaultHeartbeatInterval;
            [self startHeartbeatWithInterval:interval];
            [self sendHandshake];
            break;
        }

        case YTMUDiscordOpcodeHeartbeat:
            [self sendHeartbeat];
            break;

        case YTMUDiscordOpcodeHeartbeatAck:
            self.awaitingHeartbeatAck = NO;
            break;

        case YTMUDiscordOpcodeInvalidSession: {
            BOOL resumable = [payload isKindOfClass:[NSNumber class]] && [payload boolValue];
            if (!resumable) {
                self.sessionID = nil;
                self.sequence = 0;
            }
            [self handleCloseWithCode:4000 reason:@"invalid session" generation:self.generation];
            break;
        }

        case YTMUDiscordOpcodeReconnect:
            [self handleCloseWithCode:4000 reason:@"reconnect requested" generation:self.generation];
            break;

        case YTMUDiscordOpcodeDispatch: {
            NSString *type = [frame[@"t"] isKindOfClass:[NSString class]] ? frame[@"t"] : nil;

            if ([type isEqualToString:@"READY"]) {
                self.sessionID = payloadDictionary[@"session_id"];
                NSString *resumeURL = payloadDictionary[@"resume_gateway_url"];
                if ([resumeURL isKindOfClass:[NSString class]] && resumeURL.length > 0) {
                    self.gatewayURL = [resumeURL stringByAppendingString:@"?v=10&encoding=json"];
                }
                self.reconnectAttempts = 0;
                self.ready = YES;
                [self notifyDelegate:@selector(gatewayDidBecomeReady:)];
            } else if ([type isEqualToString:@"RESUMED"]) {
                self.reconnectAttempts = 0;
                self.ready = YES;
                [self notifyDelegate:@selector(gatewayDidResume:)];
            }
            break;
        }

        default:
            break;
    }
}

#pragma mark - Sending

// Must run on self.queue.
- (void)sendFrame:(NSDictionary *)frame {
    NSData *data = [NSJSONSerialization dataWithJSONObject:frame options:0 error:nil];
    if (!data) return;

    NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (text) [self sendString:text];
}

// Must run on self.queue. The task buffers sends made before the handshake
// finishes, so this deliberately does not wait on -open.
- (void)sendString:(NSString *)text {
    NSURLSessionWebSocketTask *task = self.task;
    if (!task) return;

    NSURLSessionWebSocketMessage *message = [[NSURLSessionWebSocketMessage alloc] initWithString:text];
    [task sendMessage:message completionHandler:^(NSError *error) {
        // Send failures surface through the receive loop as a socket error.
    }];
}

- (void)sendPresenceUpdate:(NSString *)presenceJSON {
    if (presenceJSON.length == 0) return;

    dispatch_async(self.queue, ^{
        if (!self.ready) return;
        [self sendString:presenceJSON];
    });
}

// Must run on self.queue.
- (void)sendHandshake {
    NSString *token = self.tokenProvider ? self.tokenProvider() : nil;
    if (token.length == 0) {
        [self handleCloseWithCode:4004 reason:@"no token available" generation:self.generation];
        return;
    }

    if (self.sessionID.length > 0 && self.sequence > 0) {
        [self sendFrame:@{
            @"op": @(YTMUDiscordOpcodeResume),
            @"d": @{@"token": token, @"session_id": self.sessionID, @"seq": @(self.sequence)}
        }];
        return;
    }

    [self sendFrame:@{
        @"op": @(YTMUDiscordOpcodeIdentify),
        @"d": @{
            @"token": token,
            @"intents": @(0),
            @"compress": @(NO),
            @"properties": @{
                @"os": @"ios",
                @"browser": @"Discord iOS",
                @"device": YTMUDiscordApplicationID()
            }
        }
    }];
}

#pragma mark - Heartbeat

// Must run on self.queue.
- (void)startHeartbeatWithInterval:(NSTimeInterval)interval {
    [self stopHeartbeat];

    self.awaitingHeartbeatAck = NO;

    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue);
    // Discord asks for the first beat to land after a random fraction of the
    // interval so clients do not all fire at once.
    NSTimeInterval jitter = interval * ((double)arc4random_uniform(1000) / 1000.0);
    dispatch_source_set_timer(timer,
                              dispatch_time(DISPATCH_TIME_NOW, (int64_t)(jitter * NSEC_PER_SEC)),
                              (uint64_t)(interval * NSEC_PER_SEC),
                              (uint64_t)(NSEC_PER_SEC));

    __weak __typeof(self) weakSelf = self;
    dispatch_source_set_event_handler(timer, ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        if (strongSelf.awaitingHeartbeatAck) {
            // A missed acknowledgement means the connection is a zombie.
            [strongSelf handleCloseWithCode:4000 reason:@"heartbeat timeout" generation:strongSelf.generation];
            return;
        }

        [strongSelf sendHeartbeat];
    });

    self.heartbeatTimer = timer;
    dispatch_resume(timer);
}

// Must run on self.queue.
- (void)stopHeartbeat {
    if (self.heartbeatTimer) {
        dispatch_source_cancel(self.heartbeatTimer);
        self.heartbeatTimer = nil;
    }
}

// Must run on self.queue.
- (void)sendHeartbeat {
    self.awaitingHeartbeatAck = YES;
    [self sendFrame:@{
        @"op": @(YTMUDiscordOpcodeHeartbeat),
        @"d": self.sequence > 0 ? @(self.sequence) : [NSNull null]
    }];
}

#pragma mark - Reconnection

+ (YTMUDiscordReconnectAction)actionForCloseCode:(NSInteger)code hasSession:(BOOL)hasSession {
    switch (code) {
        case 4004: return YTMUDiscordReconnectActionRefreshToken;
        case 4010:
        case 4011:
        case 4012:
        case 4013:
        case 4014: return YTMUDiscordReconnectActionFatal;
        default: return hasSession ? YTMUDiscordReconnectActionResume : YTMUDiscordReconnectActionReidentify;
    }
}

// Must run on self.queue.
- (void)handleCloseWithCode:(NSInteger)code reason:(NSString *)reason generation:(NSUInteger)generation {
    if (generation != self.generation) return;
    if (self.stopped) return;
    if (!self.task && !self.open) return;

    [self teardownSocketWithCloseCode:kResumableCloseCode];
    [self notifyDisconnectWithCode:code reason:reason];

    BOOL hasSession = self.sessionID.length > 0 && self.sequence > 0;
    YTMUDiscordReconnectAction action = [[self class] actionForCloseCode:code hasSession:hasSession];

    if (action == YTMUDiscordReconnectActionFatal) {
        self.stopped = YES;
        self.active = NO;
        self.sessionID = nil;
        self.sequence = 0;
        return;
    }

    if (action == YTMUDiscordReconnectActionRefreshToken) {
        self.stopped = YES;
        self.active = NO;
        self.sessionID = nil;
        self.sequence = 0;
        [self notifyDelegate:@selector(gatewayRequiresTokenRefresh:)];
        return;
    }

    if (action == YTMUDiscordReconnectActionReidentify) {
        self.sessionID = nil;
        self.sequence = 0;
        self.gatewayURL = YTMUDiscordGatewayURL;
    }

    if (self.reconnectAttempts >= kMaxReconnectAttempts) {
        self.stopped = YES;
        self.active = NO;
        return;
    }

    self.reconnectAttempts++;

    NSTimeInterval delay = MIN(kBaseReconnectDelay * pow(2, self.reconnectAttempts - 1), kMaxReconnectDelay);
    delay += ((double)arc4random_uniform(1000) / 1000.0) * delay * 0.25;

    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), self.queue, ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf || strongSelf.stopped) return;
        [strongSelf openSocket];
    });
}

#pragma mark - Delegate helpers

- (void)notifyDelegate:(SEL)selector {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        id<YTMUDiscordGatewayDelegate> delegate = strongSelf.delegate;
        if ([delegate respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [delegate performSelector:selector withObject:strongSelf];
#pragma clang diagnostic pop
        }
    });
}

- (void)notifyDisconnectWithCode:(NSInteger)code reason:(NSString *)reason {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        [strongSelf.delegate gateway:strongSelf didDisconnectWithCode:code reason:reason];
    });
}

#pragma mark - NSURLSessionWebSocketDelegate

- (void)URLSession:(NSURLSession *)session
      webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask
 didOpenWithProtocol:(NSString *)protocol {
    if (webSocketTask != self.task) return;
    self.open = YES;
}

- (void)URLSession:(NSURLSession *)session
      webSocketTask:(NSURLSessionWebSocketTask *)webSocketTask
   didCloseWithCode:(NSURLSessionWebSocketCloseCode)closeCode
             reason:(NSData *)reason {
    if (webSocketTask != self.task) return;

    NSString *text = reason.length > 0 ? [[NSString alloc] initWithData:reason encoding:NSUTF8StringEncoding] : nil;
    [self handleCloseWithCode:(NSInteger)closeCode reason:text generation:self.generation];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (task != self.task) return;
    if (!error) return;

    [self handleCloseWithCode:4000 reason:error.localizedDescription generation:self.generation];
}

@end
