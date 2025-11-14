# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project adheres to Semantic Versioning once stable.

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

[Unreleased]: https://github.com/M1tsumi/Caelum/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/M1tsumi/Caelum/releases/tag/v0.1.0

