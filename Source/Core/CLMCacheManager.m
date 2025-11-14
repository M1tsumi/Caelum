#import "CLMCacheManager.h"

@interface CLMCacheManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSMutableDictionary<NSString*, CLMCacheEntry*>*> *namespaces;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation CLMCacheEntry
@end

@implementation CLMCacheManager

- (instancetype)initWithPolicy:(CLMCachePolicy *)policy {
    if ((self = [super init])) {
        _policy = policy ?: [CLMCachePolicy policyWithTTL:0 maxItems:0];
        _namespaces = [NSMutableDictionary new];
        _queue = dispatch_queue_create("io.caelum.cache", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSMutableDictionary<NSString*, CLMCacheEntry*> *)bucketForNamespace:(NSString *)ns create:(BOOL)create {
    __block NSMutableDictionary *bucket = nil;
    dispatch_barrier_sync(self.queue, ^{
        bucket = self.namespaces[ns];
        if (!bucket && create) {
            bucket = [NSMutableDictionary new];
            self.namespaces[ns] = bucket;
        }
    });
    return bucket;
}

- (void)setObject:(id)obj forKey:(NSString *)key inNamespace:(NSString *)ns {
    if (!obj || key.length == 0 || ns.length == 0) return;
    dispatch_barrier_async(self.queue, ^{
        NSMutableDictionary *bucket = self.namespaces[ns];
        if (!bucket) { bucket = [NSMutableDictionary new]; self.namespaces[ns] = bucket; }
        if (self.policy.maxItems > 0 && bucket.count >= self.policy.maxItems) {
            // simple eviction: remove oldest
            __block NSString *oldestKey = nil; __block NSDate *oldestDate = [NSDate date];
            [bucket enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull k, CLMCacheEntry * _Nonnull entry, BOOL * _Nonnull stop) {
                if (!entry.insertedAt || [entry.insertedAt compare:oldestDate] == NSOrderedAscending) { oldestDate = entry.insertedAt ?: [NSDate distantPast]; oldestKey = k; }
            }];
            if (oldestKey) [bucket removeObjectForKey:oldestKey];
        }
        CLMCacheEntry *entry = [CLMCacheEntry new];
        entry.value = obj; entry.insertedAt = [NSDate date];
        bucket[key] = entry;
    });
}

- (id)objectForKey:(NSString *)key inNamespace:(NSString *)ns {
    if (key.length == 0 || ns.length == 0) return nil;
    __block id value = nil;
    dispatch_sync(self.queue, ^{
        NSMutableDictionary *bucket = self.namespaces[ns];
        CLMCacheEntry *entry = bucket[key];
        if (!entry) return;
        if (self.policy.timeToLive > 0 && entry.insertedAt) {
            NSTimeInterval age = -[entry.insertedAt timeIntervalSinceNow];
            if (age > self.policy.timeToLive) {
                [bucket removeObjectForKey:key];
                return;
            }
        }
        value = entry.value;
    });
    return value;
}

- (void)removeObjectForKey:(NSString *)key inNamespace:(NSString *)ns {
    if (key.length == 0 || ns.length == 0) return;
    dispatch_barrier_async(self.queue, ^{
        [self.namespaces[ns] removeObjectForKey:key];
    });
}

- (void)removeAllInNamespace:(NSString *)ns {
    if (ns.length == 0) return;
    dispatch_barrier_async(self.queue, ^{
        [self.namespaces removeObjectForKey:ns];
    });
}

- (void)pruneExpired {
    if (self.policy.timeToLive <= 0) return;
    dispatch_barrier_async(self.queue, ^{
        [self.namespaces enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull ns, NSMutableDictionary<NSString *,CLMCacheEntry *> * _Nonnull bucket, BOOL * _Nonnull stop) {
            NSMutableArray *expired = [NSMutableArray new];
            [bucket enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull k, CLMCacheEntry * _Nonnull entry, BOOL * _Nonnull stop2) {
                NSTimeInterval age = -[entry.insertedAt timeIntervalSinceNow];
                if (age > self.policy.timeToLive) { [expired addObject:k]; }
            }];
            [bucket removeObjectsForKeys:expired];
        }];
    });
}

@end
