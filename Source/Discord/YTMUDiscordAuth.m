#import <AuthenticationServices/AuthenticationServices.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>
#import "YTMUDiscordAuth.h"
#import "YTMUDiscordDefaults.h"

NSString *const YTMUDiscordAuthErrorDomain = @"YTMUDiscordAuthErrorDomain";

@interface YTMUDiscordAuth () <ASWebAuthenticationPresentationContextProviding>
@property (nonatomic, strong, nullable) ASWebAuthenticationSession *session;
@property (nonatomic, weak, nullable) UIViewController *presentingViewController;
@property (nonatomic, strong) NSURLSession *urlSession;
@end

@implementation YTMUDiscordAuth

+ (instancetype)sharedInstance {
    static YTMUDiscordAuth *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });

    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        configuration.timeoutIntervalForRequest = 15.0;
        _urlSession = [NSURLSession sessionWithConfiguration:configuration];
    }

    return self;
}

#pragma mark - PKCE

+ (NSString *)base64URLEncoded:(NSData *)data {
    NSString *encoded = [data base64EncodedStringWithOptions:0];
    encoded = [encoded stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    encoded = [encoded stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    encoded = [encoded stringByReplacingOccurrencesOfString:@"=" withString:@""];

    return encoded;
}

+ (NSString *)randomStringWithByteCount:(NSUInteger)count {
    NSMutableData *data = [NSMutableData dataWithLength:count];
    if (SecRandomCopyBytes(kSecRandomDefault, count, data.mutableBytes) != errSecSuccess) {
        // Fall back to a UUID pair rather than emitting predictable zero bytes.
        NSString *fallback = [NSString stringWithFormat:@"%@%@", [NSUUID UUID].UUIDString, [NSUUID UUID].UUIDString];
        return [self base64URLEncoded:[fallback dataUsingEncoding:NSUTF8StringEncoding]];
    }

    return [self base64URLEncoded:data];
}

+ (NSString *)challengeForVerifier:(NSString *)verifier {
    NSData *data = [verifier dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, digest);

    return [self base64URLEncoded:[NSData dataWithBytes:digest length:CC_SHA256_DIGEST_LENGTH]];
}

#pragma mark - Authorization

- (void)authorizeFromViewController:(UIViewController *)viewController
                         completion:(YTMUDiscordAuthCompletion)completion {
    NSString *appID = YTMUDiscordApplicationID();
    if (appID.length == 0) {
        [self finishWithError:YTMUDiscordAuthErrorMissingAppID message:@"No Discord application id configured" completion:completion];
        return;
    }

    NSString *verifier = [[self class] randomStringWithByteCount:64];
    NSString *challenge = [[self class] challengeForVerifier:verifier];
    NSString *state = [[self class] randomStringWithByteCount:16];

    self.presentingViewController = viewController;

    NSURLComponents *components = [NSURLComponents componentsWithString:YTMUDiscordOAuthAuthorizeURL];
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName:@"client_id" value:appID],
        [NSURLQueryItem queryItemWithName:@"response_type" value:@"code"],
        [NSURLQueryItem queryItemWithName:@"redirect_uri" value:YTMUDiscordCallbackURL],
        [NSURLQueryItem queryItemWithName:@"scope" value:YTMUDiscordOAuthScopes],
        [NSURLQueryItem queryItemWithName:@"state" value:state],
        [NSURLQueryItem queryItemWithName:@"code_challenge_method" value:@"S256"],
        [NSURLQueryItem queryItemWithName:@"code_challenge" value:challenge]
    ];

    __weak __typeof(self) weakSelf = self;
    ASWebAuthenticationSession *session = [[ASWebAuthenticationSession alloc] initWithURL:components.URL
                                                                       callbackURLScheme:YTMUDiscordCallbackScheme
                                                                       completionHandler:^(NSURL *callbackURL, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        strongSelf.session = nil;

        if (error || callbackURL == nil) {
            [strongSelf finishWithError:YTMUDiscordAuthErrorCancelled message:error.localizedDescription ?: @"Authorization cancelled" completion:completion];
            return;
        }

        NSURLComponents *callbackComponents = [NSURLComponents componentsWithURL:callbackURL resolvingAgainstBaseURL:NO];
        NSString *code = nil;
        NSString *returnedState = nil;
        NSString *oauthError = nil;

        for (NSURLQueryItem *item in callbackComponents.queryItems) {
            if ([item.name isEqualToString:@"code"]) code = item.value;
            else if ([item.name isEqualToString:@"state"]) returnedState = item.value;
            else if ([item.name isEqualToString:@"error"]) oauthError = item.value;
        }

        if (oauthError) {
            [strongSelf finishWithError:YTMUDiscordAuthErrorCancelled message:oauthError completion:completion];
            return;
        }

        if (![returnedState isEqualToString:state]) {
            [strongSelf finishWithError:YTMUDiscordAuthErrorStateMismatch message:@"OAuth state mismatch" completion:completion];
            return;
        }

        if (code.length == 0) {
            [strongSelf finishWithError:YTMUDiscordAuthErrorMissingCode message:@"Missing authorization code" completion:completion];
            return;
        }

        [strongSelf exchangeGrantType:@"authorization_code"
                           parameters:@{@"code": code,
                                        @"redirect_uri": YTMUDiscordCallbackURL,
                                        @"code_verifier": verifier}
                           completion:completion];
    }];

    session.presentationContextProvider = self;
    self.session = session;

    if (![session start]) {
        self.session = nil;
        [self finishWithError:YTMUDiscordAuthErrorCancelled message:@"Could not present the Discord login page" completion:completion];
    }
}

