#import <Foundation/Foundation.h>

// Integration types for application commands installation contexts
// See Discord docs: application command installation context

typedef NS_ENUM(NSInteger, CLMApplicationIntegrationType) {
    CLMApplicationIntegrationTypeGuildInstall = 0,
    CLMApplicationIntegrationTypeUserInstall = 1,
};

typedef NS_OPTIONS(NSUInteger, CLMCommandContextType) {
    CLMCommandContextGuild = 1 << 0,
    CLMCommandContextBotDM = 1 << 1,
    CLMCommandContextPrivateChannel = 1 << 2,
};

@interface CLMApplicationInstallUtils : NSObject
// Adds installation fields to an application command JSON payload (create/edit)
+ (NSMutableDictionary *)applyInstallFieldsToCommandJSON:(NSDictionary *)commandJSON
                                       integrationTypes:(NSArray<NSNumber *> *)integrationTypes
                                                contexts:(NSArray<NSNumber *> *)contexts;
@end
