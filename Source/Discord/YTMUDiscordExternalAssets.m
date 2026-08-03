#import "YTMUDiscordExternalAssets.h"
#import "YTMUDiscordDefaults.h"

static NSUInteger const kMaxCacheEntries = 128;

@implementation YTMUDiscordExternalAssets

+ (NSCache<NSString *, NSString *> *)cache {
    static NSCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
        cache.countLimit = kMaxCacheEntries;
    });

    return cache;
}

+ (NSURLSession *)session {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 10.0;
        session = [NSURLSession sessionWithConfiguration:configuration];
    });

    return session;
}

+ (void)resolveImageURL:(NSString *)imageURL
          applicationID:(NSString *)applicationID
            bearerToken:(NSString *)bearerToken
             completion:(void (^)(NSString *_Nullable assetPath))completion {
    if (imageURL.length == 0 || applicationID.length == 0 || bearerToken.length == 0) {
        completion(nil);
        return;
    }

    // Already an asset path, nothing to do.
    if ([imageURL hasPrefix:@"mp:"]) {
        completion(imageURL);
        return;
    }

    NSString *cached = [[self cache] objectForKey:imageURL];
    if (cached) {
        completion(cached);
        return;
    }

    NSString *endpoint = [NSString stringWithFormat:@"%@/v9/applications/%@/external-assets", YTMUDiscordAPIBase, applicationID];
    NSData *body = [NSJSONSerialization dataWithJSONObject:@{@"urls": @[imageURL]} options:0 error:nil];
    if (!body) {
        completion(nil);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:endpoint]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = body;
    [request setValue:bearerToken forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:YTMUDiscordUserAgent() forHTTPHeaderField:@"User-Agent"];
    [request setValue:YTMUDiscordSuperPropertiesBase64() forHTTPHeaderField:@"X-Super-Properties"];

    [[[self session] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (error || statusCode < 200 || statusCode > 299 || data.length == 0) {
            completion(nil);
            return;
        }

        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (![json isKindOfClass:[NSArray class]] || json.count == 0) {
            completion(nil);
            return;
        }

        NSDictionary *first = json.firstObject;
        NSString *path = [first isKindOfClass:[NSDictionary class]] ? first[@"external_asset_path"] : nil;
        if (![path isKindOfClass:[NSString class]] || path.length == 0) {
            completion(nil);
            return;
        }

        NSString *assetPath = [@"mp:" stringByAppendingString:path];
        [[self cache] setObject:assetPath forKey:imageURL];

        completion(assetPath);
    }] resume];
}

+ (void)clearCache {
    [[self cache] removeAllObjects];
}

@end
