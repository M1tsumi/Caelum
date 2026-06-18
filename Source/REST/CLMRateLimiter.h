#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface CLMRateLimiter : NSObject
- (void)enqueueRoute:(NSString *)route perform:(void (^)(void))block;
- (void)updateBucket:(NSString *)bucket remaining:(NSInteger)remaining resetAfter:(NSTimeInterval)resetAfter isGlobal:(BOOL)isGlobal;
@end
NS_ASSUME_NONNULL_END
