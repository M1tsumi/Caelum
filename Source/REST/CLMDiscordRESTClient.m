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
    NSString *token = [self.configuration.tokenProvider botToken];
    if (token.length > 0) {
        [urlRequest setValue:[NSString stringWithFormat:@"Bot %@", token] forHTTPHeaderField:@"Authorization"];
    }

    // Audit Log Reason (optional, URL-encoded per Discord requirements)
    if (request.auditLogReason.length > 0) {
        NSString *encoded = [request.auditLogReason stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        if (encoded.length > 0) {
            [urlRequest setValue:encoded forHTTPHeaderField:@"X-Audit-Log-Reason"];
        }
    }

    // Body: JSON or multipart
    if (request.files.count > 0) {
        NSString *boundary = [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
        [urlRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
        NSMutableData *bodyData = [NSMutableData data];
        // payload_json part
        NSDictionary *payload = request.jsonBody ?: @{};
        NSError *payloadErr = nil;
        NSData *payloadJSON = [NSJSONSerialization dataWithJSONObject:payload options:0 error:&payloadErr];
        if (payloadErr) {
            CLMRESTResponse *resp = [CLMRESTResponse new];
            resp.error = payloadErr;
            if (completion) completion(resp);
            return;
        }
        [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[@"Content-Disposition: form-data; name=\"payload_json\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:[@"Content-Type: application/json\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [bodyData appendData:payloadJSON];
        [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        // file parts
        [request.files enumerateObjectsUsingBlock:^(CLMRESTFilePart * _Nonnull part, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *field = part.fieldName.length > 0 ? part.fieldName : [NSString stringWithFormat:@"files[%lu]", (unsigned long)idx];
            NSString *filename = part.filename.length > 0 ? part.filename : @"file.bin";
            NSString *mime = part.mimeType.length > 0 ? part.mimeType : @"application/octet-stream";
            [bodyData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [bodyData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", field, filename] dataUsingEncoding:NSUTF8StringEncoding]];
            [bodyData appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mime] dataUsingEncoding:NSUTF8StringEncoding]];
            [bodyData appendData:part.data ?: [NSData data]];
            [bodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }];
        [bodyData appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        urlRequest.HTTPBody = bodyData;
    } else if (request.jsonBody) {
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
            // Network/transport error
            resp.error = [NSError errorWithDomain:@"com.caelum.discord"
                                             code:1 /* CLMErrorNetwork */
                                         userInfo:@{ NSUnderlyingErrorKey: error ?: [NSNull null],
                                                     @"endpoint": request.route ?: @"",
                                                   }];
        } else if (data.length > 0) {
            NSError *jsonError = nil;
            id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                resp.error = [NSError errorWithDomain:@"com.caelum.discord"
                                                 code:2 /* CLMErrorDecode */
                                             userInfo:@{ NSUnderlyingErrorKey: jsonError,
                                                         @"endpoint": request.route ?: @"",
                                                         @"statusCode": @(resp.statusCode),
                                                       }];
            } else {
                resp.JSONObject = obj;
            }
        }

        // Map HTTP status codes to domain errors when applicable
        if (!resp.error && resp.statusCode >= 400) {
            NSInteger code = 0; // CLMErrorUnknown default
            if (resp.statusCode == 401) code = 3; // CLMErrorUnauthorized
            else if (resp.statusCode == 429) code = 4; // CLMErrorRateLimited
            else if (resp.statusCode >= 500) code = 7; // server generic
            NSMutableDictionary *ui = [@{ @"statusCode": @(resp.statusCode),
                                          @"endpoint": request.route ?: @"",
                                        } mutableCopy];
            if (resp.statusCode == 429 && response) {
                NSDictionary *headers = ((NSHTTPURLResponse *)response).allHeaderFields;
                id ra = headers[@"Retry-After"]; if (ra) ui[@"retry_after"] = ra;
                id rl = headers[@"X-RateLimit-Remaining"]; if (rl) ui[@"x-ratelimit-remaining"] = rl;
                id rra = headers[@"X-RateLimit-Reset-After"]; if (rra) ui[@"x-ratelimit-reset-after"] = rra;
                id rb = headers[@"X-RateLimit-Bucket"]; if (rb) ui[@"x-ratelimit-bucket"] = rb;
                id rg = headers[@"X-RateLimit-Global"]; if (rg) ui[@"x-ratelimit-global"] = rg;
            }
            resp.error = [NSError errorWithDomain:@"com.caelum.discord"
                                             code:code
                                         userInfo:ui];
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

- (void)sendMessage:(NSString *)content toChannel:(NSString *)channelID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = @{ @"content": content ?: @"" };
    req.auditLogReason = reason;
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

- (void)modifyChannelWithID:(NSString *)channelID name:(NSString *)name topic:(NSString *)topic auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@", channelID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (topic.length > 0) { body[@"topic"] = topic; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)modifyChannelWithID:(NSString *)channelID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)modifyChannelWithID:(NSString *)channelID json:(NSDictionary *)json auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = json ?: @{};
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)deleteChannelWithID:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)deleteChannelWithID:(NSString *)channelID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)triggerTypingInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/typing", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    [self performRequest:req completion:completion];
}

- (void)triggerTypingInChannel:(NSString *)channelID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/typing", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.auditLogReason = reason;
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

- (void)createWebhookInChannel:(NSString *)channelID name:(NSString *)name auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/webhooks", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = @{ @"name": name ?: @"webhook" };
    req.auditLogReason = reason;
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

- (void)editMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID newContent:(NSString *)content auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages/%@", channelID, messageID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = @{ @"content": content ?: @"" };
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)deleteMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages/%@", channelID, messageID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)deleteMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages/%@", channelID, messageID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)getUserWithID:(NSString *)userID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"users/%@", userID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)addOwnReactionInChannel:(NSString *)channelID messageID:(NSString *)messageID emoji:(NSString *)emoji completion:(CLMRESTCompletion)completion {
    NSString *encodedEmoji = [emoji stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] ?: emoji;
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages/%@/reactions/%@/@me", channelID, messageID, encodedEmoji];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PUT" route:route];
    [self performRequest:req completion:completion];
}

