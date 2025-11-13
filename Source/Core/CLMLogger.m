#import "CLMLogger.h"
@implementation CLMDefaultLogger
- (void)logWithLevel:(NSString *)level message:(NSString *)message { NSLog(@"[%@] %@", level, message); }
@end
