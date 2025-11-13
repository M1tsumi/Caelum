# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project adheres to Semantic Versioning once stable.

## [Unreleased]
- Gateway: Implemented `NSURLSessionWebSocketTask` connection with JSON handling.
- Gateway: Added Identify flow and heartbeat loop (HELLO/ACK), basic Dispatch routing.
- REST: Added convenience endpoints — `users/@me`, `applications/@me`, `channels/{id}`, `guilds/{id}`, `channels/{id}/messages` (send).
- REST: Channels — modify channel (name/topic), delete channel, trigger typing, list/create webhooks.
- REST: Guilds — list channels, list members (paginated with limit/after).
- REST: Added Audit Log Reason header support on mutating endpoints.
- REST: Added pagination helpers: `CLMMessagesPaginator`, `CLMMembersPaginator`.
- REST: Error mapping to `CLMErrorDomain` codes for network/decode/auth/429/server.
- Packaging: Added Swift Package manifest (`Package.swift`).
- CI: Added GitHub Actions workflow (macOS) to build via SwiftPM.
- README: Professionalized with badges (Language, Platforms, Status, Changelog, Discord, License, CI) and Quickstart.
- Project: `.gitignore` updated for Xcode/Obj‑C; `plan.txt` ignored.

## [0.1.0] - 2025-11-13
### Added
- Initial repository setup.
- High-level project plan for an Objective-C Discord API wrapper.
- Draft README with features, requirements, installation plan, and quickstart.

[Unreleased]: https://github.com/M1tsumi/Caelum/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/M1tsumi/Caelum/releases/tag/v0.1.0
