#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@protocol CLMClock <NSObject>
- (NSDate *)now;
@end
@interface CLMSystemClock : NSObject <CLMClock>
@end
NS_ASSUME_NONNULL_END