- (void)removeOwnReactionInChannel:(NSString *)channelID messageID:(NSString *)messageID emoji:(NSString *)emoji completion:(CLMRESTCompletion)completion {
    NSString *encodedEmoji = [emoji stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]] ?: emoji;
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages/%@/reactions/%@/@me", channelID, messageID, encodedEmoji];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)bulkDeleteMessagesInChannel:(NSString *)channelID messageIDs:(NSArray<NSString *> *)messageIDs completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages/bulk-delete", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = @{ @"messages": messageIDs ?: @[] };
    [self performRequest:req completion:completion];
}

- (void)listPinnedMessagesInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/pins", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)pinMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/pins/%@", channelID, messageID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PUT" route:route];
    [self performRequest:req completion:completion];
}

- (void)unpinMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/pins/%@", channelID, messageID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)createChannelInGuild:(NSString *)guildID name:(NSString *)name type:(NSNumber *)type topic:(NSString *)topic completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/channels", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (type) { body[@"type"] = type; }
    if (topic.length > 0) { body[@"topic"] = topic; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)createChannelInGuild:(NSString *)guildID name:(NSString *)name type:(NSNumber *)type topic:(NSString *)topic auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/channels", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (type) { body[@"type"] = type; }
    if (topic.length > 0) { body[@"topic"] = topic; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

// Forum: Create initial post (thread) in a forum channel
- (void)createForumPostInChannel:(NSString *)channelID title:(NSString *)title messageJSON:(NSDictionary *)message appliedTagIds:(NSArray<NSString*> *)tagIds completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/threads", channelID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (title.length > 0) { body[@"name"] = title; }
    if (tagIds.count > 0) { body[@"applied_tags"] = tagIds; }
    if (message.count > 0) { body[@"message"] = message; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)listRolesInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/roles", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)createRoleInGuild:(NSString *)guildID name:(NSString *)name completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/roles", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = @{ @"name": name ?: @"" };
    [self performRequest:req completion:completion];
}

