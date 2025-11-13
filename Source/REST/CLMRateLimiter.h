#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface CLMRateLimiter : NSObject
- (void)enqueueRoute:(NSString *)route perform:(void (^)(void))block;
@end
NS_ASSUME_NONNULL_END
