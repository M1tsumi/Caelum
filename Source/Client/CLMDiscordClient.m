#import "CLMDiscordClient.h"
@implementation CLMDiscordClient
- (instancetype)initWithREST:(CLMDiscordRESTClient *)rest gateway:(CLMDiscordGatewayClient *)gateway {
    if ((self=[super init])) { _rest = rest; _gateway = gateway; }
    return self;
}
- (instancetype)initWithConfiguration:(CLMClientConfiguration *)configuration {
    CLMDiscordRESTClient *rest = [[CLMDiscordRESTClient alloc] initWithConfiguration:configuration.restConfiguration];
    CLMDiscordGatewayClient *gateway = [[CLMDiscordGatewayClient alloc] initWithConfiguration:configuration.gatewayConfiguration];
    return [self initWithREST:rest gateway:gateway];
}
@end
