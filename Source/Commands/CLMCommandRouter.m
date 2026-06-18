#import "CLMCommandRouter.h"
#import "CLMCommandCooldownManager.h"
#import "CLMCommandContext.h"
#import "../REST/CLMDiscordRESTClient.h"
#import "../Gateway/CLMDiscordGatewayClient.h"
#import "../Core/CLMErrors.h"

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
    if (!command) {
        CLMLog(self.logger, CLMLogLevelDebug, @"Unknown command: %@", cmdName);
        if ([self.delegate respondsToSelector:@selector(commandRouterDidRejectCommand:reason:)]) {
            [self.delegate commandRouterDidRejectCommand:cmdName reason:@"Unknown command"];
        }
        return;
    }

    NSTimeInterval now = [NSDate date].timeIntervalSince1970;
    if (![self.cooldowns canExecuteCommand:command.name userId:authorId cooldown:command.cooldownSeconds now:now]) {
        CLMLog(self.logger, CLMLogLevelDebug, @"Command %@ on cooldown for user %@", command.name, authorId);
        if ([self.delegate respondsToSelector:@selector(commandRouterDidRejectCommand:reason:)]) {
            [self.delegate commandRouterDidRejectCommand:command.name reason:@"Cooldown active"];
        }
        return;
    }

    if (self.permissionChecker && command.requiredPermissions.count > 0) {
        NSError *permErr = nil;
        BOOL ok = [self.permissionChecker userId:authorId hasPermissions:command.requiredPermissions inGuild:guildId error:&permErr];
        if (!ok) {
            CLMLog(self.logger, CLMLogLevelWarning, @"Permission denied for %@ by user %@ in guild %@", command.name, authorId, guildId ?: @"?");
            if ([self.delegate respondsToSelector:@selector(commandRouterDidRejectCommand:reason:)]) {
                [self.delegate commandRouterDidRejectCommand:command.name reason:permErr.localizedDescription ?: @"Permission denied"];
            }
            return;
        }
    }

    CLMCommandContext *ctx = [[CLMCommandContext alloc] initWithMessageJSON:json
                                                                     content:content
                                                                      guildId:guildId
                                                                    channelId:channelId
                                                                      authorId:authorId
                                                                     arguments:args
                                                                          rest:self.rest
                                                                       gateway:self.gateway];

    for (CLMCommandMiddleware mw in self.middlewares) {
        NSError *mwErr = nil;
        if (!mw(ctx, &mwErr)) {
            CLMLog(self.logger, CLMLogLevelWarning, @"Middleware rejected command %@: %@", command.name, mwErr.localizedDescription ?: @"no error");
            if ([self.delegate respondsToSelector:@selector(commandRouterDidRejectCommand:reason:)]) {
                [self.delegate commandRouterDidRejectCommand:command.name reason:mwErr.localizedDescription ?: @"Middleware rejected"];
            }
            return;
        }
    }

    [self.cooldowns recordExecutionForCommand:command.name userId:authorId at:now];
    [command executeWithContext:ctx completion:^(NSError * _Nullable error) {
        if (error) {
            CLMLog(self.logger, CLMLogLevelError, @"Command %@ failed: %@", command.name, error.localizedDescription);
            if ([self.delegate respondsToSelector:@selector(commandRouterDidFailToHandleCommand:error:)]) {
                [self.delegate commandRouterDidFailToHandleCommand:command.name error:error];
            }
        } else {
            CLMLog(self.logger, CLMLogLevelInfo, @"Command %@ handled successfully", command.name);
            if ([self.delegate respondsToSelector:@selector(commandRouterDidHandleCommand:)]) {
                [self.delegate commandRouterDidHandleCommand:command.name];
            }
        }
    }];
}

@end
