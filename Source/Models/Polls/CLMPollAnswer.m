#import "CLMPollAnswer.h"

@implementation CLMPollAnswer
+ (instancetype)fromJSON:(NSDictionary *)json {
    CLMPollAnswer *a = [CLMPollAnswer new];
    a.answerId = [json[@"id"] description] ?: @"";
    a.text = json[@"text"];
    NSDictionary *emoji = json[@"emoji"];
    if ([emoji isKindOfClass:[NSDictionary class]]) {
        a.emojiName = emoji[@"name"]; a.emojiId = [emoji[@"id"] description]; a.emojiAnimated = [emoji[@"animated"] boolValue];
    }
    return a;
}
- (NSDictionary *)toJSON {
    NSMutableDictionary *d = [NSMutableDictionary new];
    if (self.answerId.length) d[@"id"] = self.answerId;
    if (self.text.length) d[@"text"] = self.text;
    if (self.emojiName.length || self.emojiId.length) {
        NSMutableDictionary *e = [NSMutableDictionary new];
        if (self.emojiName) e[@"name"] = self.emojiName;
        if (self.emojiId) e[@"id"] = self.emojiId;
        if (self.emojiAnimated) e[@"animated"] = @YES;
        d[@"emoji"] = e;
    }
    return d;
}
@end
