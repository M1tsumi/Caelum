# Caelum - Discord API Wrapper for Objective-C

**Objective-C Discord Bot Library | Discord Gateway v10 | iOS & macOS**

Clean, fast, and native Objective-C library for Discord bots and applications. Built for iOS and macOS developers who want full Discord API v10 integration without Swift dependencies.

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

> **Note:** Caelum is actively maintained and evolving. APIs may change before v1.0.

---

## Why Caelum?

Caelum fills a unique gap in the Discord development ecosystem by providing a **pure Objective-C solution** for building Discord bots and applications on Apple platforms. Unlike other libraries that require Swift or cross-platform runtimes, Caelum delivers native performance with zero external language dependencies.

**Perfect for:**
- Legacy iOS/macOS projects that use Objective-C
- Developers preferring Objective-C's messaging syntax
- Apps requiring native Apple framework integration
- Projects needing guaranteed Swift-free dependencies

---

## Core Features

### Gateway & Real-Time Communication
- **Discord Gateway v10** - Full implementation with automatic reconnection
- **Sharding Support** - Scale to thousands of guilds with `CLMShardManager`
- **Heartbeat Management** - Automatic keep-alive with latency tracking
- **Session Resume** - Seamless reconnection after network interruptions
- **Presence Updates** - Set bot status, activity, and online state
- **Member Chunking** - Request guild member lists efficiently

### REST API Coverage
- **Messages** - Send, edit, delete with file attachments and embeds
- **Channels** - Full CRUD operations including threads and forums
- **Guilds** - Member management, roles, bans, webhooks
- **Interactions** - Slash commands, buttons, select menus, modals
- **Application Commands** - Register and manage bot commands
- **Webhooks** - Create and execute webhooks with rate limiting
- **Polls** - Create and manage message polls
- **AutoMod** - Configure automated moderation rules

### Developer Tools
- **Rate Limit Handler** - Per-bucket tracking with automatic retry and jitter
- **Cache System** - `CLMCacheManager` with TTL and size policies
- **Event Center** - Block-based event listeners for clean code organization
- **Command Router** - MEE6-style prefix commands with cooldowns and permissions
- **Type-Safe Models** - Comprehensive Objective-C models for all Discord objects

### Modern Bot Features
- **Components** - Interactive buttons, select menus, and action rows
- **Modals** - Text input forms for user data collection
- **Application Emojis** - Manage bot-specific custom emojis
- **Forum Channels** - Create and manage forum posts with tags
- **Localization** - Multi-language command support

---

## Requirements

- **iOS 13.0+** or **macOS 10.15+** (for `NSURLSessionWebSocketTask`)
- **Xcode 15+** recommended
- **Apple Silicon or Intel Mac** with macOS and Xcode installed

> **Platform Note:** Caelum targets Apple platforms exclusively. Building on Windows or Linux is not supported due to Foundation framework requirements.

---

## Installation

### Swift Package Manager (Recommended)

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/M1tsumi/Caelum.git", from: "0.1.1")
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

Import in Objective-C:

```objc
#import <Caelum/Caelum.h>
```

### Other Package Managers

CocoaPods and Carthage support planned for future releases.

---

## Quick Start Guide

### Basic Discord Bot

```objc
#import <Caelum/Caelum.h>

// Configure the client
CLMClientConfiguration *config = [CLMClientConfiguration defaultConfiguration];
config.tokenProvider = myTokenProvider;

// Initialize
CLMDiscordClient *client = [[CLMDiscordClient alloc] initWithConfiguration:config];
client.delegate = self;

// Connect with intents
[client connectGatewayWithIntents:(CLMIntentGuilds | CLMIntentGuildMessages) error:NULL];

// Send a message
[client.rest sendMessage:@"Hello from Caelum!" 
               toChannel:channelID 
              completion:^(NSError *error) {
    if (error) NSLog(@"Error: %@", error);
}];
```

### Command System

Build MEE6-style prefix commands with automatic cooldowns:

