#import "CLMActionRow.h"
#import "CLMButton.h"
#import "CLMSelectMenu.h"
#import "CLMTextInput.h"

@implementation CLMActionRow

+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error {
    CLMActionRow *row = [CLMActionRow new];
    NSArray *arr = json[@"components"];
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *c in arr) {
        NSInteger type = [c[@"type"] integerValue];
        if (type == CLMComponentTypeButton) {
            [result addObject:[CLMButton fromJSON:c error:nil]];
        } else if (type == CLMComponentTypeSelectString || type == CLMComponentTypeSelectUser || type == CLMComponentTypeSelectRole || type == CLMComponentTypeSelectMentionable || type == CLMComponentTypeSelectChannel) {
            [result addObject:[CLMSelectMenu fromJSON:c error:nil]];
        } else if (type == CLMComponentTypeTextInput) {
            [result addObject:[CLMTextInput fromJSON:c error:nil]];
        }
    }
    row.components = result;
    return row;
}

- (NSDictionary *)toJSON {
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.components.count];
    for (id c in self.components) {
        if ([c isKindOfClass:[CLMButton class]]) {
            [arr addObject:[(CLMButton *)c toJSON]];
        } else if ([c isKindOfClass:[CLMSelectMenu class]]) {
            [arr addObject:[(CLMSelectMenu *)c toJSON]];
        } else if ([c isKindOfClass:[CLMTextInput class]]) {
            [arr addObject:[(CLMTextInput *)c toJSON]];
        }
    }
    return @{ @"type": @(CLMComponentTypeActionRow), @"components": arr };
}

+ (NSError *)validateComponents:(NSArray *)components {
    if (components.count == 0 || components.count > 5) {
        return [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorInvalidLayout userInfo:@{NSLocalizedDescriptionKey: @"action row must have 1-5 components"}];
    }
    BOOL hasSelect = NO; BOOL hasButton = NO; BOOL hasTextInput = NO;
    for (id c in components) {
        if ([c isKindOfClass:[CLMSelectMenu class]]) hasSelect = YES;
        if ([c isKindOfClass:[CLMButton class]]) hasButton = YES;
        if ([c isKindOfClass:[CLMTextInput class]]) hasTextInput = YES;
    }
    if ((hasSelect && hasButton) || (hasTextInput && hasButton) || (hasTextInput && hasSelect)) {
        return [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorInvalidLayout userInfo:@{NSLocalizedDescriptionKey: @"select menu must be alone in a row"}];
    }
    if ((hasSelect && components.count != 1) || (hasTextInput && components.count != 1)) {
        return [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorInvalidLayout userInfo:@{NSLocalizedDescriptionKey: @"select row must have exactly one component"}];
    }
    return nil;
}

@end
