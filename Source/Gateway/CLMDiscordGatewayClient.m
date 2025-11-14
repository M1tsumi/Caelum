#import "CLMDiscordGatewayClient.h"
#import "CLMWebSocketConnection.h"
#import "CLMRESTConfiguration.h"
#import "Models/Interactions/CLMComponentInteraction.h"

typedef NS_ENUM(NSInteger, CLMGatewayOp) {
    CLMGatewayOpDispatch = 0,
    CLMGatewayOpHeartbeat = 1,
    CLMGatewayOpIdentify = 2,
    CLMGatewayOpHello = 10,
    CLMGatewayOpHeartbeatAck = 11,
};

@interface CLMDiscordGatewayClient () <CLMWebSocketConnectionDelegate>
@property (nonatomic, strong) CLMWebSocketConnection *socket;
@property (nonatomic, strong, nullable) NSTimer *heartbeatTimer;
@property (nonatomic, copy, nullable) NSString *sessionID;
@property (nonatomic, assign) NSInteger lastSequence;
@end

@implementation CLMDiscordGatewayClient {
    CLMGatewayConfiguration *_config;
}

- (instancetype)initWithConfiguration:(CLMGatewayConfiguration *)configuration {
    if ((self=[super init])) {
        _config = configuration;
        _shardId = (_config.shardId >= 0 ? _config.shardId : -1);
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        _socket = [[CLMWebSocketConnection alloc] initWithSessionConfiguration:cfg];
        _socket.delegate = self;
        _lastSequence = -1;
    }
    return self;
}

- (void)connect {
    if (!self.socket) return;
    NSURL *url = _config.gatewayURL ?: [NSURL URLWithString:@"wss://gateway.discord.gg/?v=10&encoding=json"];
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    // No Authorization header for Gateway; token goes in Identify payload
    [self.socket connectWithURL:url headers:headers];
}

- (void)disconnect {
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = nil;
    [self.socket close];
}

#pragma mark - Identify & Heartbeat

- (void)sendIdentify {
    NSString *token = [_config.tokenProvider botToken];
    if (token.length == 0) { return; }
    NSNumber *intents = @(_config.intents);
    NSDictionary *properties = @{ @"os": @"iOS", @"browser": @"Caelum", @"device": @"Caelum" };
    NSMutableDictionary *data = [@{ @"token": token,
                                     @"intents": intents,
                                     @"properties": properties,
                                   } mutableCopy];
    if (_config.shardId >= 0 && _config.shardCount > 0) {
        data[@"shard"] = @[ @(_config.shardId), @(_config.shardCount) ];
    }
    NSDictionary *payload = @{ @"op": @(CLMGatewayOpIdentify), @"d": data };
    [self.socket sendJSONObject:payload];
}

- (void)startHeartbeatWithIntervalMS:(NSInteger)ms {
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:(ms / 1000.0)
                                                          target:self
                                                        selector:@selector(sendHeartbeat)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)sendHeartbeat {
    id seq = (self.lastSequence >= 0) ? @(self.lastSequence) : [NSNull null];
    NSDictionary *payload = @{ @"op": @(CLMGatewayOpHeartbeat), @"d": seq };
    [self.socket sendJSONObject:payload];
}

// Presence Update (OP 3)
- (void)sendPresenceUpdate:(NSDictionary *)presencePayload {
    if (![presencePayload isKindOfClass:[NSDictionary class]]) return;
    NSDictionary *payload = @{ @"op": @3, @"d": presencePayload };
    [self.socket sendJSONObject:payload];
}

// Request Guild Members (OP 8)
- (void)requestGuildMembers:(NSString *)guildId query:(NSString *)query userIDs:(NSArray<NSString *> *)userIDs limit:(NSNumber *)limit presences:(NSNumber *)presences nonce:(NSString *)nonce {
    if (guildId.length == 0) return;
    NSMutableDictionary *d = [@{ @"guild_id": guildId } mutableCopy];
    if (query.length > 0) d[@"query"] = query; // mutually exclusive with user_ids
    if (userIDs.count > 0) d[@"user_ids"] = userIDs;
    if (limit) d[@"limit"] = limit;
    if (presences) d[@"presences"] = presences;
    if (nonce.length > 0) d[@"nonce"] = nonce;
    NSDictionary *payload = @{ @"op": @8, @"d": d };
    [self.socket sendJSONObject:payload];
}

