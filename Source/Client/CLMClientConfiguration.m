#import "CLMClientConfiguration.h"
@implementation CLMClientConfiguration
+ (instancetype)defaultConfiguration {
    CLMClientConfiguration *c = [CLMClientConfiguration new];
    c.restConfiguration = [CLMRESTConfiguration defaultConfiguration];
    c.gatewayConfiguration = [CLMGatewayConfiguration defaultConfiguration];
    return c;
}
@end
