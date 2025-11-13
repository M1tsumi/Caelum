# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project adheres to Semantic Versioning once stable.

## [Unreleased]
- Gateway: Implemented `NSURLSessionWebSocketTask` connection with JSON handling.
- Gateway: Added Identify flow and heartbeat loop (HELLO/ACK), basic Dispatch routing.
- REST: Massive coverage expansion for Discord v10:
  - Users, Applications (commands CRUD global/guild)
  - Channels (get/modify/delete, typing), Webhooks (list/create/modify/delete)
  - Messages (list/send/edit/delete, reactions own add/remove, bulk delete, pins list/pin/unpin)
  - Messages with attachments (multipart): send/edit; Webhook execute with files
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
  - Voice state modify self/other
- REST: Audit Log Reason header support on mutating endpoints (URL‑encoded).
- REST: 429 error surfaces rate limit headers (`Retry-After`, `X-RateLimit-*`) in error.userInfo.
- REST: Multipart/form-data support with `payload_json` and file parts.
- Tests: Added XCTest harness with MockURLProtocol. Added tests for success, JSON decode error, status mapping (401/429/5xx), audit log header.
- README: Added coverage summary and examples (multipart, threads, followups).
- Project: `.gitignore` updated for Xcode/Obj‑C; `plan.txt` ignored.

## [Unreleased] - 2025-11-13
### Added
- Initial repository setup.
- High-level project plan for an Objective-C Discord API wrapper.
- Draft README with features, requirements, installation plan, and quickstart.

[Unreleased]: https://github.com/M1tsumi/Caelum/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/M1tsumi/Caelum/releases/tag/v0.1.0
