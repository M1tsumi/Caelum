#import "CLMCommandContext.h"
#import "../REST/CLMDiscordRESTClient.h"
#import "../Gateway/CLMDiscordGatewayClient.h"

@implementation CLMCommandContext

- (instancetype)initWithMessageJSON:(NSDictionary *)json
                             content:(NSString *)content
                              guildId:(NSString *)guildId
                            channelId:(NSString *)channelId
                              authorId:(NSString *)authorId
                             arguments:(NSArray<NSString *> *)arguments
                                  rest:(CLMDiscordRESTClient *)rest
                               gateway:(CLMDiscordGatewayClient *)gateway {
    self = [super init];
    if (self) {
        _messageJSON = [json copy];
        _content = [content copy];
        _guildId = [guildId copy];
        _channelId = [channelId copy];
        _authorId = [authorId copy];
        _arguments = [arguments copy];
        _rest = rest;
        _gateway = gateway;
    }
    return self;
}

@end
