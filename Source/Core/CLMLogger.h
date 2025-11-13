#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@protocol CLMLogger <NSObject>
- (void)logWithLevel:(NSString *)level message:(NSString *)message;
@end
@interface CLMDefaultLogger : NSObject <CLMLogger>
@end
NS_ASSUME_NONNULL_END