- (void)createRoleInGuild:(NSString *)guildID name:(NSString *)name auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/roles", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = @{ @"name": name ?: @"" };
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)deleteRoleInGuild:(NSString *)guildID roleID:(NSString *)roleID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/roles/%@", guildID, roleID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)deleteRoleInGuild:(NSString *)guildID roleID:(NSString *)roleID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/roles/%@", guildID, roleID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)banUserInGuild:(NSString *)guildID userID:(NSString *)userID deleteMessageSeconds:(NSNumber *)deleteMessageSeconds auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/bans/%@", guildID, userID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PUT" route:route];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (deleteMessageSeconds) { body[@"delete_message_seconds"] = deleteMessageSeconds; }
    if (body.count > 0) { req.jsonBody = body; }
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)unbanUserInGuild:(NSString *)guildID userID:(NSString *)userID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/bans/%@", guildID, userID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)modifyWebhookWithID:(NSString *)webhookID name:(NSString *)name channelID:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"webhooks/%@", webhookID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (channelID.length > 0) { body[@"channel_id"] = channelID; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)modifyWebhookWithID:(NSString *)webhookID name:(NSString *)name channelID:(NSString *)channelID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"webhooks/%@", webhookID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (channelID.length > 0) { body[@"channel_id"] = channelID; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)deleteWebhookWithID:(NSString *)webhookID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"webhooks/%@", webhookID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)deleteWebhookWithID:(NSString *)webhookID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"webhooks/%@", webhookID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)getMemberInGuild:(NSString *)guildID userID:(NSString *)userID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/members/%@", guildID, userID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)modifyMemberInGuild:(NSString *)guildID userID:(NSString *)userID nick:(NSString *)nick completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/members/%@", guildID, userID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (nick.length > 0) { body[@"nick"] = nick; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)modifyMemberInGuild:(NSString *)guildID userID:(NSString *)userID nick:(NSString *)nick auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/members/%@", guildID, userID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (nick.length > 0) { body[@"nick"] = nick; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)kickMemberInGuild:(NSString *)guildID userID:(NSString *)userID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/members/%@", guildID, userID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)kickMemberInGuild:(NSString *)guildID userID:(NSString *)userID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/members/%@", guildID, userID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)addRoleToMemberInGuild:(NSString *)guildID userID:(NSString *)userID roleID:(NSString *)roleID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/members/%@/roles/%@", guildID, userID, roleID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PUT" route:route];
    [self performRequest:req completion:completion];
}

- (void)addRoleToMemberInGuild:(NSString *)guildID userID:(NSString *)userID roleID:(NSString *)roleID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/members/%@/roles/%@", guildID, userID, roleID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PUT" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)removeRoleFromMemberInGuild:(NSString *)guildID userID:(NSString *)userID roleID:(NSString *)roleID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/members/%@/roles/%@", guildID, userID, roleID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)removeRoleFromMemberInGuild:(NSString *)guildID userID:(NSString *)userID roleID:(NSString *)roleID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/members/%@/roles/%@", guildID, userID, roleID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)searchMembersInGuild:(NSString *)guildID query:(NSString *)query limit:(NSNumber *)limit completion:(CLMRESTCompletion)completion {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    if (query.length > 0) { [parts addObject:[NSString stringWithFormat:@"query=%@", [query stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]]; }
    if (limit) { [parts addObject:[NSString stringWithFormat:@"limit=%@", limit]]; }
    NSString *queryStr = parts.count ? [@"?" stringByAppendingString:[parts componentsJoinedByString:@"&"]] : @"";
    NSString *route = [NSString stringWithFormat:@"guilds/%@/members/search%@", guildID, queryStr];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

// Invites
- (void)createInviteInChannel:(NSString *)channelID maxAge:(NSNumber *)maxAge maxUses:(NSNumber *)maxUses temporary:(NSNumber *)temporary unique:(NSNumber *)unique completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/invites", channelID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (maxAge) { body[@"max_age"] = maxAge; }
    if (maxUses) { body[@"max_uses"] = maxUses; }
    if (temporary) { body[@"temporary"] = temporary; }
    if (unique) { body[@"unique"] = unique; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)createInviteInChannel:(NSString *)channelID maxAge:(NSNumber *)maxAge maxUses:(NSNumber *)maxUses temporary:(NSNumber *)temporary unique:(NSNumber *)unique auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/invites", channelID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (maxAge) { body[@"max_age"] = maxAge; }
    if (maxUses) { body[@"max_uses"] = maxUses; }
    if (temporary) { body[@"temporary"] = temporary; }
    if (unique) { body[@"unique"] = unique; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    if (body.count > 0) req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)deleteInviteWithCode:(NSString *)inviteCode completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"invites/%@", inviteCode];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)deleteInviteWithCode:(NSString *)inviteCode auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"invites/%@", inviteCode];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)getInviteWithCode:(NSString *)inviteCode completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"invites/%@", inviteCode];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)listInvitesInChannel:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/invites", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)listInvitesInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/invites", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

