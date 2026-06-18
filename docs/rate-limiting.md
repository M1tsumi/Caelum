# Rate Limiting

**Class:** `CLMRateLimiter`  
**Header:** `REST/CLMRateLimiter.h`

Per-bucket and global rate limit tracker. Used internally by `CLMDiscordRESTClient`.

## Interface

```objc
@interface CLMRateLimiter : NSObject
- (void)enqueueRoute:(NSString *)route perform:(void (^)(void))block;
- (void)updateBucket:(NSString *)bucket remaining:(NSInteger)remaining
          resetAfter:(NSTimeInterval)resetAfter isGlobal:(BOOL)isGlobal;
@end
```

## Behavior

- **Per-bucket tracking**: Each route maps to a bucket. When `remaining` reaches 0, subsequent requests to that bucket are delayed until `resetAfter` seconds have passed.
- **Global backoff**: If the API signals a global rate limit, all requests across all routes are delayed.
- **Thread-safe**: All bucket state mutations happen on a serial queue.
- **Automatic**: The REST client calls `enqueueRoute:perform:` before each request and `updateBucket:remaining:resetAfter:isGlobal:` after receiving a response with rate limit headers.

## Response Headers

Discord's rate limit headers are exposed through `CLMRESTResponse`:

```objc
resp.rateLimitBucket        // X-RateLimit-Bucket
resp.rateLimitRemaining     // X-RateLimit-Remaining
resp.rateLimitResetAfter    // X-RateLimit-Reset-After
resp.rateLimitGlobal        // X-RateLimit-Global present
```

And in the error userInfo on 429:

```objc
resp.error.userInfo[@"retry_after"]
resp.error.userInfo[@"x-ratelimit-bucket"]
resp.error.userInfo[@"x-ratelimit-global"]
```
