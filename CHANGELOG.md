# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project adheres to Semantic Versioning once stable.

## [v0.2.0 - 2025-11-16]
### Added
- REST: Full Discord v10 endpoint parity (non-voice) — ~50 new endpoints:
  - User: modify profile, guilds list, create DM, leave guild, guild member
  - Channel: get single message, follow news channel, group DM CRUD, voice status
  - Guild: preview, channel reorder, add member, self-nick, message search,
    modify/get individual role, role member counts, voice regions,
    delete integration, bulk ban, member screening, incident actions
  - Application: edit application, bulk overwrite commands, get single command,
    command permissions (list/batch/get/edit for global & guild)
  - Gateway info, OAuth2, Sticker Packs, Webhooks (Slack/GitHub/get),
    Role Connection Metadata, Voice Regions, Voice State GET,
    Scheduled Event GET, Expire Poll
- Intents: Added `CLMIntentGuildMessagePolls` (1 << 24) and
  `CLMIntentDirectMessagePolls` (1 << 25)
- Error codes: `CLMErrorBadRequest` (5), `CLMErrorForbidden` (6),
  `CLMErrorNotFound` (8), `CLMErrorWebSocket` (9)
- Error factory: `CLMErrorMake()` function for consistent NSError creation
- Logging: `CLMLogLevel` enum (Debug/Info/Warning/Error), `CLMLog()` macro
  with automatic source location and level filtering
- Logger injection: `logger` property on `CLMDiscordClient`,
  `CLMDiscordRESTClient`, and `CLMCommandRouter`
- Logging: Request/response logging throughout REST client lifecycle,
  command routing events, rate limit detection
- CommandRouter: `CLMCommandRouterDelegate` protocol with callbacks for
  handled/failed/rejected commands
- RESTResponse: `isSuccess`, `isError`, `isRateLimited`, `isUnauthorized`
  convenience properties plus rate limit header accessors
- RESTConfig: `botToken` property for direct token assignment without
  implementing CLMTokenProvider protocol
- CommandContext: `replyWithContent:`, `replyWithJSON:`, `replyDeferred`
  convenience methods for common interaction responses
- Errors: `CLMErrorCodeForHTTPStatus()` helper function
### Changed
- CLMErrors domain uses `CLMErrorDomain` constant throughout all files
  (was hardcoded `@"com.caelum.discord"` string in gateway client)
- Gateway reconnect delay made configurable via `reconnectDelay` property
- Umbrella headers synced between `Source/Caelum.h` and SwiftPM variant
- CLMDefaultLogger format: `[LEVEL] file:line function - message`
### Fixed
- `_session` ivar shadowing in CLMDiscordRESTClient (nil URLSession bug)
- Missing `Content-Type: application/json` header for JSON-only requests
- Rate limiter stub replaced with real bucket/global tracking
- Cooldown manager never recorded command executions
- `NSNull` crash risk in `CLMModalBuilder.addTextInput:`
- `CLMAutoModTrigger` missing spam trigger type handling
- Hardcoded error domains in gateway client replaced with constant
- All errors now wrapped in `CLMErrorDomain` (JSON serialization errors
  were previously bare NSCocoaErrorDomain)

## [v0.1.1 - 2025-11-15]
### Added
- Gateway: READY session capture, RESUME (OP 6), RECONNECT (OP 7), INVALID_SESSION (OP 9) with 1–4s jitter re-identify, and auto-reconnect behavior.
- REST: Additional v10 endpoints for parity (non-voice):
  - Guild bans list/get
  - Webhooks: list in guild, get (id), get/modify/delete with token, execute options (thread_id, wait)
  - Reactions: list users, remove user, delete all, delete all for emoji
  - Threads: get/list thread members
  - Messages: crosspost
  - Scheduled events: list users
  - Stage instances: get
  - Stickers: list sticker packs
### Changed
- README: Added full Coverage Matrix for REST v10 and Gateway v10; expanded Gateway details; clarified voice send/receive exclusion.
- REST headers: fixed stray top-of-file declaration in `CLMDiscordRESTClient.h`.

## [v0.1.0 - 2025-11-14]
### Added
- Gateway: Implemented `NSURLSessionWebSocketTask` connection with JSON handling.
- Gateway: Identify flow and heartbeat loop (HELLO/ACK); dispatch routing.
- Gateway: Sharding via `CLMShardManager`; shard-aware delegate methods.
- Gateway: Presence update (OP 3) and guild member chunk requests (OP 8).
- REST: v10 coverage expansion:
  - Users, Applications (commands CRUD global/guild)
  - Channels (get/modify/delete, typing), Webhooks (list/create/modify/delete)
  - Messages (list/send/edit/delete, reactions own add/remove, bulk delete, pins list/pin/unpin)
  - Multipart attachments for messages and webhooks
  - Permission overwrites
  - Threads (start/join/leave/add/remove member; list archived public/private, joined private; list active in guild)
  - Guilds (get, list channels/members, roles list/create/delete, bans ban/unban)
  - Guild management (prune count/start, widget get/modify, vanity URL, integrations list)
  - Templates list/get/create/modify/sync/delete; Welcome Screen get/modify; Onboarding get/modify
  - Emojis/Stickers list/get/create/modify/delete
  - Invites create/get/delete, list by channel/guild
  - Audit log fetch with filters
  - Scheduled events list/create/modify/delete
  - Stage instances create/modify/delete
  - Voice state modify self/other (voice features otherwise pending)
- Interactions & Components V2: Buttons, Select Menus, Text Inputs (Modals), Action Rows; interaction callbacks.
- Forum Channels & Tags: Models and REST helpers.
- Polls: Models, send message with poll, fetch voters.
- Localization: `CLMLocale` and `CLMLocalizedString`.
- AutoMod: Rules, triggers, actions models.
- Message Snapshot: Embed helper for link previews.
- Application Emoji: Models and REST CRUD helpers for application-scoped emojis.
- Developer Experience: `CLMCacheManager`/`CLMCachePolicy` caching and `CLMEventCenter` (block-based listeners).

### Changed
- README: Added Phase 4/5 highlights, examples (sharding, events, caching, application emoji), and criteria checklist.

### Fixed
- Documentation and minor typos across public headers.

## [Unreleased] - 2025-11-13
### Added
- Initial repository setup.
- High-level project plan for an Objective-C Discord API wrapper.
- Draft README with features, requirements, installation plan, and quickstart.

[0.1.1]: https://github.com/M1tsumi/Caelum/releases/tag/v0.1.1
[0.1.0]: https://github.com/M1tsumi/Caelum/releases/tag/v0.1.0