- (void)refreshWithToken:(NSString *)refreshToken completion:(YTMUDiscordAuthCompletion)completion {
    [self exchangeGrantType:@"refresh_token"
                 parameters:@{@"refresh_token": refreshToken}
                 completion:completion];
}

- (void)cancel {
    [self.session cancel];
    self.session = nil;
}

#pragma mark - Token endpoint

- (void)exchangeGrantType:(NSString *)grantType
               parameters:(NSDictionary<NSString *, NSString *> *)parameters
               completion:(YTMUDiscordAuthCompletion)completion {
    NSString *appID = YTMUDiscordApplicationID();
    if (appID.length == 0) {
        [self finishWithError:YTMUDiscordAuthErrorMissingAppID message:@"No Discord application id configured" completion:completion];
        return;
    }

    NSMutableDictionary *form = [NSMutableDictionary dictionaryWithDictionary:parameters];
    form[@"client_id"] = appID;
    form[@"grant_type"] = grantType;

    NSMutableArray<NSString *> *pairs = [NSMutableArray array];
    NSCharacterSet *allowed = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~"];
    for (NSString *name in form) {
        NSString *encodedName = [name stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        NSString *encodedValue = [form[name] stringByAddingPercentEncodingWithAllowedCharacters:allowed];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", encodedName, encodedValue]];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:YTMUDiscordOAuthTokenURL]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[pairs componentsJoinedByString:@"&"] dataUsingEncoding:NSUTF8StringEncoding];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    __weak __typeof(self) weakSelf = self;
    [[self.urlSession dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        if (error) {
            [strongSelf finishWithError:YTMUDiscordAuthErrorNetwork message:error.localizedDescription completion:completion];
            return;
        }

        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        NSDictionary *json = data.length > 0 ? [NSJSONSerialization JSONObjectWithData:data options:0 error:nil] : nil;
        if (![json isKindOfClass:[NSDictionary class]]) json = nil;

        if (statusCode < 200 || statusCode > 299) {
            NSString *oauthError = json[@"error"];
            YTMUDiscordAuthError code = [oauthError isEqualToString:@"invalid_grant"]
                ? YTMUDiscordAuthErrorInvalidGrant
                : YTMUDiscordAuthErrorNetwork;
            [strongSelf finishWithError:code
                                message:[NSString stringWithFormat:@"Discord returned HTTP %ld (%@)", (long)statusCode, oauthError ?: @"unknown"]
                             completion:completion];
            return;
        }

        NSString *accessToken = json[@"access_token"];
        if (accessToken.length == 0) {
            [strongSelf finishWithError:YTMUDiscordAuthErrorNetwork message:@"Discord returned no access token" completion:completion];
            return;
        }

        NSString *refreshToken = json[@"refresh_token"];
        NSTimeInterval expiresIn = [json[@"expires_in"] doubleValue];

        dispatch_async(dispatch_get_main_queue(), ^{
            completion(accessToken, [refreshToken isKindOfClass:[NSString class]] ? refreshToken : nil, expiresIn, nil);
        });
    }] resume];
}

- (void)finishWithError:(YTMUDiscordAuthError)code
                message:(NSString *)message
             completion:(YTMUDiscordAuthCompletion)completion {
    NSError *error = [NSError errorWithDomain:YTMUDiscordAuthErrorDomain
                                         code:code
                                     userInfo:@{NSLocalizedDescriptionKey: message ?: @"Discord authorization failed"}];

    dispatch_async(dispatch_get_main_queue(), ^{
        completion(nil, nil, 0, error);
    });
}

#pragma mark - ASWebAuthenticationPresentationContextProviding

- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session {
    UIWindow *window = self.presentingViewController.view.window;
    if (window) return window;

    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) continue;
        for (UIWindow *candidate in ((UIWindowScene *)scene).windows) {
            if (candidate.isKeyWindow) return candidate;
        }
    }

    return [UIApplication sharedApplication].windows.firstObject;
}

@end
