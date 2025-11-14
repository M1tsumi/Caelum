#import "CLMSelectMenuOption.h"

@implementation CLMSelectMenuOption

+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error {
    CLMSelectMenuOption *opt = [CLMSelectMenuOption new];
    opt.label = json[@"label"] ?: @"";
    opt.value = json[@"value"] ?: @"";
    opt.descriptionText = json[@"description"];
    NSDictionary *emoji = json[@"emoji"];
    if ([emoji isKindOfClass:[NSDictionary class]]) {
        opt.emojiName = emoji[@"name"];
        id eid = emoji[@"id"]; opt.emojiId = [eid isKindOfClass:[NSString class]] ? eid : nil;
        opt.emojiAnimated = [emoji[@"animated"] boolValue];
    }
    opt.defaultSelected = [json[@"default"] boolValue];
    return opt;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *d = [@{ @"label": self.label ?: @"", @"value": self.value ?: @"" } mutableCopy];
    if (self.descriptionText.length) d[@"description"] = self.descriptionText;
    if (self.emojiName.length || self.emojiId.length) {
        NSMutableDictionary *e = [NSMutableDictionary new];
        if (self.emojiName) e[@"name"] = self.emojiName;
        if (self.emojiId) e[@"id"] = self.emojiId;
        if (self.emojiAnimated) e[@"animated"] = @YES;
        d[@"emoji"] = e;
    }
    if (self.defaultSelected) d[@"default"] = @YES;
    return d;
}

@end
