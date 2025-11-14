#import <Foundation/Foundation.h>

@class CLMDiscordRESTClient;
@class CLMDiscordGatewayClient;

NS_ASSUME_NONNULL_BEGIN

@interface CLMCommandContext : NSObject
@property (nonatomic, strong, readonly) NSDictionary *messageJSON;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy, readonly, nullable) NSString *guildId;
@property (nonatomic, copy, readonly) NSString *channelId;
@property (nonatomic, copy, readonly) NSString *authorId;
@property (nonatomic, copy, readonly) NSArray<NSString *> *arguments;
@property (nonatomic, strong, readonly) CLMDiscordRESTClient *rest;
@property (nonatomic, strong, readonly, nullable) CLMDiscordGatewayClient *gateway;

- (instancetype)initWithMessageJSON:(NSDictionary *)json
                             content:(NSString *)content
                              guildId:(nullable NSString *)guildId
                            channelId:(NSString *)channelId
                              authorId:(NSString *)authorId
                             arguments:(NSArray<NSString *> *)arguments
                                  rest:(CLMDiscordRESTClient *)rest
                               gateway:(nullable CLMDiscordGatewayClient *)gateway NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
