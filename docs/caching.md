# Caching

**Classes:** `CLMCacheManager`, `CLMCachePolicy`  
**Header:** `Core/CLMCacheManager.h`

Thread-safe in-memory cache with TTL, max items, and LRU eviction.

## Cache Policy

```objc
@interface CLMCachePolicy : NSObject
@property (nonatomic) NSTimeInterval defaultTTL; // seconds (default: 300)
@property (nonatomic) NSInteger maxItems;         // default: 1000

+ (instancetype)policyWithTTL:(NSTimeInterval)ttl maxItems:(NSInteger)maxItems;
@end
```

## Cache Manager

```objc
@interface CLMCacheManager : NSObject
- (instancetype)initWithPolicy:(CLMCachePolicy *)policy;

- (void)setObject:(id)obj forKey:(NSString *)key inNamespace:(NSString *)ns;
- (id)objectForKey:(NSString *)key inNamespace:(NSString *)ns;
- (void)removeObjectForKey:(NSString *)key inNamespace:(NSString *)ns;
- (void)removeAllInNamespace:(NSString *)ns;
- (void)pruneExpired;
@end
```

Cache operations use a concurrent queue with barrier writes for thread safety.

## Example

```objc
CLMCachePolicy *policy = [CLMCachePolicy policyWithTTL:300 maxItems:1000];
CLMCacheManager *cache = [[CLMCacheManager alloc] initWithPolicy:policy];

[cache setObject:userData forKey:@"user:123456" namespace:@"users"];
NSDictionary *user = [cache objectForKey:@"user:123456" namespace:@"users"];
if (user) {
    // cache hit
} else {
    // cache miss or expired -- fetch from API
}
```
