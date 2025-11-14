#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLMCommandCooldownManager : NSObject
- (instancetype)initWithQueue:(dispatch_queue_t)queue;
- (BOOL)canExecuteCommand:(NSString *)commandName userId:(NSString *)userId cooldown:(NSTimeInterval)cooldownSeconds now:(NSTimeInterval)now;
- (void)recordExecutionForCommand:(NSString *)commandName userId:(NSString *)userId at:(NSTimeInterval)now;
@end

NS_ASSUME_NONNULL_END
