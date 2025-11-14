#import "CLMTextInput.h"

@implementation CLMTextInput

+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error {
    CLMTextInput *ti = [CLMTextInput new];
    ti.customId = json[@"custom_id"] ?: @"";
    ti.style = [json[@"style"] integerValue];
    ti.label = json[@"label"] ?: @"";
    ti.minLength = [json[@"min_length"] integerValue];
    ti.maxLength = [json[@"max_length"] integerValue];
    ti.required = [json[@"required"] boolValue];
    ti.value = json[@"value"];
    ti.placeholder = json[@"placeholder"];
    return ti;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *d = [@{ @"type": @(CLMComponentTypeTextInput),
                                 @"custom_id": self.customId ?: @"",
                                 @"style": @(self.style),
                                 @"label": self.label ?: @"" } mutableCopy];
    if (self.minLength > 0) d[@"min_length"] = @(self.minLength);
    if (self.maxLength > 0) d[@"max_length"] = @(self.maxLength);
    if (self.isRequired) d[@"required"] = @YES;
    if (self.value.length) d[@"value"] = self.value;
    if (self.placeholder.length) d[@"placeholder"] = self.placeholder;
    return d;
}

@end
