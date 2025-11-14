#import <Foundation/Foundation.h>
#import "CLMCommand.h"
#import "CLMCommandPermissionChecker.h"

@class CLMDiscordRESTClient, CLMDiscordGatewayClient, CLMCommandCooldownManager, CLMCommandContext;

NS_ASSUME_NONNULL_BEGIN

@interface CLMCommandRouter : NSObject
@property (nonatomic, copy) NSString *prefix; // e.g., "!"
@property (nonatomic, strong, readonly) CLMCommandCooldownManager *cooldowns;
@property (nonatomic, weak, nullable) id<CLMCommandPermissionChecker> permissionChecker;

- (instancetype)initWithREST:(CLMDiscordRESTClient *)rest gateway:(nullable CLMDiscordGatewayClient *)gateway;

- (void)registerCommand:(id<CLMCommand>)command;
- (nullable id<CLMCommand>)commandNamed:(NSString *)name;
- (void)addMiddleware:(CLMCommandMiddleware)middleware; // returns BOOL to continue

// Call from MESSAGE_CREATE dispatch
- (void)handleMessageCreatePayload:(NSDictionary *)json;
@end

NS_ASSUME_NONNULL_END
