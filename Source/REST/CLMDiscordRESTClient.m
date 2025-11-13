#import "CLMDiscordRESTClient.h"

@implementation CLMDiscordRESTClient {
    NSURLSession *_session;
}

- (instancetype)initWithConfiguration:(CLMRESTConfiguration *)configuration {
    if ((self = [super init])) {
        _configuration = configuration;
        NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        cfg.timeoutIntervalForRequest = configuration.timeout;
        _session = [NSURLSession sessionWithConfiguration:cfg];
        _session = _session; // explicitly retain
    }
    return self;
}

- (NSURLSession *)session { return _session; }

- (void)performRequest:(CLMRESTRequest *)request completion:(CLMRESTCompletion)completion {
    // Build URL
    NSURL *url = [NSURL URLWithString:request.route relativeToURL:self.configuration.baseURL];
    if (!url) {
        CLMRESTResponse *resp = [CLMRESTResponse new];
        resp.error = [NSError errorWithDomain:@"com.caelum.discord"
                                         code:-1
                                     userInfo:@{NSLocalizedDescriptionKey: @"Invalid URL"}];
        if (completion) completion(resp);
        return;
    }

    // Request
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    urlRequest.HTTPMethod = request.method ?: @"GET";
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *token = [self.configuration.tokenProvider botToken];
    if (token.length > 0) {
        [urlRequest setValue:[NSString stringWithFormat:@"Bot %@", token] forHTTPHeaderField:@"Authorization"];
    }

    if (request.jsonBody) {
        NSError *encodeError = nil;
        NSData *body = [NSJSONSerialization dataWithJSONObject:request.jsonBody options:0 error:&encodeError];
        if (encodeError) {
            CLMRESTResponse *resp = [CLMRESTResponse new];
            resp.error = encodeError;
            if (completion) completion(resp);
            return;
        }
        urlRequest.HTTPBody = body;
    }

    NSURLSessionDataTask *task = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        CLMRESTResponse *resp = [CLMRESTResponse new];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            resp.statusCode = ((NSHTTPURLResponse *)response).statusCode;
        }
        if (error) {
            resp.error = error;
        } else if (data.length > 0) {
            NSError *jsonError = nil;
            id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                resp.error = jsonError;
            } else {
                resp.JSONObject = obj;
            }
        }
        if (completion) completion(resp);
    }];
    [task resume];
}
@end

@implementation CLMDiscordRESTClient (Convenience)
- (void)getCurrentApplication:(CLMRESTCompletion)completion {
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:@"applications/@me"];
    [self performRequest:req completion:completion];
}

- (void)getCurrentUser:(CLMRESTCompletion)completion {
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:@"users/@me"];
    [self performRequest:req completion:completion];
}

- (void)getChannelWithID:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)sendMessage:(NSString *)content toChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = @{ @"content": content ?: @"" };
    [self performRequest:req completion:completion];
}

- (void)getGuildWithID:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)listChannelsInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/channels", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)listMembersInGuild:(NSString *)guildID limit:(NSNumber *)limit after:(NSString *)after completion:(CLMRESTCompletion)completion {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    if (limit) { [parts addObject:[NSString stringWithFormat:@"limit=%@", limit]]; }
    if (after.length > 0) { [parts addObject:[NSString stringWithFormat:@"after=%@", after]]; }
    NSString *query = parts.count ? [@"?" stringByAppendingString:[parts componentsJoinedByString:@"&"]] : @"";
    NSString *route = [NSString stringWithFormat:@"guilds/%@/members%@", guildID, query];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)modifyChannelWithID:(NSString *)channelID name:(NSString *)name topic:(NSString *)topic completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@", channelID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (topic.length > 0) { body[@"topic"] = topic; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)deleteChannelWithID:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)triggerTypingInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/typing", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    [self performRequest:req completion:completion];
}

- (void)listWebhooksInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/webhooks", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)createWebhookInChannel:(NSString *)channelID name:(NSString *)name completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/webhooks", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = @{ @"name": name ?: @"webhook" };
    [self performRequest:req completion:completion];
}

- (void)listMessagesInChannel:(NSString *)channelID
                         limit:(NSNumber *)limit
                        before:(NSString *)before
                         after:(NSString *)after
                       completion:(CLMRESTCompletion)completion {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    if (limit) { [parts addObject:[NSString stringWithFormat:@"limit=%@", limit]]; }
    if (before.length > 0) { [parts addObject:[NSString stringWithFormat:@"before=%@", before]]; }
    if (after.length > 0) { [parts addObject:[NSString stringWithFormat:@"after=%@", after]]; }
    NSString *query = parts.count ? [@"?" stringByAppendingString:[parts componentsJoinedByString:@"&"]] : @"";
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages%@", channelID, query];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)editMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID newContent:(NSString *)content completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages/%@", channelID, messageID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = @{ @"content": content ?: @"" };
    [self performRequest:req completion:completion];
}

- (void)deleteMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages/%@", channelID, messageID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}
@end
