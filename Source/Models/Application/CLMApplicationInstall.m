#import "CLMApplicationInstall.h"

@implementation CLMApplicationInstallUtils
+ (NSMutableDictionary *)applyInstallFieldsToCommandJSON:(NSDictionary *)commandJSON
                                       integrationTypes:(NSArray<NSNumber *> *)integrationTypes
                                                contexts:(NSArray<NSNumber *> *)contexts {
    NSMutableDictionary *json = [NSMutableDictionary dictionaryWithDictionary:commandJSON ?: @{}];
    if (integrationTypes.count > 0) {
        json[@"integration_types"] = integrationTypes;
    }
    if (contexts.count > 0) {
        json[@"contexts"] = contexts; // Discord expects specific numeric set; caller maps from CLMCommandContextType
    }
    return json;
}
@end
