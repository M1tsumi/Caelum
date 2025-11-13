#import <Foundation/Foundation.h>
#import "CLMDiscordRESTClient.h"
#import "CLMDiscordGatewayClient.h"
#import "CLMClientConfiguration.h"
NS_ASSUME_NONNULL_BEGIN
@interface CLMDiscordClient : NSObject
@property (nonatomic, strong, readonly) CLMDiscordRESTClient *rest;
@property (nonatomic, strong, readonly) CLMDiscordGatewayClient *gateway;
- (instancetype)initWithREST:(CLMDiscordRESTClient *)rest gateway:(CLMDiscordGatewayClient *)gateway;
- (instancetype)initWithConfiguration:(CLMClientConfiguration *)configuration;
@end
NS_ASSUME_NONNULL_END
