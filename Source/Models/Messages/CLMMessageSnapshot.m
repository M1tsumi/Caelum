#import "CLMMessageSnapshot.h"

@implementation CLMMessageSnapshot

- (NSDictionary *)toEmbedJSON {
    NSMutableArray *fields = [NSMutableArray new];
    if (self.authorName.length) {
        [fields addObject:@{ @"name": @"Author", @"value": self.authorName }];
    }
    if (self.contentExcerpt.length) {
        [fields addObject:@{ @"name": @"Excerpt", @"value": self.contentExcerpt }];
    }
    if (self.jumpURL.length) {
        [fields addObject:@{ @"name": @"Jump", @"value": self.jumpURL }];
    }
    NSMutableDictionary *embed = [NSMutableDictionary new];
    embed[@"title"] = @"Forwarded Message";
    embed[@"fields"] = fields;
    embed[@"footer"] = @{ @"text": [NSString stringWithFormat:@"#%@ in <#%@>", self.messageId ?: @"?", self.channelId ?: @"?"] };
    return embed;
}

@end
