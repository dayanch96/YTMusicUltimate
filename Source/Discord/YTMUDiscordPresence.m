#import "YTMUDiscordPresence.h"

@implementation YTMUDiscordActivity

- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"";
        _type = YTMUDiscordActivityTypeListening;
        _buttons = @[];
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    YTMUDiscordActivity *copy = [[[self class] allocWithZone:zone] init];
    copy.name = self.name;
    copy.type = self.type;
    copy.details = self.details;
    copy.state = self.state;
    copy.largeImage = self.largeImage;
    copy.largeText = self.largeText;
    copy.smallImage = self.smallImage;
    copy.smallText = self.smallText;
    copy.startTimestamp = self.startTimestamp;
    copy.endTimestamp = self.endTimestamp;
    copy.buttons = self.buttons;

    return copy;
}

- (NSDictionary *)JSONObject {
    NSMutableDictionary *activity = [NSMutableDictionary dictionary];
    activity[@"name"] = self.name ?: @"";
    activity[@"type"] = @(self.type);

    if (self.details.length > 0) activity[@"details"] = self.details;
    if (self.state.length > 0) activity[@"state"] = self.state;

    if (self.startTimestamp > 0 || self.endTimestamp > 0) {
        NSMutableDictionary *timestamps = [NSMutableDictionary dictionary];
        if (self.startTimestamp > 0) timestamps[@"start"] = @(self.startTimestamp);
        if (self.endTimestamp > 0) timestamps[@"end"] = @(self.endTimestamp);
        activity[@"timestamps"] = timestamps;
    }

    if (self.largeImage.length > 0 || self.smallImage.length > 0) {
        NSMutableDictionary *assets = [NSMutableDictionary dictionary];
        if (self.largeImage.length > 0) assets[@"large_image"] = self.largeImage;
        if (self.largeText.length > 0) assets[@"large_text"] = self.largeText;
        if (self.smallImage.length > 0) assets[@"small_image"] = self.smallImage;
        if (self.smallText.length > 0) assets[@"small_text"] = self.smallText;
        activity[@"assets"] = assets;
    }

    // Over the gateway `buttons` is a plain array of labels; the matching URLs
    // travel in metadata.button_urls.
    if (self.buttons.count > 0) {
        NSMutableArray<NSString *> *labels = [NSMutableArray array];
        NSMutableArray<NSString *> *urls = [NSMutableArray array];

        for (NSArray<NSString *> *button in self.buttons) {
            if (button.count != 2) continue;
            if (button[0].length == 0 || button[1].length == 0) continue;
            [labels addObject:button[0]];
            [urls addObject:button[1]];
        }

        if (labels.count > 0) {
            activity[@"buttons"] = labels;
            activity[@"metadata"] = @{@"button_urls": urls};
        }
    }

    return activity;
}

@end

@implementation YTMUDiscordPresence

+ (NSString *)presenceUpdateJSONWithActivities:(NSArray<YTMUDiscordActivity *> *)activities
                                        status:(NSString *)status {
    NSMutableArray<NSDictionary *> *serialised = [NSMutableArray array];
    for (YTMUDiscordActivity *activity in activities) {
        [serialised addObject:[activity JSONObject]];
    }

    NSDictionary *frame = @{
        @"op": @(3),
        @"d": @{
            @"since": @(0),
            @"activities": serialised,
            @"status": status.length > 0 ? status : @"online",
            @"afk": @(NO)
        }
    };

    NSData *data = [NSJSONSerialization dataWithJSONObject:frame options:0 error:nil];
    if (!data) return nil;

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
