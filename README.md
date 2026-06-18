# Caelum - Discord API Wrapper for Objective-C

**Objective-C Discord Bot Library | Discord Gateway v10 | iOS & macOS**

An Objective-C library for building Discord bots on Apple platforms. No Swift required — just you, Foundation, and the Discord API.

![Language](https://img.shields.io/badge/language-Objective%E2%80%91C-blue)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-lightgrey)
![Status](https://img.shields.io/badge/status-early--development-orange)
[![Changelog](https://img.shields.io/badge/docs-changelog-informational)](CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![CI](https://github.com/M1tsumi/Caelum/actions/workflows/ci.yml/badge.svg)](https://github.com/M1tsumi/Caelum/actions/workflows/ci.yml)

<div align="center" style="margin: 8px 0 0 0;">
  <a href="https://discord.gg/6nS2KqxQtj" target="_blank" rel="noopener noreferrer">
    <button style="background:#5865F2;color:#fff;border:none;border-radius:6px;padding:8px 14px;font-weight:600;cursor:pointer;">Join our Discord</button>
  </a>
</div>

> **Heads up:** We're still iterating before v1.0. Things might change.

---

## What's This For?

Most Discord bot libraries are written in Python, JavaScript, or Rust. If you're working in an Objective-C codebase (or just prefer it), your options are slim. Caelum is a native Objective-C wrapper around Discord's REST API and Gateway — same frameworks you already use, no bridging needed.

**Good for:**
- Objective-C projects that need a Discord bot
- Developers who'd rather write `[client sendMessage:@"hi" toChannel:id]` than stringify JSON
- Apps that already depend on Foundation and want to stay there

---

## What You Get

### Gateway (real-time bot stuff)
- Discord Gateway v10 over WebSocket — connects, stays alive, reconnects when things break
- Sharding via `CLMShardManager` — handles multi-guild scaling
- Heartbeats, session resume, presence updates, member chunking

### REST API
- Just about every v10 endpoint that doesn't involve voice audio
- Messages, channels, threads, guilds, roles, bans, webhooks, invites
- Application commands (global and per-guild) with permissions
- Interactions — slash commands, buttons, select menus, modals, followups
- Polls, AutoMod, scheduled events, stage instances, forum channels
- Application emojis, stickers, member verification, onboarding, templates
- File uploads with multipart form encoding

### Developer Experience
- `CLMRESTResponse` — `response.isSuccess`, `response.isRateLimited`, rate limit headers exposed directly
- `CLMErrorMake(code, description, extra)` — no more guessing domain strings
- `CLMLog()` — debug/info/warn/error logging with file and line info
- `CLMCommandRouter` — MEE6-style prefix commands with cooldowns and permissions
- `CLMCommandRouterDelegate` — get callbacks when commands succeed, fail, or get rejected
- `CLMEventCenter` — block-based event listeners (subscribe to `MESSAGE_CREATE`, etc.)
- `CLMCacheManager` — in-memory cache with TTL and max size
- Paginators for messages and members
- Rate limiter with per-bucket and global backoff
- Logger protocol — swap in your own logger, or use the default that calls `NSLog`

---

## Requirements

- **iOS 13.0+** or **macOS 10.15+** (needed for `NSURLSessionWebSocketTask`)
- **Xcode 15+**
- Apple Silicon or Intel Mac

This is Apple-only. Foundation doesn't run on Linux or Windows.

---

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/M1tsumi/Caelum.git", from: "0.2.0")
],
targets: [
    .target(
        name: "YourBot",
        dependencies: [
            .product(name: "Caelum", package: "Caelum")
        ]
    )
]
```

Then import:

```objc
#import <Caelum/Caelum.h>
```

CocoaPods and Carthage? Not yet, but maybe later.

---

## Getting Started

### Basic bot

```objc
#import <Caelum/Caelum.h>

CLMClientConfiguration *config = [CLMClientConfiguration defaultConfiguration];
// Set your token — two ways:
config.restConfiguration.botToken = @"BOT_TOKEN_HERE";           // easy
// config.restConfiguration.tokenProvider = myTokenProvider;     // or via protocol
config.gatewayConfiguration.intents = CLMIntentGuilds | CLMIntentGuildMessages;

CLMDiscordClient *client = [[CLMDiscordClient alloc] initWithConfiguration:config];

// Connect to gateway
[client.gateway connect];

// Send a message
[client.rest sendMessage:@"Hello from Caelum!"
               toChannel:channelID
              completion:^(CLMRESTResponse *resp) {
    if (resp.isSuccess) NSLog(@"Sent!");
    if (resp.isRateLimited) NSLog(@"Slow down!");
}];
```

### Prefix commands

```objc
CLMCommandRouter *router = [[CLMCommandRouter alloc] initWithREST:client.rest
                                                           gateway:client.gateway];
router.prefix = @"!";
router.delegate = self; // optional: get callbacks for command lifecycle

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

### File uploads

```objc
NSData *image = [NSData dataWithContentsOfFile:@"/tmp/screenshot.png"];
CLMRESTFilePart *file = [CLMRESTFilePart partWithField:@"files[0]"
                                               filename:@"screenshot.png"
                                               mimeType:@"image/png"
                                                   data:image];

[client.rest sendMessageInChannel:channelID
                             json:@{ @"content": @"Here's a screenshot" }
                            files:@[file]
                       completion:^(CLMRESTResponse *resp) {
    // resp.isSuccess, resp.error, etc.
}];
```

### Event listeners

```objc
[[CLMEventCenter shared] addListenerForEvent:@"GUILD_CREATE"
                                       queue:dispatch_get_main_queue()
                                       block:^(NSDictionary *guild) {
    NSLog(@"Added to guild: %@", guild[@"name"]);
}];
```

---

## Project Layout

```
Source/
├── Gateway/     WebSocket, sharding, reconnect
├── REST/        Endpoints, rate limiter, response models
├── Models/      Discord objects (messages, guilds, components, etc.)
├── Commands/    Command router, cooldowns, permissions
├── Client/      Facade that ties REST + Gateway together
├── Core/        Logger, errors, cache, event center
└── Tests/       Unit tests with mock URL protocol
```

---

## API Coverage

### Gateway v10

| Feature | Status |
|---------|--------|
| Identify, Heartbeat, Resume | Done |
| Reconnect, Invalid Session | Done |
| Sharding | Done |
| Presence Update, Member Chunk | Done |

### REST v10

| Area | Status |
|------|--------|
| Users, Channels, Messages | Full |
| Threads, Guilds, Roles | Full |
| Webhooks, Invites, Bans | Full |
| Application Commands & Permissions | Full |
| Interactions, Followups, Modals | Full |
| Polls, AutoMod, Scheduled Events | Full |
| Stage Instances, Templates | Full |
| Guild Onboarding, Welcome Screen | Full |
| Member Verification, Incident Actions | Full |
| Emojis, Stickers, Application Emojis | Full |
| Voice State (mute/deafen/suppress) | Done — no audio |
| **Voice audio (send/receive)** | **Not implemented** |

---

## Things to Know

### Rate limiting
Caelum tracks per-bucket and global rate limits. If you get 429'd, the `CLMRESTResponse.error.userInfo` includes `retry_after`, `x-ratelimit-bucket`, and `x-ratelimit-global`. The rate limiter delays requests automatically when a bucket is exhausted.

### Error handling
Errors use `CLMErrorDomain` with typed codes — check `resp.error.code` against `CLMErrorUnauthorized`, `CLMErrorRateLimited`, `CLMErrorNotFound`, etc. Use `CLMErrorMake()` to create consistent errors if you're extending things.

### Logging
Assign a `logger` to `client.logger` and `CLMLog()` will output with level, file, line, and function name. The default logger prints to `NSLog` at INFO level and above. Implement the `CLMLogger` protocol to hook in your own (OSLog, file, remote, etc.)

---

## Roadmap

- [x] Gateway v10 core
- [x] REST API coverage (non-voice)
- [x] Sharding
- [x] Interaction components (buttons, selects, modals)
- [x] Application emojis
- [ ] Voice audio (planned)
- [ ] CocoaPods / Carthage
- [ ] More unit tests
- [ ] Performance benchmarks

---

## Contributing

Fork the repo, make a branch, send a PR. Keep the code style consistent — no comments in implementation files, follow the existing patterns.

See [CHANGELOG.md](CHANGELOG.md) for what's changed.

---

## Community

- **Discord**: [Join here](https://discord.gg/6nS2KqxQtj)
- **Issues**: [GitHub Issues](https://github.com/M1tsumi/Caelum/issues)
- **Discussions**: [GitHub Discussions](https://github.com/M1tsumi/Caelum/discussions)

---

## License

MIT — see [LICENSE](LICENSE).

---

*Keywords: objective-c, discord, discord-bot, discord-api, ios, macos, gateway, rest-api, bot-framework, discord-v10, sharding, interactions, webhooks*
