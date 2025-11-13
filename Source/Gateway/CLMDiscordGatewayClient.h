#import <Foundation/Foundation.h>
#import "CLMGatewayConfiguration.h"
@class CLMWebSocketConnection;
NS_ASSUME_NONNULL_BEGIN
@protocol CLMGatewayEventDelegate <NSObject>
@optional
- (void)gatewayDidConnect;
- (void)gatewayDidDisconnectWithError:(nullable NSError *)error;
- (void)gatewayDidReceiveDispatch:(NSString *)eventName payload:(id)payload;
@end
@interface CLMDiscordGatewayClient : NSObject
@property (nonatomic, weak, nullable) id<CLMGatewayEventDelegate> delegate;
- (instancetype)initWithConfiguration:(CLMGatewayConfiguration *)configuration;
- (void)connect;
- (void)disconnect;
@end
NS_ASSUME_NONNULL_END
