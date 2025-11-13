#import "CLMRESTConfiguration.h"
@implementation CLMRESTConfiguration
+ (instancetype)defaultConfiguration {
    CLMRESTConfiguration *c = [CLMRESTConfiguration new];
    c.baseURL = [NSURL URLWithString:@"https://discord.com/api/v10/"];
    c.timeout = 30.0;
    return c;
}
@end
