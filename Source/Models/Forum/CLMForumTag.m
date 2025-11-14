#import "CLMForumTag.h"

@implementation CLMForumTag
+ (instancetype)fromJSON:(NSDictionary *)json {
    CLMForumTag *t = [CLMForumTag new];
    t.tagId = [json[@"id"] description] ?: @"";
    t.name = json[@"name"] ?: @"";
    t.moderated = [json[@"moderated"] boolValue];
    t.emojiId = [json[@"emoji_id"] description];
    t.emojiName = json[@"emoji_name"];
    return t;
}
- (NSDictionary *)toJSON {
    NSMutableDictionary *d = [NSMutableDictionary new];
    if (self.tagId.length) d[@"id"] = self.tagId;
    if (self.name.length) d[@"name"] = self.name;
    if (self.moderated) d[@"moderated"] = @YES;
    if (self.emojiId.length) d[@"emoji_id"] = self.emojiId;
    if (self.emojiName.length) d[@"emoji_name"] = self.emojiName;
    return d;
}
@end
