#import "CLMSelectMenu.h"
#import "CLMSelectMenuOption.h"

@implementation CLMSelectMenu

+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error {
    CLMSelectMenu *m = [CLMSelectMenu new];
    m.type = [json[@"type"] integerValue];
    m.customId = json[@"custom_id"] ?: @"";
    m.minValues = [json[@"min_values"] integerValue];
    m.maxValues = [json[@"max_values"] integerValue];
    m.disabled = [json[@"disabled"] boolValue];
    m.placeholder = json[@"placeholder"];
    NSArray *opts = json[@"options"];
    if ([opts isKindOfClass:[NSArray class]]) {
        NSMutableArray *parsed = [NSMutableArray arrayWithCapacity:opts.count];
        for (NSDictionary *o in opts) {
            [parsed addObject:[CLMSelectMenuOption fromJSON:o error:nil]];
        }
        m.options = parsed;
    }
    NSArray *ct = json[@"channel_types"];
    if ([ct isKindOfClass:[NSArray class]]) m.channelTypes = ct;
    return m;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *d = [@{ @"type": @(self.type) } mutableCopy];
    if (self.customId.length) d[@"custom_id"] = self.customId;
    if (self.placeholder.length) d[@"placeholder"] = self.placeholder;
    if (self.minValues) d[@"min_values"] = @(self.minValues);
    if (self.maxValues) d[@"max_values"] = @(self.maxValues);
    if (self.disabled) d[@"disabled"] = @YES;
    if (self.options.count) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.options.count];
        for (CLMSelectMenuOption *o in self.options) { [arr addObject:o.toJSON]; }
        d[@"options"] = arr;
    }
    if (self.channelTypes.count) d[@"channel_types"] = self.channelTypes;
    return d;
}

@end

@implementation CLMSelectMenuBuilder {
    CLMSelectMenu *_menu;
}

- (instancetype)init { if ((self = [super init])) { _menu = [CLMSelectMenu new]; _menu.type = CLMComponentTypeSelectString; _menu.minValues = 0; _menu.maxValues = 1; } return self; }
- (CLMSelectMenu *)menu { return _menu; }
- (instancetype)type:(CLMComponentType)type { _menu.type = type; return self; }
- (instancetype)customId:(NSString *)customId { _menu.customId = [customId copy]; return self; }
- (instancetype)placeholder:(NSString *)placeholder { _menu.placeholder = [placeholder copy]; return self; }
- (instancetype)minValues:(NSInteger)min { _menu.minValues = min; return self; }
- (instancetype)maxValues:(NSInteger)max { _menu.maxValues = max; return self; }
- (instancetype)options:(NSArray<CLMSelectMenuOption *> *)options { _menu.options = [options copy]; return self; }
- (instancetype)channelTypes:(NSArray<NSNumber *> *)types { _menu.channelTypes = [types copy]; return self; }

- (CLMSelectMenu *)build:(NSError **)error {
    if (!_menu.customId.length) {
        if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorInvalidField userInfo:@{NSLocalizedDescriptionKey: @"customId required"}];
        return nil;
    }
    if (_menu.placeholder.length > 150) {
        if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorOutOfRange userInfo:@{NSLocalizedDescriptionKey: @"placeholder too long"}];
        return nil;
    }
    if (_menu.minValues < 0 || _menu.minValues > 25 || _menu.maxValues < 1 || _menu.maxValues > 25 || _menu.minValues > _menu.maxValues) {
        if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorOutOfRange userInfo:@{NSLocalizedDescriptionKey: @"min/max values out of range"}];
        return nil;
    }
    BOOL isString = (_menu.type == CLMComponentTypeSelectString);
    if (isString) {
        if (_menu.options.count < 1 || _menu.options.count > 25) {
            if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorInvalidField userInfo:@{NSLocalizedDescriptionKey: @"string select requires 1-25 options"}];
            return nil;
        }
    } else {
        if (_menu.options.count) {
            if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorInvalidField userInfo:@{NSLocalizedDescriptionKey: @"non-string selects cannot have options"}];
            return nil;
        }
    }
    return _menu;
}

@end