```objc
// Setup router
CLMCommandRouter *router = [[CLMCommandRouter alloc] initWithREST:client.rest 
                                                           gateway:client.gateway];
router.prefix = @"!";

// Create a ping command
@interface PingCommand : NSObject <CLMCommand>
@end

@implementation PingCommand
- (NSString *)name { return @"ping"; }
- (NSString *)commandDescription { return @"Check bot latency"; }
- (NSTimeInterval)cooldownSeconds { return 2; }

- (void)executeWithContext:(CLMCommandContext *)ctx 
                completion:(CLMCommandCompletion)completion {
    [ctx.rest sendMessageInChannel:ctx.channelId
                              json:@{ @"content": @"🏓 Pong!" }
                             files:nil
                        completion:^(CLMRESTResponse *resp) {
        if (completion) completion(nil);
    }];
}
@end

// Register and route
[router registerCommand:[PingCommand new]];
```

### Multi-Guild Sharding

Scale your bot across thousands of servers:

```objc
CLMShardManager *shards = [[CLMShardManager alloc] 
    initWithTokenProvider:tokenProvider
               shardCount:4
               gatewayURL:nil];

[shards startAllWithIntents:(CLMIntentGuilds | CLMIntentGuildMessages)];
```

---

## Advanced Usage

### Event Handling with CLMEventCenter

```objc
CLMEventCenter *events = [[CLMEventCenter alloc] init];

id token = [events addListenerForEvent:@"MESSAGE_CREATE" 
                                 queue:dispatch_get_main_queue() 
                                 block:^(NSDictionary *payload) {
    NSString *content = payload[@"content"];
    NSLog(@"New message: %@", content);
}];

// Clean up when done
[events removeListenerWithToken:token];
```

### Caching Strategy

```objc
CLMCachePolicy *policy = [CLMCachePolicy policyWithTTL:300 maxItems:1000];
CLMCacheManager *cache = [[CLMCacheManager alloc] initWithPolicy:policy];

// Store user data
[cache setObject:@{ @"username": @"Developer" } 
          forKey:@"user:123456" 
       namespace:@"users"];

// Retrieve later
NSDictionary *user = [cache objectForKey:@"user:123456" namespace:@"users"];
```

### File Uploads & Rich Messages

```objc
// Create file attachment
NSData *imageData = [NSData dataWithContentsOfFile:@"/path/to/image.png"];
CLMRESTFilePart *file = [CLMRESTFilePart partWithField:@"files[0]" 
                                               filename:@"screenshot.png" 
                                               mimeType:@"image/png" 
                                                   data:imageData];

// Send with embed
NSDictionary *embed = @{
    @"title": @"Report",
    @"description": @"See attached screenshot",
    @"color": @0x3498db
};

[client.rest sendMessageInChannel:channelID
                             json:@{ @"embeds": @[embed] }
                            files:@[file]
                       completion:^(CLMRESTResponse *resp) { /* handle */ }];
```

### Thread Management

```objc
// Start a thread from a message
[client.rest startThreadFromMessageInChannel:channelID
                                   messageID:messageID
                                        name:@"Discussion"
                          autoArchiveDuration:@(1440)
                            rateLimitPerUser:nil
                                  completion:^(CLMRESTResponse *resp) {
    NSLog(@"Thread created: %@", resp.json[@"id"]);
}];
```

### Application Emoji Management

```objc
// Create custom emoji
CLMApplicationEmoji *emoji = [CLMApplicationEmoji new];
emoji.name = @"custom_emoji";
emoji.imageBase64 = @"data:image/png;base64,iVBORw0KGgo...";

[client.rest createApplicationEmoji:applicationID 
                               json:[emoji toCreateJSON] 
                         completion:^(CLMRESTResponse *resp) { /* handle */ }];
```

---

## API Coverage

### Discord Gateway v10

