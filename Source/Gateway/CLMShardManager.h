#import <Foundation/Foundation.h>
#import "CLMDiscordGatewayClient.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CLMShardManagerDelegate <NSObject>
@optional
- (void)shardManagerDidConnectShard:(NSInteger)shardId;
- (void)shardManagerDidDisconnectShard:(NSInteger)shardId error:(nullable NSError *)error;
- (void)shardManagerDidReceiveDispatchOnShard:(NSInteger)shardId event:(NSString *)event payload:(id)payload;
@end

@interface CLMShardManager : NSObject <CLMGatewayEventDelegate>
@property (nonatomic, weak, nullable) id<CLMShardManagerDelegate> delegate;
@property (nonatomic, copy, readonly) NSArray<CLMDiscordGatewayClient *> *shards;
@property (nonatomic, assign, readonly) NSInteger shardCount;
- (instancetype)initWithBaseConfiguration:(CLMGatewayConfiguration *)baseConfig shardCount:(NSInteger)shardCount;
- (void)startAll;
- (void)stopAll;
- (nullable CLMDiscordGatewayClient *)clientForGuildId:(NSString *)guildId;
@end

NS_ASSUME_NONNULL_END