// Application Commands
- (void)listGlobalApplicationCommands:(NSString *)applicationID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/commands", applicationID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)createGlobalApplicationCommand:(NSString *)applicationID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/commands", applicationID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)editGlobalApplicationCommand:(NSString *)applicationID commandID:(NSString *)commandID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/commands/%@", applicationID, commandID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)deleteGlobalApplicationCommand:(NSString *)applicationID commandID:(NSString *)commandID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/commands/%@", applicationID, commandID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)listGuildApplicationCommands:(NSString *)applicationID guildID:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/guilds/%@/commands", applicationID, guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)createGuildApplicationCommand:(NSString *)applicationID guildID:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/guilds/%@/commands", applicationID, guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)editGuildApplicationCommand:(NSString *)applicationID guildID:(NSString *)guildID commandID:(NSString *)commandID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/guilds/%@/commands/%@", applicationID, guildID, commandID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)deleteGuildApplicationCommand:(NSString *)applicationID guildID:(NSString *)guildID commandID:(NSString *)commandID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/guilds/%@/commands/%@", applicationID, guildID, commandID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

// Channel Permission Overwrites
- (void)setPermissionOverwriteInChannel:(NSString *)channelID overwriteID:(NSString *)overwriteID allow:(NSNumber *)allow deny:(NSNumber *)deny type:(NSNumber *)type completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/permissions/%@", channelID, overwriteID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (allow) { body[@"allow"] = allow; }
    if (deny) { body[@"deny"] = deny; }
    if (type) { body[@"type"] = type; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PUT" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)setPermissionOverwriteInChannel:(NSString *)channelID overwriteID:(NSString *)overwriteID allow:(NSNumber *)allow deny:(NSNumber *)deny type:(NSNumber *)type auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/permissions/%@", channelID, overwriteID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (allow) { body[@"allow"] = allow; }
    if (deny) { body[@"deny"] = deny; }
    if (type) { body[@"type"] = type; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PUT" route:route];
    if (body.count > 0) req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)deletePermissionOverwriteInChannel:(NSString *)channelID overwriteID:(NSString *)overwriteID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/permissions/%@", channelID, overwriteID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)deletePermissionOverwriteInChannel:(NSString *)channelID overwriteID:(NSString *)overwriteID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/permissions/%@", channelID, overwriteID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

// Guild Emojis
- (void)listEmojisInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/emojis", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)getEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/emojis/%@", guildID, emojiID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)createEmojiInGuild:(NSString *)guildID name:(NSString *)name image:(NSString *)image roles:(NSArray<NSString *> *)roles completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/emojis", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (image.length > 0) { body[@"image"] = image; }
    if (roles.count > 0) { body[@"roles"] = roles; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)createEmojiInGuild:(NSString *)guildID name:(NSString *)name image:(NSString *)image roles:(NSArray<NSString *> *)roles auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/emojis", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (image.length > 0) { body[@"image"] = image; }
    if (roles.count > 0) { body[@"roles"] = roles; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)modifyEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID name:(NSString *)name roles:(NSArray<NSString *> *)roles completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/emojis/%@", guildID, emojiID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (roles) { body[@"roles"] = roles ?: @[]; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)modifyEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID name:(NSString *)name roles:(NSArray<NSString *> *)roles auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/emojis/%@", guildID, emojiID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (roles) { body[@"roles"] = roles ?: @[]; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    if (body.count > 0) req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)deleteEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/emojis/%@", guildID, emojiID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)deleteEmojiInGuild:(NSString *)guildID emojiID:(NSString *)emojiID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/emojis/%@", guildID, emojiID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

// Application Emojis
- (void)listApplicationEmojis:(NSString *)applicationID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/emojis", applicationID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)getApplicationEmoji:(NSString *)applicationID emojiID:(NSString *)emojiID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/emojis/%@", applicationID, emojiID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)createApplicationEmoji:(NSString *)applicationID name:(NSString *)name imageDataURI:(NSString *)imageDataURI completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/emojis", applicationID];
    NSMutableDictionary *body = [NSMutableDictionary new];
    if (name.length) body[@"name"] = name;
    if (imageDataURI.length) body[@"image"] = imageDataURI;
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)modifyApplicationEmoji:(NSString *)applicationID emojiID:(NSString *)emojiID name:(NSString *)name completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/emojis/%@", applicationID, emojiID];
    NSMutableDictionary *body = [NSMutableDictionary new];
    if (name.length) body[@"name"] = name;
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)deleteApplicationEmoji:(NSString *)applicationID emojiID:(NSString *)emojiID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"applications/%@/emojis/%@", applicationID, emojiID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

