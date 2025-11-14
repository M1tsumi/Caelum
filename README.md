# Caelum
Clean, fast, and fully Objective‑C‑native library for the Discord Gateway (v10) and REST API. Built for macOS & iOS projects that live in Objective‑C, with zero Swift dependencies, and first‑class Apple‑platform integration.

![Language](https://img.shields.io/badge/language-Objective%E2%80%91C-blue)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%7C%20macOS-lightgrey)
![Status](https://img.shields.io/badge/status-early--development-orange)
[![Changelog](https://img.shields.io/badge/docs-changelog-informational)](CHANGELOG.md)
 [![License: MIT](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![CI](https://github.com/M1tsumi/Caelum/actions/workflows/ci.yml/badge.svg)](https://github.com/M1tsumi/Caelum/actions/workflows/ci.yml)

<div align="center" style="margin: 8px 0 0 0;">
  <a href="https://discord.gg/KzFY5zEja4" target="_blank" rel="noopener noreferrer">
    <button style="background:#5865F2;color:#fff;border:none;border-radius:6px;padding:8px 14px;font-weight:600;cursor:pointer;">Join our Discord</button>
  </a>
  <br/>
</div>

> Note: Caelum is in active development. Public APIs may evolve prior to the first stable release.

## Features
- **Objective‑C first**. No Swift dependencies in the core library.
- **Gateway v10**. Identify, heartbeat (HELLO/ACK), intents, and dispatch routing.
- **REST client**. Core endpoints for application, user, channels, guilds, and sending messages.
- **Rate limits**. Per‑bucket handling, global 429 backoff, retries with jitter.
- **Threading**. Structured queues for I/O, parsing, and state mutation.
- **Extensible**. Protocols for logging, token provision, storage, and clock.

## Phase 4/5 Highlights
- **Application Emoji**: Models and REST CRUD helpers for application-scoped emojis.
- **Gateway Sharding**: `CLMShardManager` orchestrates multiple `CLMDiscordGatewayClient` instances.
- **Presence & Member Chunking**: Presence update (OP 3) and guild member chunk requests (OP 8).
- **Interactions & Components V2**: Buttons, Select Menus, Text Inputs (Modals), Action Rows.
- **Forum Channels & Tags**: Models and REST helpers.
- **Polls**: Poll models and message helpers.
- **Localization**: Locale constants and localized strings support.
- **AutoMod**: Rule, trigger, and action models.
- **Message Snapshots**: Helper to build rich embeds from message metadata.
- **Developer Experience**: `CLMCacheManager`/`CLMCachePolicy` and `CLMEventCenter` (block-based listeners).

## Requirements
- iOS 13+ or macOS 10.15+ (for `NSURLSessionWebSocketTask`).
- Xcode 15+ recommended.

## Installation
Packaging will be added as the API stabilizes. Planned support:
- CocoaPods
- Carthage
- Swift Package Manager (Objective‑C compatible)

## Quickstart
```objc
// Pseudo‑code (API surface may change)
#import <Caelum/CLMDiscordClient.h>

CLMClientConfiguration *config = [CLMClientConfiguration defaultConfiguration];
config.tokenProvider = myTokenProvider; // supply your bot token securely

CLMDiscordClient *client = [[CLMDiscordClient alloc] initWithConfiguration:config];
client.delegate = self; // adopt CLMDiscordClientDelegate / CLMGatewayEventDelegate

[client connectGatewayWithIntents:(CLMIntentGuilds | CLMIntentGuildMessages) error:NULL];

[client.rest sendMessage:@"Hello from Caelum" toChannel:channelID completion:^(NSError *error){
    if (error) NSLog(@"Send failed: %@", error);
}];
```

### Command routing (MEE6-style)
```objc
// Setup once
CLMCommandRouter *router = [[CLMCommandRouter alloc] initWithREST:client.rest gateway:client.gateway];
router.prefix = @"!";

// Minimal ping command
@interface PingCommand : NSObject <CLMCommand>
@end
@implementation PingCommand
- (NSString *)name { return @"ping"; }
- (NSString *)commandDescription { return @"Latency check"; }
- (NSArray<NSString *> *)aliases { return @[]; }
- (NSTimeInterval)cooldownSeconds { return 2; }
- (NSArray<NSString *> *)requiredPermissions { return @[]; }
- (void)executeWithContext:(CLMCommandContext *)context completion:(CLMCommandCompletion)completion {
  [context.rest sendMessageInChannel:context.channelId
                                json:@{ @"content": @"Pong!" }
                                files:nil
                           completion:^(__unused CLMRESTResponse *resp) { if (completion) completion(nil); }];
}
@end

[router registerCommand:[PingCommand new]];

// In your gateway dispatch handler for MESSAGE_CREATE:
// [router handleMessageCreatePayload:payload];
```

## Usage Examples
### Sharding with CLMShardManager
```objc
// Create N shards and start
CLMShardManager *shards = [[CLMShardManager alloc] initWithTokenProvider:provider
                                                              shardCount:4
                                                             gatewayURL:nil];
[shards startAllWithIntents:(CLMIntentGuilds | CLMIntentGuildMessages)];
```

### Event dispatch with CLMEventCenter
```objc
CLMEventCenter *events = [[CLMEventCenter alloc] init];
id token = [events addListenerForEvent:@"MESSAGE_CREATE" queue:dispatch_get_main_queue() block:^(NSDictionary *payload){
    NSLog(@"New message: %@", payload[@"id"]);
}];
// Later: [events removeListenerWithToken:token];
```

### Caching with CLMCacheManager
```objc
CLMCacheManager *cache = [[CLMCacheManager alloc] initWithPolicy:[CLMCachePolicy policyWithTTL:300 maxItems:1000]];
[cache setObject:@{ @"username": @"Ada" } forKey:@"user:123" namespace:@"users"];
NSDictionary *user = [cache objectForKey:@"user:123" namespace:@"users"];
```

### Application Emoji CRUD
```objc
// List application emojis
[client.rest listApplicationEmojis:applicationID completion:^(CLMRESTResponse *resp) { /* handle */ }];

// Create
CLMApplicationEmoji *emoji = [CLMApplicationEmoji new];
emoji.name = @"party";
emoji.imageBase64 = base64PNG; // data:image/png;base64,...
[client.rest createApplicationEmoji:applicationID json:[emoji toCreateJSON] completion:^(CLMRESTResponse *resp){ /* handle */ }];
```

## Usage notes
- Messages pagination: use `listMessagesInChannel:limit:before:after:` to page backward (supply last message ID to `before`).
- Guild members pagination: use `listMembersInGuild:limit:after:` and pass the last member ID to `after` for the next page.

## Coverage (Discord API v10)
- Users: current user, get user.
- Channels: get/modify/delete, typing, webhooks list/create/modify/delete, permission overwrites.
- Messages: list/send/edit/delete, reactions add/remove own, bulk delete, pins list/pin/unpin, attachments (multipart).
- Threads: start (from message/without), join/leave, add/remove member, list archived (public/private), list joined private, list active in guild.
- Guilds: get, list channels/members, roles list/create/delete, bans ban/unban, templates list/get/create/modify/sync/delete, welcome screen get/modify, onboarding get/modify, widget get/modify, vanity URL, integrations list, prune count/start.
- Emojis/Stickers: list/get/create/modify/delete.
- Invites: create/get/delete, list by channel/guild.
- Application commands: global/guild list/create/edit/delete.
- Audit log: fetch with filters.
- Scheduled events: list/create/modify/delete.
- Stage instances: create/modify/delete.
- Voice state: modify self/other in guild.
- Rate limits: 429 surfaced with retry headers in error userInfo.

### Additional Coverage (New)
- Interactions: callbacks, followups, modals (Text Inputs), components (Buttons, Select Menus, Action Rows).
- Forum channels and tags: create/modify via patch helpers.
- Polls: models and REST helpers for sending messages with polls, fetching voters.
- Application Emoji: full CRUD for application-scoped emojis.
- Gateway enhancements: sharding, presence update, guild member chunking.
- Localization: constants and localized strings model.
- AutoMod: rules, triggers, actions models.
- Message Snapshot: embed helper for link previews.
- Developer Experience: cache manager/policy, event center (block listeners).

## Examples
### Send a message with attachments
```objc
CLMRESTFilePart *file = [CLMRESTFilePart partWithField:@"files[0]" filename:@"hello.txt" mimeType:@"text/plain" data:[@"hi" dataUsingEncoding:NSUTF8StringEncoding]];
[client.rest sendMessageInChannel:channelID
                              json:@{ @"content": @"Hi with file" }
                              files:@[file]
                         completion:^(CLMRESTResponse *resp) { /* handle */ }];
```

### Start a thread from a message
```objc
[client.rest startThreadFromMessageInChannel:channelID
                                   messageID:messageID
                                         name:@"Topic"
                           autoArchiveDuration:@(60)
                             rateLimitPerUser:nil
                                    completion:^(CLMRESTResponse *resp){ /* handle */ }];
```

### Interaction followup: edit original response
```objc
[client.rest editOriginalInteractionResponseForApplication:applicationID
                                                     token:interactionToken
                                                      json:@{ @"content": @"Updated" }
                                                completion:^(CLMRESTResponse *resp){ /* handle */ }];
```

## advaith's Library Criteria (non-voice)
- ✅ Objective‑C native, no Swift deps
- ✅ Gateway v10 (Identify, heartbeats, dispatch)
- ✅ REST v10 coverage for core surfaces (users/channels/messages/threads/guilds/webhooks/commands)
- ✅ Rate limit handling with surfaced headers
- ✅ Interactions: components, modals, followups
- ✅ File uploads (multipart)
- ✅ Sharding support
- ✅ Caching layer and event listeners
- ✅ Forum channels, Polls, Localization, AutoMod
- ✅ Application Emoji management
- ⛔ Voice features intentionally not implemented yet

## Roadmap
See `plan.txt` for the detailed plan. High‑level milestones:
- M0: Scaffold, logging, error domain
- M1: REST MVP (auth, core endpoints, rate limits)
- M2: Gateway MVP (connect, identify, heartbeat, dispatch)
- M3: Stabilization, docs, examples
- M4: Packaging (Pods/Carthage/SPM) and CI

## Community
- Discord: https://discord.gg/KzFY5zEja4

## Contributing
Contributions are welcome after initial API stabilization. Please open issues for bugs and proposals. See `CHANGELOG.md` for release notes.



