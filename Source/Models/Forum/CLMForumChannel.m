#import "CLMForumChannel.h"
#import "CLMForumTag.h"

@implementation CLMForumChannel
+ (instancetype)fromJSON:(NSDictionary *)json {
    CLMForumChannel *c = [CLMForumChannel new];
    c.channelId = [json[@"id"] description] ?: @"";
    NSArray *tags = json[@"available_tags"];
    if ([tags isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[tags count]];
        for (NSDictionary *t in tags) { [arr addObject:[CLMForumTag fromJSON:t]]; }
        c.availableTags = arr;
    }
    NSDictionary *dre = json[@"default_reaction_emoji"];
    if ([dre isKindOfClass:[NSDictionary class]]) {
        c.defaultReactionEmojiId = [dre[@"emoji_id"] description];
        c.defaultReactionEmojiName = dre[@"emoji_name"];
    }
    if (json[@"default_sort_order"] != nil) c.defaultSortOrder = [json[@"default_sort_order"] integerValue];
    if (json[@"default_forum_layout"] != nil) c.defaultLayout = [json[@"default_forum_layout"] integerValue];
    if (json[@"default_thread_rate_limit_per_user"]) c.defaultThreadRateLimitPerUser = json[@"default_thread_rate_limit_per_user"];
    return c;
}

- (NSDictionary *)toJSONPatch {
    NSMutableDictionary *d = [NSMutableDictionary new];
    if (self.availableTags) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.availableTags.count];
        for (CLMForumTag *t in self.availableTags) { [arr addObject:[t toJSON]]; }
        d[@"available_tags"] = arr;
    }
    if (self.defaultReactionEmojiId.length || self.defaultReactionEmojiName.length) {
        NSMutableDictionary *dre = [NSMutableDictionary new];
        if (self.defaultReactionEmojiId) dre[@"emoji_id"] = self.defaultReactionEmojiId;
        if (self.defaultReactionEmojiName) dre[@"emoji_name"] = self.defaultReactionEmojiName;
        d[@"default_reaction_emoji"] = dre;
    }
    d[@"default_sort_order"] = @(self.defaultSortOrder);
    d[@"default_forum_layout"] = @(self.defaultLayout);
    if (self.defaultThreadRateLimitPerUser) d[@"default_thread_rate_limit_per_user"] = self.defaultThreadRateLimitPerUser;
    return d;
}
@end