// Stickers
- (void)listStickersInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/stickers", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)getStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/stickers/%@", guildID, stickerID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)getStickerWithID:(NSString *)stickerID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"stickers/%@", stickerID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)createStickerInGuild:(NSString *)guildID name:(NSString *)name description:(NSString *)description tags:(NSString *)tags image:(NSString *)image completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/stickers", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (description.length > 0) { body[@"description"] = description; }
    if (tags.length > 0) { body[@"tags"] = tags; }
    if (image.length > 0) { body[@"image"] = image; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)createStickerInGuild:(NSString *)guildID name:(NSString *)name description:(NSString *)description tags:(NSString *)tags image:(NSString *)image auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/stickers", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (description.length > 0) { body[@"description"] = description; }
    if (tags.length > 0) { body[@"tags"] = tags; }
    if (image.length > 0) { body[@"image"] = image; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)modifyStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID name:(NSString *)name description:(NSString *)description tags:(NSString *)tags completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/stickers/%@", guildID, stickerID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (description) { body[@"description"] = description ?: @""; }
    if (tags) { body[@"tags"] = tags ?: @""; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)modifyStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID name:(NSString *)name description:(NSString *)description tags:(NSString *)tags auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/stickers/%@", guildID, stickerID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (description) { body[@"description"] = description ?: @""; }
    if (tags) { body[@"tags"] = tags ?: @""; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    if (body.count > 0) req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)deleteStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/stickers/%@", guildID, stickerID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)deleteStickerInGuild:(NSString *)guildID stickerID:(NSString *)stickerID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/stickers/%@", guildID, stickerID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

// Guild Management
- (void)modifyGuildWithID:(NSString *)guildID name:(NSString *)name icon:(NSString *)icon description:(NSString *)description completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (icon.length > 0) { body[@"icon"] = icon; }
    if (description) { body[@"description"] = description ?: @""; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)modifyGuildWithID:(NSString *)guildID name:(NSString *)name icon:(NSString *)icon description:(NSString *)description auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (icon.length > 0) { body[@"icon"] = icon; }
    if (description) { body[@"description"] = description ?: @""; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    if (body.count > 0) req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)getPruneCountInGuild:(NSString *)guildID days:(NSNumber *)days includeRoles:(NSArray<NSString *> *)includeRoles completion:(CLMRESTCompletion)completion {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    if (days) { [parts addObject:[NSString stringWithFormat:@"days=%@", days]]; }
    if (includeRoles.count > 0) { [parts addObject:[NSString stringWithFormat:@"include_roles=%@", [includeRoles componentsJoinedByString:@","]]]; }
    NSString *query = parts.count ? [@"?" stringByAppendingString:[parts componentsJoinedByString:@"&"]] : @"";
    NSString *route = [NSString stringWithFormat:@"guilds/%@/prune%@", guildID, query];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)beginPruneInGuild:(NSString *)guildID days:(NSNumber *)days includeRoles:(NSArray<NSString *> *)includeRoles computeCount:(NSNumber *)computeCount completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/prune", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (days) { body[@"days"] = days; }
    if (includeRoles.count > 0) { body[@"include_roles"] = includeRoles; }
    if (computeCount) { body[@"compute_prune_count"] = computeCount; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)beginPruneInGuild:(NSString *)guildID days:(NSNumber *)days includeRoles:(NSArray<NSString *> *)includeRoles computeCount:(NSNumber *)computeCount auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/prune", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (days) { body[@"days"] = days; }
    if (includeRoles.count > 0) { body[@"include_roles"] = includeRoles; }
    if (computeCount) { body[@"compute_prune_count"] = computeCount; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    if (body.count > 0) req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)getGuildWidget:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/widget", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)modifyGuildWidget:(NSString *)guildID enabled:(NSNumber *)enabled channelID:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/widget", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (enabled) { body[@"enabled"] = enabled; }
    if (channelID.length > 0) { body[@"channel_id"] = channelID; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)modifyGuildWidget:(NSString *)guildID enabled:(NSNumber *)enabled channelID:(NSString *)channelID auditLogReason:(NSString *)reason completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/widget", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (enabled) { body[@"enabled"] = enabled; }
    if (channelID.length > 0) { body[@"channel_id"] = channelID; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    if (body.count > 0) req.jsonBody = body;
    req.auditLogReason = reason;
    [self performRequest:req completion:completion];
}

- (void)getGuildVanityURL:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/vanity-url", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)listGuildIntegrations:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/integrations", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

