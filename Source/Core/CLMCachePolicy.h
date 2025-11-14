#import <Foundation/Foundation.h>

@interface CLMCachePolicy : NSObject
@property (nonatomic, assign) NSTimeInterval timeToLive; // seconds; 0 = no TTL
@property (nonatomic, assign) NSUInteger maxItems; // 0 = unbounded
+ (instancetype)policyWithTTL:(NSTimeInterval)ttl maxItems:(NSUInteger)maxItems;
@end