| Feature | Status |
|---------|--------|
| Identify (OP 2) | ✅ Complete |
| Heartbeat (OP 1) & ACK | ✅ Complete |
| Resume (OP 6) | ✅ Automatic |
| Reconnect (OP 7) | ✅ Automatic |
| Invalid Session (OP 9) | ✅ Handled |
| Sharding | ✅ Complete |
| Presence Update | ✅ Complete |
| Guild Member Chunk | ✅ Complete |

### REST API v10

<details>
<summary><strong>View Complete Coverage Matrix</strong></summary>

| Category | Endpoints | Status |
|----------|-----------|--------|
| **Users** | Get current user, Get user | ✅ |
| **Channels** | CRUD, typing, permissions | ✅ |
| **Messages** | Send, edit, delete, reactions, bulk delete | ✅ |
| **Threads** | Create, join, leave, archive | ✅ |
| **Guilds** | Get, modify, channels, members, roles | ✅ |
| **Webhooks** | List, create, execute, modify | ✅ |
| **Emojis** | Guild & application CRUD | ✅ |
| **Invites** | Create, get, delete | ✅ |
| **Commands** | Global & guild registration | ✅ |
| **Interactions** | Callbacks, followups, modals | ✅ |
| **Polls** | Create, fetch voters | ✅ |
| **AutoMod** | Rules, actions | ✅ |
| **Voice** | State modifications only* | ✅ |

*Voice media transport (audio send/receive) is not implemented.

</details>

---

## Best Practices

### Rate Limiting

Caelum automatically handles Discord's rate limits:

- Per-endpoint bucket tracking
- Global 429 backoff
- Exponential retry with jitter
- Rate limit headers exposed in error `userInfo`

### Pagination

```objc
// Messages (backward)
[client.rest listMessagesInChannel:channelID 
                             limit:100 
                            before:lastMessageID 
                             after:nil 
                        completion:^(CLMRESTResponse *resp) { /* handle */ }];

// Guild members (forward)
[client.rest listMembersInGuild:guildID 
                          limit:1000 
                          after:lastMemberID 
                     completion:^(CLMRESTResponse *resp) { /* handle */ }];
```

### Error Handling

```objc
[client.rest sendMessageInChannel:channelID 
                             json:messageData 
                            files:nil 
                       completion:^(CLMRESTResponse *resp) {
    if (resp.error) {
        if ([resp.error.domain isEqualToString:CLMRESTErrorDomain]) {
            NSInteger code = resp.error.code;
            // Check for rate limit, permission errors, etc.
        }
    }
}];
```

---

## Project Structure

```
Caelum/
├── Gateway/              # WebSocket connection, sharding
├── REST/                 # API endpoints, rate limiting
├── Models/               # Discord object models
├── Cache/                # Optional caching layer
├── Events/               # Event dispatch system
├── Commands/             # Command router framework
└── Utilities/            # Helpers, protocols
```

---

## Roadmap

- [x] Gateway v10 core operations
- [x] REST API comprehensive coverage
- [x] Sharding support
- [x] Interaction components
- [x] Application emojis
- [ ] Voice receive (planned)
- [ ] Audio playback (planned)
- [ ] CocoaPods distribution
- [ ] Comprehensive unit tests
- [ ] Performance benchmarks

---

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Follow existing code style
4. Add tests for new features
5. Submit a pull request

See [CHANGELOG.md](CHANGELOG.md) for recent updates.

---

## Community & Support

- **Discord Server**: [Join here](https://discord.gg/6nS2KqxQtj)
- **Issues**: [GitHub Issues](https://github.com/M1tsumi/Caelum/issues)
- **Discussions**: [GitHub Discussions](https://github.com/M1tsumi/Caelum/discussions)

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Keywords

`objective-c` `discord` `discord-bot` `discord-api` `discord-library` `ios` `macos` `gateway` `rest-api` `discord-api-wrapper` `bot-framework` `objective-c-library` `discord-v10` `sharding` `slash-commands` `interactions` `webhooks` `apple-platforms` `discord-objective-c`

