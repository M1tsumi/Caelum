#import "CLMCommandCooldownManager.h"

@interface CLMCommandCooldownManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *lastExec; // key: command|user
@property (nonatomic) dispatch_queue_t queue;
@end

@implementation CLMCommandCooldownManager

- (instancetype)initWithQueue:(dispatch_queue_t)queue {
    if (self = [super init]) {
        _queue = queue ?: dispatch_queue_create("com.caelum.commands.cooldowns", DISPATCH_QUEUE_CONCURRENT);
        _lastExec = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)keyForCommand:(NSString *)command user:(NSString *)userId {
    return [NSString stringWithFormat:@"%@|%@", command, userId];
}

- (BOOL)canExecuteCommand:(NSString *)commandName userId:(NSString *)userId cooldown:(NSTimeInterval)cooldownSeconds now:(NSTimeInterval)now {
    if (cooldownSeconds <= 0) return YES;
    __block NSNumber *last;
    dispatch_sync(self.queue, ^{ last = self.lastExec[[self keyForCommand:commandName user:userId]]; });
    if (!last) return YES;
    return (now - last.doubleValue) >= cooldownSeconds;
}

- (void)recordExecutionForCommand:(NSString *)commandName userId:(NSString *)userId at:(NSTimeInterval)now {
    dispatch_barrier_async(self.queue, ^{ self.lastExec[[self keyForCommand:commandName user:userId]] = @(now); });
}

@end
