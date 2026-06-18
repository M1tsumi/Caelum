#import <Foundation/Foundation.h>
@protocol CLMTokenProvider;
NS_ASSUME_NONNULL_BEGIN
typedef NS_OPTIONS(NSUInteger, CLMIntents) {
    CLMIntentGuilds                 = 1 << 0,
    CLMIntentGuildMembers           = 1 << 1,
    CLMIntentGuildModeration        = 1 << 2,
    CLMIntentGuildEmojisAndStickers = 1 << 3,
    CLMIntentGuildIntegrations      = 1 << 4,
    CLMIntentGuildWebhooks          = 1 << 5,
    CLMIntentGuildInvites           = 1 << 6,
    CLMIntentGuildVoiceStates       = 1 << 7,
    CLMIntentGuildPresences         = 1 << 8,
    CLMIntentGuildMessages          = 1 << 9,
    CLMIntentGuildMessageReactions  = 1 << 10,
    CLMIntentGuildMessageTyping     = 1 << 11,
    CLMIntentDirectMessages         = 1 << 12,
    CLMIntentDirectMessageReactions = 1 << 13,
    CLMIntentDirectMessageTyping    = 1 << 14,
    CLMIntentMessageContent         = 1 << 15,
    CLMIntentGuildScheduledEvents   = 1 << 16,
    CLMIntentAutoModConfiguration   = 1 << 20,
    CLMIntentAutoModExecution       = 1 << 21,
    CLMIntentGuildMessagePolls      = 1 << 24,
    CLMIntentDirectMessagePolls     = 1 << 25,
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
