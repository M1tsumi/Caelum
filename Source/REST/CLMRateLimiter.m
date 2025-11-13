#import "CLMRateLimiter.h"
@implementation CLMRateLimiter
- (void)enqueueRoute:(NSString *)route perform:(void (^)(void))block { if (block) block(); }
@end
