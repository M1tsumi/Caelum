#import "CLMEventCenter.h"

@implementation CLMEventListener
@end

@interface CLMEventCenter ()
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSMutableArray<CLMEventListener*>*> *listeners;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation CLMEventCenter

+ (instancetype)shared {
    static CLMEventCenter *s;
    static dispatch_once_t onceToken; dispatch_once(&onceToken, ^{ s = [CLMEventCenter new]; });
    return s;
}

- (instancetype)init {
    if ((self = [super init])) {
        _listeners = [NSMutableDictionary new];
        _queue = dispatch_queue_create("io.caelum.events", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (CLMEventToken)addListenerForEvent:(NSString *)eventName queue:(dispatch_queue_t)queue block:(void (^)(id payload))block {
    if (eventName.length == 0 || !block) return nil;
    CLMEventListener *l = [CLMEventListener new];
    l.eventName = [eventName copy];
    l.queue = queue ?: dispatch_get_main_queue();
    l.block = [block copy];
    l.token = [[NSUUID UUID] UUIDString];
    dispatch_barrier_async(self.queue, ^{
        NSMutableArray *arr = self.listeners[eventName];
        if (!arr) { arr = [NSMutableArray new]; self.listeners[eventName] = arr; }
        [arr addObject:l];
    });
    return l.token;
}

- (void)removeListenerWithToken:(CLMEventToken)token {
    if (token.length == 0) return;
    dispatch_barrier_async(self.queue, ^{
        [self.listeners enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSMutableArray<CLMEventListener *> * _Nonnull arr, BOOL * _Nonnull stop) {
            NSUInteger idx = [arr indexOfObjectPassingTest:^BOOL(CLMEventListener * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop2) {
                return [obj.token isEqualToString:token];
            }];
            if (idx != NSNotFound) { [arr removeObjectAtIndex:idx]; *stop = YES; }
        }];
    });
}

- (void)postEvent:(NSString *)eventName payload:(id)payload {
    if (eventName.length == 0) return;
    dispatch_async(self.queue, ^{
        NSArray<CLMEventListener *> *arr = [self.listeners[eventName] copy];
        for (CLMEventListener *l in arr) {
            dispatch_async(l.queue, ^{ l.block(payload); });
        }
    });
}

@end
