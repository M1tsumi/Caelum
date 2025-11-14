#import "CLMButton.h"

@implementation CLMButton

+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error {
    CLMButton *b = [CLMButton new];
    b.style = [json[@"style"] integerValue];
    b.label = json[@"label"];
    NSDictionary *emoji = json[@"emoji"];
    if ([emoji isKindOfClass:[NSDictionary class]]) {
        b.emojiName = emoji[@"name"]; b.emojiId = emoji[@"id"]; b.emojiAnimated = [emoji[@"animated"] boolValue];
    }
    b.customId = json[@"custom_id"]; b.url = json[@"url"]; b.disabled = [json[@"disabled"] boolValue];
    return b;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *d = [@{ @"type": @(CLMComponentTypeButton), @"style": @(self.style) } mutableCopy];
    if (self.label.length) d[@"label"] = self.label;
    if (self.emojiName.length || self.emojiId.length) {
        NSMutableDictionary *e = [NSMutableDictionary new];
        if (self.emojiName) e[@"name"] = self.emojiName;
        if (self.emojiId) e[@"id"] = self.emojiId;
        if (self.emojiAnimated) e[@"animated"] = @YES;
        d[@"emoji"] = e;
    }
    if (self.style == CLMButtonStyleLink) {
        if (self.url) d[@"url"] = self.url;
    } else {
        if (self.customId) d[@"custom_id"] = self.customId;
    }
    if (self.disabled) d[@"disabled"] = @YES;
    return d;
}

@end
