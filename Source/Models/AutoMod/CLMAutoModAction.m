#import "CLMAutoModAction.h"

@implementation CLMAutoModAction

+ (instancetype)fromJSON:(NSDictionary *)json {
    CLMAutoModAction *a = [CLMAutoModAction new];
    a.type = [json[@"type"] integerValue];
    NSDictionary *md = json[@"metadata"];
    if ([md isKindOfClass:[NSDictionary class]]) {
        a.customMessage = md[@"custom_message"];
        a.channelId = [md[@"channel_id"] description];
        if (md[@"duration_seconds"]) a.durationSeconds = md[@"duration_seconds"];
    }
    return a;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *d = [@{ @"type": @(self.type) } mutableCopy];
    NSMutableDictionary *md = [NSMutableDictionary new];
    if (self.customMessage.length) md[@"custom_message"] = self.customMessage;
    if (self.channelId.length) md[@"channel_id"] = self.channelId;
    if (self.durationSeconds) md[@"duration_seconds"] = self.durationSeconds;
    if (md.count) d[@"metadata"] = md;
    return d;
}

@end