// Threads
- (void)startThreadFromMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID name:(NSString *)name autoArchiveDuration:(NSNumber *)autoArchiveDuration rateLimitPerUser:(NSNumber *)rateLimitPerUser completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages/%@/threads", channelID, messageID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (autoArchiveDuration) { body[@"auto_archive_duration"] = autoArchiveDuration; }
    if (rateLimitPerUser) { body[@"rate_limit_per_user"] = rateLimitPerUser; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)startThreadInChannel:(NSString *)channelID name:(NSString *)name autoArchiveDuration:(NSNumber *)autoArchiveDuration type:(NSNumber *)type invitable:(NSNumber *)invitable rateLimitPerUser:(NSNumber *)rateLimitPerUser completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/threads", channelID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (name.length > 0) { body[@"name"] = name; }
    if (autoArchiveDuration) { body[@"auto_archive_duration"] = autoArchiveDuration; }
    if (type) { body[@"type"] = type; }
    if (invitable) { body[@"invitable"] = invitable; }
    if (rateLimitPerUser) { body[@"rate_limit_per_user"] = rateLimitPerUser; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)joinThread:(NSString *)threadID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/thread-members/@me", threadID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PUT" route:route];
    [self performRequest:req completion:completion];
}

- (void)leaveThread:(NSString *)threadID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/thread-members/@me", threadID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)addThreadMember:(NSString *)threadID userID:(NSString *)userID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/thread-members/%@", threadID, userID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PUT" route:route];
    [self performRequest:req completion:completion];
}

- (void)removeThreadMember:(NSString *)threadID userID:(NSString *)userID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/thread-members/%@", threadID, userID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)listPublicArchivedThreadsInChannel:(NSString *)channelID before:(NSString *)before limit:(NSNumber *)limit completion:(CLMRESTCompletion)completion {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    if (before.length > 0) { [parts addObject:[NSString stringWithFormat:@"before=%@", [before stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]]; }
    if (limit) { [parts addObject:[NSString stringWithFormat:@"limit=%@", limit]]; }
    NSString *query = parts.count ? [@"?" stringByAppendingString:[parts componentsJoinedByString:@"&"]] : @"";
    NSString *route = [NSString stringWithFormat:@"channels/%@/threads/archived/public%@", channelID, query];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)listPrivateArchivedThreadsInChannel:(NSString *)channelID before:(NSString *)before limit:(NSNumber *)limit completion:(CLMRESTCompletion)completion {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    if (before.length > 0) { [parts addObject:[NSString stringWithFormat:@"before=%@", [before stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]]; }
    if (limit) { [parts addObject:[NSString stringWithFormat:@"limit=%@", limit]]; }
    NSString *query = parts.count ? [@"?" stringByAppendingString:[parts componentsJoinedByString:@"&"]] : @"";
    NSString *route = [NSString stringWithFormat:@"channels/%@/threads/archived/private%@", channelID, query];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)listJoinedPrivateArchivedThreadsInChannel:(NSString *)channelID before:(NSString *)before limit:(NSNumber *)limit completion:(CLMRESTCompletion)completion {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    if (before.length > 0) { [parts addObject:[NSString stringWithFormat:@"before=%@", [before stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]]]; }
    if (limit) { [parts addObject:[NSString stringWithFormat:@"limit=%@", limit]]; }
    NSString *query = parts.count ? [@"?" stringByAppendingString:[parts componentsJoinedByString:@"&"]] : @"";
    NSString *route = [NSString stringWithFormat:@"channels/%@/users/@me/threads/archived/private%@", channelID, query];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)listActiveThreadsInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/threads/active", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

// Interaction Followups (webhooks)
- (void)getOriginalInteractionResponseForApplication:(NSString *)applicationID token:(NSString *)token completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"webhooks/%@/%@/messages/@original", applicationID, token];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)editOriginalInteractionResponseForApplication:(NSString *)applicationID token:(NSString *)token json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"webhooks/%@/%@/messages/@original", applicationID, token];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)deleteOriginalInteractionResponseForApplication:(NSString *)applicationID token:(NSString *)token completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"webhooks/%@/%@/messages/@original", applicationID, token];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

- (void)createFollowupMessageForApplication:(NSString *)applicationID token:(NSString *)token json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"webhooks/%@/%@", applicationID, token];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)editFollowupMessageForApplication:(NSString *)applicationID token:(NSString *)token messageID:(NSString *)messageID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"webhooks/%@/%@/messages/%@", applicationID, token, messageID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)deleteFollowupMessageForApplication:(NSString *)applicationID token:(NSString *)token messageID:(NSString *)messageID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"webhooks/%@/%@/messages/%@", applicationID, token, messageID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

// Interaction Initial Response (callbacks)
- (void)createInteractionCallbackWithID:(NSString *)interactionID token:(NSString *)token json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"interactions/%@/%@/callback", interactionID, token];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

