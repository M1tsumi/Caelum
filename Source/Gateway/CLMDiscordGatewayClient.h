#import <Foundation/Foundation.h>
#import "CLMGatewayConfiguration.h"
@class CLMWebSocketConnection;
@class CLMComponentInteraction;
NS_ASSUME_NONNULL_BEGIN
@protocol CLMGatewayEventDelegate <NSObject>
@optional
- (void)gatewayDidConnect;
- (void)gatewayDidDisconnectWithError:(nullable NSError *)error;
- (void)gatewayDidReceiveDispatch:(NSString *)eventName payload:(id)payload;
// Typed events (optional)
- (void)gatewayDidReceiveInteraction:(CLMComponentInteraction *)interaction;
// Guild member chunking
- (void)gatewayDidReceiveGuildMembersChunk:(NSDictionary *)payload; // raw GUILD_MEMBERS_CHUNK
// Shard-aware optional variants (non-breaking; client calls both old and new)
- (void)gateway:(id)sender didConnectWithShardId:(NSInteger)shardId;
- (void)gateway:(id)sender didDisconnectWithError:(nullable NSError *)error shardId:(NSInteger)shardId;
- (void)gateway:(id)sender didReceiveDispatch:(NSString *)eventName payload:(id)payload shardId:(NSInteger)shardId;
@end
@interface CLMDiscordGatewayClient : NSObject
@property (nonatomic, weak, nullable) id<CLMGatewayEventDelegate> delegate;
@property (nonatomic, assign, readonly) NSInteger shardId; // -1 if unset
- (instancetype)initWithConfiguration:(CLMGatewayConfiguration *)configuration;
- (void)connect;
- (void)disconnect;
// Presence Update (OP 3): pass presence payload dictionary {status, activities, afk, since}
- (void)sendPresenceUpdate:(NSDictionary *)presencePayload;
// Request Guild Members (OP 8)
- (void)requestGuildMembers:(NSString *)guildId query:(nullable NSString *)query userIDs:(nullable NSArray<NSString *> *)userIDs limit:(nullable NSNumber *)limit presences:(nullable NSNumber *)presences nonce:(nullable NSString *)nonce;
@end
NS_ASSUME_NONNULL_END
