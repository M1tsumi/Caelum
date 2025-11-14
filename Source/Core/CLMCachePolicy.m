#import "CLMCachePolicy.h"

@implementation CLMCachePolicy
+ (instancetype)policyWithTTL:(NSTimeInterval)ttl maxItems:(NSUInteger)maxItems {
    CLMCachePolicy *p = [CLMCachePolicy new];
    p.timeToLive = ttl;
    p.maxItems = maxItems;
    return p;
}
@end
