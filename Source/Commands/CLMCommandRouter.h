#import <Foundation/Foundation.h>
#import "CLMCommand.h"
#import "CLMCommandCooldownManager.h"
#import "CLMCommandPermissionChecker.h"
#import "CLMLogger.h"
@class CLMDiscordRESTClient;
@class CLMDiscordGatewayClient;
@class CLMCommandContext;
NS_ASSUME_NONNULL_BEGIN
typedef BOOL (^CLMCommandMiddleware)(CLMCommandContext *ctx, NSError **error);
@protocol CLMCommandRouterDelegate <NSObject>
@optional
- (void)commandRouterDidHandleCommand:(NSString *)commandName;
- (void)commandRouterDidFailToHandleCommand:(NSString *)commandName error:(NSError *)error;
- (void)commandRouterDidRejectCommand:(NSString *)commandName reason:(NSString *)reason;
@end
@interface CLMCommandRouter : NSObject
@property (nonatomic, strong) CLMCommandCooldownManager *cooldowns;
@property (nonatomic, weak, nullable) id<CLMCommandRouterDelegate> delegate;
@property (nonatomic, strong, nullable) id<CLMLogger> logger;
@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, weak, nullable) id<CLMCommandPermissionChecker> permissionChecker;
- (instancetype)initWithREST:(CLMDiscordRESTClient *)rest gateway:(CLMDiscordGatewayClient *)gateway;
- (void)registerCommand:(id<CLMCommand>)command;
- (nullable id<CLMCommand>)commandNamed:(NSString *)name;
- (void)addMiddleware:(CLMCommandMiddleware)middleware;
- (void)handleMessageCreatePayload:(NSDictionary *)json;
@end
NS_ASSUME_NONNULL_END
