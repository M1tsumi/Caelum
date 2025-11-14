#import "CLMApplicationEmoji.h"

@implementation CLMApplicationEmoji

+ (instancetype)fromJSON:(NSDictionary *)json {
    CLMApplicationEmoji *e = [CLMApplicationEmoji new];
    e.emojiId = [json[@"id"] description] ?: @"";
    e.name = json[@"name"] ?: @"";
    e.requiresColons = [json[@"require_colons"] boolValue];
    e.managed = [json[@"managed"] boolValue];
    e.animated = [json[@"animated"] boolValue];
    return e;
}

- (NSDictionary *)toJSONCreateWithImageDataURI:(NSString *)imageDataURI {
    NSMutableDictionary *d = [NSMutableDictionary new];
    if (self.name.length) d[@"name"] = self.name;
    if (imageDataURI.length) d[@"image"] = imageDataURI; // data URI: data:image/png;base64,...
    return d;
}

- (NSDictionary *)toJSONPatch {
    NSMutableDictionary *d = [NSMutableDictionary new];
    if (self.name.length) d[@"name"] = self.name;
    return d;
}

@end
