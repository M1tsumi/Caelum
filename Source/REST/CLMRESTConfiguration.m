#import "CLMRESTConfiguration.h"

@interface CLMStaticTokenProvider : NSObject <CLMTokenProvider>
@property (nonatomic, copy) NSString *token;
@end
@implementation CLMStaticTokenProvider
- (NSString *)botToken { return self.token; }
@end

@implementation CLMRESTConfiguration
+ (instancetype)defaultConfiguration {
    CLMRESTConfiguration *c = [CLMRESTConfiguration new];
    c.baseURL = [NSURL URLWithString:@"https://discord.com/api/v10/"];
    c.timeout = 30.0;
    return c;
}
- (void)setBotToken:(NSString *)botToken {
    if (botToken.length > 0) {
        CLMStaticTokenProvider *p = [CLMStaticTokenProvider new];
        p.token = [botToken copy];
        self.tokenProvider = p;
    }
}
- (NSString *)botToken {
    return [self.tokenProvider botToken];
}
@end