// Convenience helpers
- (void)deferUpdateForInteractionID:(NSString *)interactionID token:(NSString *)token completion:(CLMRESTCompletion)completion {
    NSDictionary *payload = @{ @"type": @6 };
    [self createInteractionCallbackWithID:interactionID token:token json:payload completion:completion];
}

- (void)updateMessageForInteractionID:(NSString *)interactionID token:(NSString *)token json:(NSDictionary *)data completion:(CLMRESTCompletion)completion {
    NSDictionary *payload = @{ @"type": @7, @"data": (data ?: @{}) };
    [self createInteractionCallbackWithID:interactionID token:token json:payload completion:completion];
}

- (void)replyToInteractionWithMessage:(NSString *)interactionID token:(NSString *)token json:(NSDictionary *)data completion:(CLMRESTCompletion)completion {
    NSDictionary *payload = @{ @"type": @4, @"data": (data ?: @{}) };
    [self createInteractionCallbackWithID:interactionID token:token json:payload completion:completion];
}

- (void)presentModalForInteractionID:(NSString *)interactionID token:(NSString *)token json:(NSDictionary *)data completion:(CLMRESTCompletion)completion {
    NSDictionary *payload = @{ @"type": @9, @"data": (data ?: @{}) };
    [self createInteractionCallbackWithID:interactionID token:token json:payload completion:completion];
}

// Audit Log
- (void)getGuildAuditLog:(NSString *)guildID userID:(NSString *)userID actionType:(NSNumber *)actionType before:(NSString *)before limit:(NSNumber *)limit completion:(CLMRESTCompletion)completion {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    if (userID.length > 0) { [parts addObject:[NSString stringWithFormat:@"user_id=%@", userID]]; }
    if (actionType) { [parts addObject:[NSString stringWithFormat:@"action_type=%@", actionType]]; }
    if (before.length > 0) { [parts addObject:[NSString stringWithFormat:@"before=%@", before]]; }
    if (limit) { [parts addObject:[NSString stringWithFormat:@"limit=%@", limit]]; }
    NSString *query = parts.count ? [@"?" stringByAppendingString:[parts componentsJoinedByString:@"&"]] : @"";
    NSString *route = [NSString stringWithFormat:@"guilds/%@/audit-logs%@", guildID, query];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

// Scheduled Events
- (void)listGuildScheduledEvents:(NSString *)guildID withUsers:(NSNumber *)withUsers completion:(CLMRESTCompletion)completion {
    NSString *query = withUsers ? [NSString stringWithFormat:@"?with_user_count=%@", withUsers] : @"";
    NSString *route = [NSString stringWithFormat:@"guilds/%@/scheduled-events%@", guildID, query];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)createGuildScheduledEvent:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/scheduled-events", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)modifyGuildScheduledEvent:(NSString *)guildID eventID:(NSString *)eventID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/scheduled-events/%@", guildID, eventID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)deleteGuildScheduledEvent:(NSString *)guildID eventID:(NSString *)eventID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/scheduled-events/%@", guildID, eventID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

// Stage Instances
- (void)createStageInstanceWithChannelID:(NSString *)channelID topic:(NSString *)topic privacyLevel:(NSNumber *)privacyLevel completion:(CLMRESTCompletion)completion {
    NSString *route = @"stage-instances";
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (channelID.length > 0) { body[@"channel_id"] = channelID; }
    if (topic.length > 0) { body[@"topic"] = topic; }
    if (privacyLevel) { body[@"privacy_level"] = privacyLevel; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)modifyStageInstanceWithChannelID:(NSString *)channelID topic:(NSString *)topic privacyLevel:(NSNumber *)privacyLevel completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"stage-instances/%@", channelID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (topic.length > 0) { body[@"topic"] = topic; }
    if (privacyLevel) { body[@"privacy_level"] = privacyLevel; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)deleteStageInstanceWithChannelID:(NSString *)channelID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"stage-instances/%@", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

// Auto Moderation Rules
- (void)listAutoModRulesInGuild:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/auto-moderation/rules", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)getAutoModRuleInGuild:(NSString *)guildID ruleID:(NSString *)ruleID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/auto-moderation/rules/%@", guildID, ruleID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)createAutoModRuleInGuild:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/auto-moderation/rules", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)modifyAutoModRuleInGuild:(NSString *)guildID ruleID:(NSString *)ruleID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/auto-moderation/rules/%@", guildID, ruleID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)deleteAutoModRuleInGuild:(NSString *)guildID ruleID:(NSString *)ruleID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/auto-moderation/rules/%@", guildID, ruleID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

