#import "CLMShardManager.h"
#import "CLMGatewayConfiguration.h"

@interface CLMShardManager ()
@property (nonatomic, strong) NSArray<CLMDiscordGatewayClient *> *shards;
@property (nonatomic, assign) NSInteger shardCount;
@end

@implementation CLMShardManager

- (instancetype)initWithBaseConfiguration:(CLMGatewayConfiguration *)baseConfig shardCount:(NSInteger)shardCount {
    if ((self = [super init])) {
        _shardCount = MAX(1, shardCount);
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:_shardCount];
        for (NSInteger i = 0; i < _shardCount; i++) {
            CLMGatewayConfiguration *cfg = [CLMGatewayConfiguration defaultConfiguration];
            cfg.intents = baseConfig.intents;
            cfg.largeThreshold = baseConfig.largeThreshold;
            cfg.gatewayURL = baseConfig.gatewayURL;
            cfg.tokenProvider = baseConfig.tokenProvider;
            cfg.shardId = i;
            cfg.shardCount = _shardCount;
            CLMDiscordGatewayClient *client = [[CLMDiscordGatewayClient alloc] initWithConfiguration:cfg];
            client.delegate = self;
            [arr addObject:client];
        }
        _shards = [arr copy];
    }
    return self;
}

- (void)startAll {
    for (CLMDiscordGatewayClient *c in self.shards) { [c connect]; }
}

- (void)stopAll {
    for (CLMDiscordGatewayClient *c in self.shards) { [c disconnect]; }
}

- (nullable CLMDiscordGatewayClient *)clientForGuildId:(NSString *)guildId {
    if (guildId.length == 0 || self.shardCount <= 0) return self.shards.firstObject;
    // Hash by snowflake to 64-bit then modulo shardCount
    unsigned long long gid = strtoull(guildId.UTF8String, NULL, 10);
    NSInteger idx = (NSInteger)(gid % (unsigned long long)self.shardCount);
    if (idx < 0 || idx >= self.shards.count) return self.shards.firstObject;
    return self.shards[idx];
}

#pragma mark - CLMGatewayEventDelegate

- (void)gatewayDidConnect {
    // Not shard-specific here; optionally notify for each shard connection
}

- (void)gatewayDidDisconnectWithError:(NSError *)error {
    // Not shard-specific here
}

- (void)gatewayDidReceiveDispatch:(NSString *)eventName payload:(id)payload {
    // We cannot know shardId directly from callback; if needed, extend CLMDiscordGatewayClient to expose shard id
    if ([self.delegate respondsToSelector:@selector(shardManagerDidReceiveDispatchOnShard:event:payload:)]) {
        // Best-effort: pass -1 as shard id unless client exposes it
        [self.delegate shardManagerDidReceiveDispatchOnShard:-1 event:eventName payload:payload];
    }
}

@end