#pragma mark - CLMWebSocketConnectionDelegate

- (void)webSocketDidOpen {
    if ([self.delegate respondsToSelector:@selector(gatewayDidConnect)]) {
        [self.delegate gatewayDidConnect];
    }
    if ([self.delegate respondsToSelector:@selector(gateway:didConnectWithShardId:)]) {
        [self.delegate gateway:self didConnectWithShardId:self.shardId];
    }
}

- (void)webSocketDidCloseWithCode:(NSInteger)code reason:(NSString *)reason {
    if ([self.delegate respondsToSelector:@selector(gatewayDidDisconnectWithError:)]) {
        NSError *err = [NSError errorWithDomain:@"com.caelum.discord" code:code userInfo:@{NSLocalizedDescriptionKey: reason ?: @"Closed"}];
        [self.delegate gatewayDidDisconnectWithError:err];
    }
    if ([self.delegate respondsToSelector:@selector(gateway:didDisconnectWithError:shardId:)]) {
        NSError *err = [NSError errorWithDomain:@"com.caelum.discord" code:code userInfo:@{NSLocalizedDescriptionKey: reason ?: @"Closed"}];
        [self.delegate gateway:self didDisconnectWithError:err shardId:self.shardId];
    }
}

- (void)webSocketDidError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(gatewayDidDisconnectWithError:)]) {
        [self.delegate gatewayDidDisconnectWithError:error];
    }
}

- (void)webSocketDidReceiveJSONObject:(id)json {
    if (![json isKindOfClass:[NSDictionary class]]) return;
    NSDictionary *dict = (NSDictionary *)json;
    NSNumber *opNum = dict[@"op"]; id d = dict[@"d"]; NSNumber *s = dict[@"s"]; NSString *t = dict[@"t"];
    if (s && [s isKindOfClass:[NSNumber class]]) { self.lastSequence = s.integerValue; }

    switch (opNum.integerValue) {
        case CLMGatewayOpHello: {
            NSInteger hb = [d[@"heartbeat_interval"] integerValue];
            [self startHeartbeatWithIntervalMS:hb];
            [self sendIdentify];
        } break;
        case CLMGatewayOpHeartbeatAck: {
            // ACK received; for now we don't track latency
        } break;
        case CLMGatewayOpDispatch: {
            if ([self.delegate respondsToSelector:@selector(gatewayDidReceiveDispatch:payload:)]) {
                [self.delegate gatewayDidReceiveDispatch:(t ?: @"") payload:(d ?: @{})];
            }
            if ([self.delegate respondsToSelector:@selector(gateway:didReceiveDispatch:payload:shardId:)]) {
                [self.delegate gateway:self didReceiveDispatch:(t ?: @"") payload:(d ?: @{}) shardId:self.shardId];
            }
            if ([t isKindOfClass:[NSString class]]) {
                if ([t isEqualToString:@"INTERACTION_CREATE"] || [t isEqualToString:@"MODAL_SUBMIT"]) {
                    if ([d isKindOfClass:[NSDictionary class]]) {
                        CLMComponentInteraction *interaction = [CLMComponentInteraction fromGatewayPayload:(NSDictionary *)d];
                        if ([self.delegate respondsToSelector:@selector(gatewayDidReceiveInteraction:)]) {
                            [self.delegate gatewayDidReceiveInteraction:interaction];
                        }
                    }
                }
                else if ([t isEqualToString:@"GUILD_MEMBERS_CHUNK"]) {
                    if ([d isKindOfClass:[NSDictionary class]] && [self.delegate respondsToSelector:@selector(gatewayDidReceiveGuildMembersChunk:)]) {
                        [self.delegate gatewayDidReceiveGuildMembersChunk:(NSDictionary *)d];
                    }
                }
            }
        } break;
        default: break;
    }
}

@end
