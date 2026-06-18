# Caelum - Discord API Wrapper for Objective-C

**Objective-C Discord Bot Library | Discord Gateway v10 | iOS & macOS**

Native Objective-C library for Discord bots on Apple platforms. No Swift required.

![Language](https://img.shields.io/badge/language-Objective%E2%80%91C-blue)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-lightgrey)
![Status](https://img.shields.io/badge/status-early--development-orange)
[![Changelog](https://img.shields.io/badge/docs-changelog-informational)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![CI](https://github.com/M1tsumi/Caelum/actions/workflows/ci.yml/badge.svg)](https://github.com/M1tsumi/Caelum/actions/workflows/ci.yml)

> API may change before v1.0.

---

## What's This For?

Most Discord bot libraries are Python, JavaScript, or Rust. If you work in Objective-C, options are slim. Caelum wraps Discord's REST API and Gateway in native Foundation types.

**Good for:**
- Objective-C projects that need a Discord bot
- Writing `[client sendMessage:@"hi" toChannel:id]` instead of stringifying JSON
- Sticking with Foundation without bridging to Swift

---

## Quick Start

```objc
#import <Caelum/Caelum.h>

CLMClientConfiguration *config = [CLMClientConfiguration defaultConfiguration];
config.restConfiguration.botToken = @"BOT_TOKEN";
config.gatewayConfiguration.intents = CLMIntentGuilds | CLMIntentGuildMessages;

CLMDiscordClient *client = [[CLMDiscordClient alloc] initWithConfiguration:config];
[client.gateway connect];

[client.rest sendMessage:@"Hello" toChannel:channelID
              completion:^(CLMRESTResponse *resp) {
    if (resp.isSuccess) NSLog(@"Sent!");
}];
```

### Prefix Commands

```objc
CLMCommandRouter *router = [[CLMCommandRouter alloc] initWithREST:client.rest
                                                           gateway:client.gateway];
router.prefix = @"!";

@interface PingCommand : NSObject <CLMCommand>
@end
@implementation PingCommand
- (NSString *)name { return @"ping"; }
- (NSTimeInterval)cooldownSeconds { return 5; }
- (void)executeWithContext:(CLMCommandContext *)ctx
                completion:(CLMCommandCompletion)completion {
    [ctx replyWithContent:@"Pong!" completion:^(CLMRESTResponse *resp) {
        if (completion) completion(nil);
    }];
}
@end
[router registerCommand:[PingCommand new]];
```

### File Uploads

```objc
NSData *image = [NSData dataWithContentsOfFile:@"/tmp/screenshot.png"];
CLMRESTFilePart *file = [CLMRESTFilePart partWithField:@"files[0]"
                                               filename:@"screenshot.png"
                                               mimeType:@"image/png"
                                                   data:image];
[client.rest sendMessageInChannel:channelID
                             json:@{ @"content": @"Screenshot" }
                            files:@[file]
                       completion:^(CLMRESTResponse *resp) { }];
```

### Event Listeners

```objc
[[CLMEventCenter shared] addListenerForEvent:@"GUILD_CREATE"
                                       queue:dispatch_get_main_queue()
                                       block:^(NSDictionary *guild) {
    NSLog(@"Added to guild: %@", guild[@"name"]);
}];
```

---

## Requirements

- iOS 13.0+ / macOS 10.15+ (for `NSURLSessionWebSocketTask`)
- Xcode 15+
- Apple Silicon or Intel Mac

Apple platforms only. Foundation does not run on Linux or Windows.

---

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/M1tsumi/Caelum.git", from: "0.2.0")
]
```

```objc
#import <Caelum/Caelum.h>
```

---

## Project Layout

```
  Source/
  Gateway/    WebSocket, sharding, reconnect
  REST/       Endpoints, rate limiter, response models
  Models/     Discord objects (messages, guilds, components, etc.)
  Commands/   Command router, cooldowns, permissions
  Client/     Facade tying REST + Gateway together
  Core/       Logger, errors, cache, event center
  Tests/      ~85 unit tests (REST endpoints, errors, response headers, rate limiter, cooldowns)
```

---

## Documentation

Full API reference is in the [docs/](docs/) folder:

- [Getting Started](docs/getting-started.md)
- [REST Client](docs/rest-client.md)
- [Gateway](docs/gateway.md)
- [Models](docs/models.md)
- [Commands](docs/commands.md)
- [Error Handling](docs/error-handling.md)
- [Logging](docs/logging.md)
- [Rate Limiting](docs/rate-limiting.md)
- [Caching](docs/caching.md)
- [Events](docs/events.md)

---

## API Coverage

### Gateway v10

Identify, Heartbeat, Resume, Reconnect, Invalid Session, Sharding, Presence Update, Member Chunk -- all implemented.

### REST v10

Users, Channels, Messages, Threads, Guilds, Roles, Bans, Webhooks, Invites, Application Commands & Permissions, Interactions (slash commands, buttons, selects, modals, followups), Polls, AutoMod, Scheduled Events, Stage Instances, Guild Templates, Onboarding, Welcome Screen, Member Verification, Incident Actions, Emojis, Stickers, Application Emojis, Voice State (mute/deafen/suppress only).

Voice audio (send/receive) is **not** implemented.

---

## Things to Know

### Rate Limiting
Per-bucket and global rate limit tracking. On 429, `CLMRESTResponse.error.userInfo` contains `retry_after`, `x-ratelimit-bucket`, `x-ratelimit-global`. Requests are delayed automatically when a bucket is exhausted.

### Error Handling
All errors use `CLMErrorDomain` with typed codes: `CLMErrorUnauthorized`, `CLMErrorRateLimited`, `CLMErrorNotFound`, `CLMErrorForbidden`, `CLMErrorBadRequest`, `CLMErrorServer`, `CLMErrorNetwork`, `CLMErrorDecode`, `CLMErrorWebSocket`. Use `CLMErrorMake()` to create consistent errors.

### Logging
Set `client.logger` to an `id<CLMLogger>`. Use the `CLMLog()` macro for automatic file/line/function info. Default logger prints to NSLog at INFO+. Implement the protocol to hook in OSLog, file, or remote logging.

---

## Contributing

Fork, branch, PR. Keep code style consistent. See [CHANGELOG.md](CHANGELOG.md).

[Discord](https://discord.gg/6nS2KqxQtj) | [Issues](https://github.com/M1tsumi/Caelum/issues)

---

## License

MIT -- see [LICENSE](LICENSE).
