# Caelum API Reference

Caelum is a native Objective-C wrapper around the Discord v10 REST API and Gateway.

## Modules

| Module | Header | Description |
|--------|--------|-------------|
| [REST Client](rest-client.md) | `CLMDiscordRESTClient.h` | All Discord REST v10 endpoints |
| [Gateway](gateway.md) | `CLMDiscordGatewayClient.h` | WebSocket connection, sharding, event dispatch |
| [Models](models.md) | `Models/*.h` | Discord object models (messages, guilds, components, etc.) |
| [Commands](commands.md) | `CLMCommandRouter.h` | Prefix command system with cooldowns and permissions |
| [Error Handling](error-handling.md) | `CLMErrors.h` | Error domain, codes, and factory |
| [Logging](logging.md) | `CLMLogger.h` | Logger protocol and `CLMLog()` macro |
| [Rate Limiting](rate-limiting.md) | `CLMRateLimiter.h` | Per-bucket and global rate limit tracking |
| [Caching](caching.md) | `CLMCacheManager.h` | In-memory cache with TTL and LRU eviction |
| [Events](events.md) | `CLMEventCenter.h` | Block-based event listener/dispatcher |

## Namespacing

All public classes are prefixed with `CLM` (CaeLuM).

## Umbrella Header

```objc
#import <Caelum/Caelum.h>
```
