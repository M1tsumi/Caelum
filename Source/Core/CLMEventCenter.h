#import <Foundation/Foundation.h>

typedef NSString * CLMEventToken;

@interface CLMEventListener : NSObject
@property (nonatomic, copy) NSString *eventName;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, copy) void (^block)(id payload);
@property (nonatomic, copy) CLMEventToken token;
@end

@interface CLMEventCenter : NSObject
+ (instancetype)shared;
- (CLMEventToken)addListenerForEvent:(NSString *)eventName queue:(dispatch_queue_t)queue block:(void (^)(id payload))block;
- (void)removeListenerWithToken:(CLMEventToken)token;
- (void)postEvent:(NSString *)eventName payload:(id)payload;
@end
