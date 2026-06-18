# Commands

**Classes:** `CLMCommandRouter`, `CLMCommandContext`, `CLMCommandCooldownManager`  
**Headers:** `Commands/CLMCommand*.h`

MEE6-style prefix command system with cooldowns and permissions.

## CLMCommand Protocol

```objc
@protocol CLMCommand <NSObject>
@property (nonatomic, readonly) NSString *name;
@optional
@property (nonatomic, readonly) NSString *commandDescription;
@property (nonatomic, readonly) NSArray<NSString *> *aliases;
@property (nonatomic, readonly) NSTimeInterval cooldownSeconds;    // default 0 (no cooldown)
@property (nonatomic, readonly) NSArray<NSString *> *requiredPermissions; // permission strings
- (void)executeWithContext:(CLMCommandContext *)ctx
               completion:(CLMCommandCompletion)completion;
@end
```

## CLMCommandRouter

```objc
@interface CLMCommandRouter : NSObject
@property (nonatomic, strong) CLMCommandCooldownManager *cooldowns;
@property (nonatomic, weak) id<CLMCommandRouterDelegate> delegate;
@property (nonatomic, strong) id<CLMLogger> logger;
@property (nonatomic, copy) NSString *prefix;                     // default "!"
@property (nonatomic, weak) id<CLMCommandPermissionChecker> permissionChecker;

- (instancetype)initWithREST:(CLMDiscordRESTClient *)rest
                     gateway:(CLMDiscordGatewayClient *)gateway;
- (void)registerCommand:(id<CLMCommand>)command;
- (id<CLMCommand>)commandNamed:(NSString *)name;
- (void)addMiddleware:(CLMCommandMiddleware)middleware;
- (void)handleMessageCreatePayload:(NSDictionary *)json;
@end
```

### Middleware

```objc
typedef BOOL (^CLMCommandMiddleware)(CLMCommandContext *ctx, NSError **error);
```

Return NO to reject the command. Set `error` to provide a reason.

### Delegate

```objc
@protocol CLMCommandRouterDelegate <NSObject>
@optional
- (void)commandRouterDidHandleCommand:(NSString *)commandName;
- (void)commandRouterDidFailToHandleCommand:(NSString *)commandName error:(NSError *)error;
- (void)commandRouterDidRejectCommand:(NSString *)commandName reason:(NSString *)reason;
@end
```

## CLMCommandContext

```objc
@interface CLMCommandContext : NSObject
@property (nonatomic, strong, readonly) NSDictionary *messageJSON;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy, readonly) NSString *guildId;
@property (nonatomic, copy, readonly) NSString *channelId;
@property (nonatomic, copy, readonly) NSString *authorId;
@property (nonatomic, copy, readonly) NSArray<NSString *> *arguments;
@property (nonatomic, strong, readonly) CLMDiscordRESTClient *rest;
@property (nonatomic, strong, readonly) CLMDiscordGatewayClient *gateway;

// Convenience reply methods
- (void)replyWithContent:(NSString *)content
              completion:(void(^)(CLMRESTResponse *response))completion;
- (void)replyWithJSON:(NSDictionary *)json
           completion:(void(^)(CLMRESTResponse *response))completion;
- (void)replyDeferredWithCompletion:(void(^)(CLMRESTResponse *response))completion;
@end
```

## CLMCommandCooldownManager

```objc
@interface CLMCommandCooldownManager : NSObject
- (BOOL)canExecuteCommand:(NSString *)commandName userId:(NSString *)userId
                cooldown:(NSTimeInterval)cooldownSeconds now:(NSTimeInterval)now;
- (void)recordExecutionForCommand:(NSString *)commandName userId:(NSString *)userId
                               at:(NSTimeInterval)now;
@end
```

Thread-safe with concurrent reads and barrier writes.

## CLMCommandPermissionChecker

```objc
@protocol CLMCommandPermissionChecker <NSObject>
- (BOOL)userId:(NSString *)userId hasPermissions:(NSArray<NSString *> *)permissions
       inGuild:(NSString *)guildId error:(NSError **)error;
@end
```

Implement this protocol to integrate with your permission system (role-based, etc.).

## Example

```objc
CLMCommandRouter *router = [[CLMCommandRouter alloc] initWithREST:client.rest
                                                           gateway:client.gateway];
router.prefix = @"!";
router.logger = client.logger;
router.delegate = self;
router.permissionChecker = myPermissionChecker;

[router registerCommand:[PingCommand new]];
[router registerCommand:[GreetCommand new]];

// In your MESSAGE_CREATE handler:
[router handleMessageCreatePayload:payload];
```
