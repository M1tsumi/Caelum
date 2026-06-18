#import "CLMRateLimiter.h"

@interface CLMRateLimiter ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSDate *> *bucketResetAt;
@property (nonatomic, strong, nullable) NSDate *globalResetAt;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation CLMRateLimiter

- (instancetype)init {
    if ((self = [super init])) {
        _bucketResetAt = [NSMutableDictionary dictionary];
        _queue = dispatch_queue_create("com.caelum.ratelimiter", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)enqueueRoute:(NSString *)route perform:(void (^)(void))block {
    dispatch_async(self.queue, ^{
        if (self.globalResetAt && [self.globalResetAt timeIntervalSinceNow] > 0) {
            NSTimeInterval wait = [self.globalResetAt timeIntervalSinceNow];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(wait * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
            return;
        }
        NSString *bucket = [self bucketForRoute:route];
        NSDate *resetAt = self.bucketResetAt[bucket];
        if (resetAt && [resetAt timeIntervalSinceNow] > 0) {
            NSTimeInterval wait = [resetAt timeIntervalSinceNow];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(wait * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
            return;
        }
        dispatch_async(dispatch_get_main_queue(), block);
    });
}

- (void)updateBucket:(NSString *)bucket remaining:(NSInteger)remaining resetAfter:(NSTimeInterval)resetAfter isGlobal:(BOOL)isGlobal {
    dispatch_async(self.queue, ^{
        if (isGlobal) {
            if (remaining == 0 && resetAfter > 0) {
                self.globalResetAt = [NSDate dateWithTimeIntervalSinceNow:resetAfter];
            } else {
                self.globalResetAt = nil;
            }
        } else if (bucket.length > 0) {
            if (remaining == 0 && resetAfter > 0) {
                self.bucketResetAt[bucket] = [NSDate dateWithTimeIntervalSinceNow:resetAfter];
            } else {
                [self.bucketResetAt removeObjectForKey:bucket];
            }
        }
    });
}

- (NSString *)bucketForRoute:(NSString *)route {
    return [route componentsSeparatedByString:@"/"].firstObject ?: route;
}

@end
