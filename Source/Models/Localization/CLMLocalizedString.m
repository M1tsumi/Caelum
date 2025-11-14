#import "CLMLocalizedString.h"

@implementation CLMLocalizedString
+ (instancetype)localizedWithBase:(NSString *)base localizations:(NSDictionary<NSString *,NSString *> *)localizations {
    CLMLocalizedString *ls = [CLMLocalizedString new];
    ls.base = base ?: @"";
    ls.localizations = localizations ?: @{};
    return ls;
}
- (NSDictionary *)toJSONDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.localizations ?: @{}];
    // Discord expects only localization map here; base string is provided separately in name/description
    // Filter out empty strings
    NSArray *keys = [dict allKeys];
    for (NSString *k in keys) {
        NSString *v = dict[k];
        if (![v isKindOfClass:[NSString class]] || v.length == 0) { [dict removeObjectForKey:k]; }
    }
    return dict;
}
@end
