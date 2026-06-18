#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CLMLogLevel) {
    CLMLogLevelDebug = 0,
    CLMLogLevelInfo = 1,
    CLMLogLevelWarning = 2,
    CLMLogLevelError = 3,
};

@protocol CLMLogger <NSObject>
- (void)logWithLevel:(CLMLogLevel)level message:(NSString *)message file:(const char *)file line:(int)line function:(const char *)function;
@optional
- (BOOL)shouldLogForLevel:(CLMLogLevel)level;
@end

#define CLMLog(_logger, _level, _fmt, ...) \
    do { \
        id<CLMLogger> __l = (_logger); \
        if (!__l || ([__l respondsToSelector:@selector(shouldLogForLevel:)] && ![__l shouldLogForLevel:(_level)])) break; \
        [__l logWithLevel:(_level) \
                  message:[NSString stringWithFormat:(_fmt), ##__VA_ARGS__] \
                     file:__FILE__ \
                     line:__LINE__ \
                 function:__PRETTY_FUNCTION__]; \
    } while(0)