// Voice State
- (void)modifyCurrentUserVoiceStateInGuild:(NSString *)guildID channelID:(NSString *)channelID suppress:(NSNumber *)suppress requestToSpeakTimestampISO8601:(NSString *)timestamp completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/voice-states/@me", guildID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (channelID.length > 0) { body[@"channel_id"] = channelID; }
    if (suppress) { body[@"suppress"] = suppress; }
    if (timestamp.length > 0) { body[@"request_to_speak_timestamp"] = timestamp; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)modifyUserVoiceStateInGuild:(NSString *)guildID userID:(NSString *)userID channelID:(NSString *)channelID suppress:(NSNumber *)suppress completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/voice-states/%@", guildID, userID];
    NSMutableDictionary *body = [NSMutableDictionary dictionary];
    if (channelID.length > 0) { body[@"channel_id"] = channelID; }
    if (suppress) { body[@"suppress"] = suppress; }
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    if (body.count > 0) req.jsonBody = body;
    [self performRequest:req completion:completion];
}

// Messages with attachments
- (void)sendMessageInChannel:(NSString *)channelID json:(NSDictionary *)json files:(NSArray<CLMRESTFilePart *> *)files completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages", channelID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = json ?: @{};
    req.files = files;
    [self performRequest:req completion:completion];
}

- (void)editMessageInChannel:(NSString *)channelID messageID:(NSString *)messageID json:(NSDictionary *)json files:(NSArray<CLMRESTFilePart *> *)files completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages/%@", channelID, messageID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = json ?: @{};
    req.files = files;
    [self performRequest:req completion:completion];
}

// Polls
- (void)sendMessageWithPollInChannel:(NSString *)channelID content:(NSString *)content pollJSON:(NSDictionary *)pollJSON completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"channels/%@/messages", channelID];
    NSMutableDictionary *body = [NSMutableDictionary new];
    if (content.length) body[@"content"] = content;
    if (pollJSON.count) body[@"poll"] = pollJSON;
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = body;
    [self performRequest:req completion:completion];
}

- (void)getPollAnswerUsersInChannel:(NSString *)channelID messageID:(NSString *)messageID answerID:(NSString *)answerID after:(NSString *)after limit:(NSNumber *)limit completion:(CLMRESTCompletion)completion {
    NSMutableArray<NSString *> *parts = [NSMutableArray array];
    if (after.length > 0) { [parts addObject:[NSString stringWithFormat:@"after=%@", after]]; }
    if (limit) { [parts addObject:[NSString stringWithFormat:@"limit=%@", limit]]; }
    NSString *query = parts.count ? [@"?" stringByAppendingString:[parts componentsJoinedByString:@"&"]] : @"";
    NSString *route = [NSString stringWithFormat:@"channels/%@/polls/%@/answers/%@/voters%@", channelID, messageID, answerID, query];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

// Webhook execute (supports files)
- (void)executeWebhookWithID:(NSString *)webhookID token:(NSString *)token json:(NSDictionary *)json files:(NSArray<CLMRESTFilePart *> *)files completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"webhooks/%@/%@", webhookID, token];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = json ?: @{};
    req.files = files;
    [self performRequest:req completion:completion];
}

// Guild Templates
- (void)listGuildTemplates:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/templates", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)getGuildTemplateWithCode:(NSString *)code completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/templates/%@", code];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)createGuildTemplate:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/templates", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"POST" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)syncGuildTemplate:(NSString *)guildID code:(NSString *)code completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/templates/%@", guildID, code];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PUT" route:route];
    [self performRequest:req completion:completion];
}

- (void)modifyGuildTemplate:(NSString *)guildID code:(NSString *)code json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/templates/%@", guildID, code];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

- (void)deleteGuildTemplate:(NSString *)guildID code:(NSString *)code completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/templates/%@", guildID, code];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"DELETE" route:route];
    [self performRequest:req completion:completion];
}

// Welcome Screen
- (void)getGuildWelcomeScreen:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/welcome-screen", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)modifyGuildWelcomeScreen:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/welcome-screen", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PATCH" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

// Onboarding
- (void)getGuildOnboarding:(NSString *)guildID completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/onboarding", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:route];
    [self performRequest:req completion:completion];
}

- (void)modifyGuildOnboarding:(NSString *)guildID json:(NSDictionary *)json completion:(CLMRESTCompletion)completion {
    NSString *route = [NSString stringWithFormat:@"guilds/%@/onboarding", guildID];
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"PUT" route:route];
    req.jsonBody = json ?: @{};
    [self performRequest:req completion:completion];
}

@end
