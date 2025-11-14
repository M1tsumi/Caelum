#import <Foundation/Foundation.h>
@protocol CLMTokenProvider;
NS_ASSUME_NONNULL_BEGIN
typedef NS_OPTIONS(NSUInteger, CLMIntents) {
    CLMIntentGuilds = 1 << 0,
    CLMIntentGuildMessages = 1 << 1,
};
@interface CLMGatewayConfiguration : NSObject
@property (nonatomic) CLMIntents intents;
@property (nonatomic) NSUInteger largeThreshold;
@property (nonatomic, strong) NSURL *gatewayURL; // e.g. wss://gateway.discord.gg/?v=10&encoding=json
@property (nonatomic, weak, nullable) id<CLMTokenProvider> tokenProvider;
// Sharding
@property (nonatomic) NSInteger shardId;      // default -1 (unset)
@property (nonatomic) NSInteger shardCount;   // default 0 (unset)
+ (instancetype)defaultConfiguration;
@end
NS_ASSUME_NONNULL_END
