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


## Community
- Discord: https://discord.gg/KzFY5zEja4

## Contributing
Contributions are welcome after initial API stabilization. Please open issues for bugs and proposals. See `CHANGELOG.md` for release notes.



