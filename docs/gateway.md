# Gateway

**Class:** `CLMDiscordGatewayClient`  
**Header:** `Gateway/CLMDiscordGatewayClient.h`

Handles the Discord Gateway v10 WebSocket connection, heartbeat, session management, and event dispatch.

## Configuration

```objc
@interface CLMGatewayConfiguration : NSObject
@property (nonatomic) CLMIntents intents;
@property (nonatomic) NSUInteger largeThreshold;
@property (nonatomic, strong) NSURL *gatewayURL;   // e.g. wss://gateway.discord.gg/?v=10&encoding=json
@property (nonatomic, weak) id<CLMTokenProvider> tokenProvider;
@property (nonatomic) NSInteger shardId;           // default -1 (unset)
@property (nonatomic) NSInteger shardCount;        // default 0 (unset)
@end
```

### Intents

```objc
typedef NS_OPTIONS(NSUInteger, CLMIntents) {
    CLMIntentGuilds                 = 1 << 0,
    CLMIntentGuildMembers           = 1 << 1,  // privileged
    CLMIntentGuildModeration        = 1 << 2,
    CLMIntentGuildEmojisAndStickers = 1 << 3,
    CLMIntentGuildIntegrations      = 1 << 4,
    CLMIntentGuildWebhooks          = 1 << 5,
    CLMIntentGuildInvites           = 1 << 6,
    CLMIntentGuildVoiceStates       = 1 << 7,
    CLMIntentGuildPresences         = 1 << 8,  // privileged
    CLMIntentGuildMessages          = 1 << 9,
    CLMIntentGuildMessageReactions  = 1 << 10,
    CLMIntentGuildMessageTyping     = 1 << 11,
    CLMIntentDirectMessages         = 1 << 12,
    CLMIntentDirectMessageReactions = 1 << 13,
    CLMIntentDirectMessageTyping    = 1 << 14,
    CLMIntentMessageContent         = 1 << 15, // privileged
    CLMIntentGuildScheduledEvents   = 1 << 16,
    CLMIntentAutoModConfiguration   = 1 << 20,
    CLMIntentAutoModExecution       = 1 << 21,
    CLMIntentGuildMessagePolls      = 1 << 24,
    CLMIntentDirectMessagePolls     = 1 << 25,
};
```

## Basic Usage

```objc
CLMGatewayConfiguration *cfg = [CLMGatewayConfiguration defaultConfiguration];
cfg.tokenProvider = myProvider;
cfg.intents = CLMIntentGuilds | CLMIntentGuildMessages;

CLMDiscordGatewayClient *gateway = [[CLMDiscordGatewayClient alloc] initWithConfiguration:cfg];
gateway.delegate = self;
gateway.reconnectDelay = 2.0; // seconds between reconnect attempts (default: 1.0)
[gateway connect];
```

## Connection Lifecycle

- `connect` -- Opens WebSocket and sends Identify (or Resume if session exists)
- `disconnect` -- Closes WebSocket and stops heartbeat
- Automatic reconnect on disconnect (controlled by `shouldReconnect` flag)
- Automatic resume on Hello if `sessionID` and `lastSequence` are available
- Invalid Session handling with jitter (1-4s) before re-identify

## Delegate

```objc
@protocol CLMGatewayEventDelegate <NSObject>
@optional
- (void)gatewayDidConnect;
- (void)gatewayDidDisconnectWithError:(NSError *)error;
- (void)gatewayDidReceiveDispatch:(NSString *)eventName payload:(id)payload;
- (void)gatewayDidReceiveInteraction:(CLMComponentInteraction *)interaction;
- (void)gatewayDidReceiveGuildMembersChunk:(NSDictionary *)payload;

// Shard-aware variants
- (void)gateway:(id)sender didConnectWithShardId:(NSInteger)shardId;
- (void)gateway:(id)sender didDisconnectWithError:(NSError *)error shardId:(NSInteger)shardId;
- (void)gateway:(id)sender didReceiveDispatch:(NSString *)eventName payload:(id)payload shardId:(NSInteger)shardId;
@end
```

Dispatch events are also posted to `[CLMEventCenter shared]`, so you can use block-based listeners as an alternative.

## Sending Data

```objc
- (void)sendPresenceUpdate:(NSDictionary *)presencePayload;     // OP 3
- (void)requestGuildMembers:(NSString *)guildId
                      query:(NSString *)query
                    userIDs:(NSArray<NSString *> *)userIDs
                      limit:(NSNumber *)limit
                  presences:(NSNumber *)presences
                      nonce:(NSString *)nonce;                    // OP 8
```

## Sharding

```objc
@interface CLMShardManager : NSObject
@property (nonatomic, weak) id<CLMShardManagerDelegate> delegate;
@property (nonatomic, copy, readonly) NSArray<CLMDiscordGatewayClient *> *shards;

- (instancetype)initWithBaseConfiguration:(CLMGatewayConfiguration *)baseConfig
                               shardCount:(NSInteger)shardCount;
- (void)startAll;
- (void)stopAll;
- (CLMDiscordGatewayClient *)clientForGuildId:(NSString *)guildId;
@end
```

ShardManager creates N gateway clients, each with a unique `shardId`. It routes events through a `CLMShardManagerDelegate` that includes the shard ID.
