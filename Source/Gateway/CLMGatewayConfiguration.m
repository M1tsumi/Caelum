#import "CLMGatewayConfiguration.h"
@implementation CLMGatewayConfiguration
+ (instancetype)defaultConfiguration {
    CLMGatewayConfiguration *c = [CLMGatewayConfiguration new];
    c.largeThreshold = 50;
    c.intents = 0;
    c.gatewayURL = [NSURL URLWithString:@"wss://gateway.discord.gg/?v=10&encoding=json"];
    return c;
}
@end
