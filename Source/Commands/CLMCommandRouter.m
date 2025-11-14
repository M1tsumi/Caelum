#import "CLMCommandRouter.h"
#import "CLMCommandCooldownManager.h"
#import "CLMCommandContext.h"
#import "../REST/CLMDiscordRESTClient.h"
#import "../Gateway/CLMDiscordGatewayClient.h"

@interface CLMCommandRouter ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, id<CLMCommand>> *registry; // lowercased name -> command
@property (nonatomic, strong) NSMutableArray<CLMCommandMiddleware> *middlewares;
@property (nonatomic, strong) CLMDiscordRESTClient *rest;
@property (nonatomic, weak) CLMDiscordGatewayClient *gateway;
@end

@implementation CLMCommandRouter

- (instancetype)initWithREST:(CLMDiscordRESTClient *)rest gateway:(CLMDiscordGatewayClient *)gateway {
    if (self = [super init]) {
        _rest = rest;
        _gateway = gateway;
        _registry = [NSMutableDictionary dictionary];
        _middlewares = [NSMutableArray array];
        _cooldowns = [[CLMCommandCooldownManager alloc] initWithQueue:dispatch_queue_create("com.caelum.commands.router", DISPATCH_QUEUE_CONCURRENT)];
        _prefix = @"!";
    }
    return self;
}

- (void)registerCommand:(id<CLMCommand>)command {
    self.registry[command.name.lowercaseString] = command;
    for (NSString *alias in (command.aliases ?: @[])) {
        self.registry[alias.lowercaseString] = command;
    }
}

- (id<CLMCommand>)commandNamed:(NSString *)name { return self.registry[name.lowercaseString]; }

- (void)addMiddleware:(CLMCommandMiddleware)middleware { [self.middlewares addObject:[middleware copy]]; }

- (void)handleMessageCreatePayload:(NSDictionary *)json {
    NSDictionary *contentDict = json[@"content"] ? json : json[@"d"] ?: @{}; // support gateway-like payloads
    NSString *content = contentDict[@"content"] ?: @"";
    if (content.length == 0) return;
    if (![content hasPrefix:self.prefix]) return;

    NSString *guildId = contentDict[@"guild_id"];
    NSString *channelId = contentDict[@"channel_id"] ?: @"";
    NSString *authorId = contentDict[@"author"][@"id"] ?: @"";

    NSString *noPrefix = [content substringFromIndex:self.prefix.length];
    NSArray<NSString *> *parts = [noPrefix componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    parts = [parts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    if (parts.count == 0) return;
    NSString *cmdName = parts.firstObject;
    NSArray<NSString *> *args = parts.count > 1 ? [parts subarrayWithRange:NSMakeRange(1, parts.count - 1)] : @[];

    id<CLMCommand> command = [self commandNamed:cmdName];
    if (!command) return;

    // Cooldown
    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if (![self.cooldowns canExecuteCommand:command.name userId:authorId cooldown:command.cooldownSeconds now:now]) {
        return; // silently drop; bots can implement feedback by a middleware
    }

    // Permissions
    if (self.permissionChecker && command.requiredPermissions.count > 0) {
        NSError *permErr = nil;
        BOOL ok = [self.permissionChecker userId:authorId hasPermissions:command.requiredPermissions inGuild:guildId error:&permErr];
        if (!ok) { return; }
    }

    CLMCommandContext *ctx = [[CLMCommandContext alloc] initWithMessageJSON:json
                                                                     content:content
                                                                      guildId:guildId
                                                                    channelId:channelId
                                                                      authorId:authorId
                                                                     arguments:args
                                                                          rest:self.rest
                                                                       gateway:self.gateway];

    // Middleware chain
    for (CLMCommandMiddleware mw in self.middlewares) {
        NSError *mwErr = nil;
        if (!mw(ctx, &mwErr)) { return; }
    }

    [command executeWithContext:ctx completion:^(NSError * _Nullable error) {
        // no-op; bots may log or emit events
    }];
}

@end
