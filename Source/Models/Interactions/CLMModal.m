#import "CLMModal.h"
#import "Models/Components/CLMComponents.h"

@implementation CLMModal

+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error {
    CLMModal *m = [CLMModal new];
    m.customId = json[@"custom_id"] ?: @"";
    m.title = json[@"title"] ?: @"";
    NSArray *rows = json[@"components"];
    if ([rows isKindOfClass:[NSArray class]]) {
        NSMutableArray *parsed = [NSMutableArray arrayWithCapacity:rows.count];
        for (NSDictionary *r in rows) {
            NSError *rowErr = nil;
            CLMActionRow *row = [CLMActionRow fromJSON:r error:&rowErr];
            if (row) [parsed addObject:row];
        }
        m.components = parsed;
    } else {
        m.components = @[];
    }
    return m;
}

- (NSDictionary *)toJSON {
    NSMutableArray *rows = [NSMutableArray arrayWithCapacity:self.components.count];
    for (CLMActionRow *row in self.components) { [rows addObject:[row toJSON]]; }
    return @{ @"custom_id": self.customId ?: @"",
              @"title": self.title ?: @"",
              @"components": rows };
}

@end

@implementation CLMModalBuilder {
    NSString *_customId; NSString *_title; NSMutableArray<CLMActionRow *> *_rows;
}

- (instancetype)init { if ((self = [super init])) { _rows = [NSMutableArray new]; } return self; }
- (instancetype)customId:(NSString *)customId { _customId = [customId copy]; return self; }
- (instancetype)title:(NSString *)title { _title = [title copy]; return self; }
- (instancetype)addTextInput:(CLMTextInput *)textInput {
    CLMActionRow *row = [CLMActionRow new];
    row.components = @[textInput ?: [NSNull null]];
    [_rows addObject:row];
    return self;
}
- (CLMModal *)build:(NSError **)error {
    if (_customId.length == 0) {
        if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorInvalidField userInfo:@{NSLocalizedDescriptionKey: @"modal customId required"}];
        return nil;
    }
    if (_title.length < 1 || _title.length > 45) {
        if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorOutOfRange userInfo:@{NSLocalizedDescriptionKey: @"modal title must be 1-45 chars"}];
        return nil;
    }
    // Validate rows: each must contain exactly one CLMTextInput
    for (CLMActionRow *row in _rows) {
        NSError *rowErr = [CLMActionRow validateComponents:row.components];
        if (rowErr) { if (error) *error = rowErr; return nil; }
        if (row.components.count != 1 || ![row.components.firstObject isKindOfClass:[CLMTextInput class]]) {
            if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorInvalidLayout userInfo:@{NSLocalizedDescriptionKey: @"each modal row must contain exactly one text input"}];
            return nil;
        }
        // Validate text input constraints
        CLMTextInput *ti = (CLMTextInput *)row.components.firstObject;
        if (ti.label.length < 1 || ti.label.length > 45) {
            if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorOutOfRange userInfo:@{NSLocalizedDescriptionKey: @"text input label must be 1-45 chars"}];
            return nil;
        }
        if (ti.minLength < 0 || ti.minLength > 4000 || ti.maxLength < 1 || ti.maxLength > 4000 || ti.minLength > ti.maxLength) {
            if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorOutOfRange userInfo:@{NSLocalizedDescriptionKey: @"text input min/max invalid"}];
            return nil;
        }
        if (ti.value.length > 4000) {
            if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorOutOfRange userInfo:@{NSLocalizedDescriptionKey: @"text input value too long"}];
            return nil;
        }
        if (ti.placeholder.length > 100) {
            if (error) *error = [NSError errorWithDomain:CLMComponentsErrorDomain code:CLMComponentsErrorOutOfRange userInfo:@{NSLocalizedDescriptionKey: @"text input placeholder too long"}];
            return nil;
        }
    }
    CLMModal *m = [CLMModal new];
    m.customId = _customId; m.title = _title; m.components = [_rows copy];
    return m;
}

@end
