#import "CLMLogger.h"

static NSString *CLMLogLevelToString(CLMLogLevel level) {
    switch (level) {
        case CLMLogLevelDebug:   return @"DEBUG";
        case CLMLogLevelInfo:    return @"INFO";
        case CLMLogLevelWarning: return @"WARN";
        case CLMLogLevelError:   return @"ERROR";
    }
}

@implementation CLMDefaultLogger
- (void)logWithLevel:(CLMLogLevel)level message:(NSString *)message file:(const char *)file line:(int)line function:(const char *)function {
    NSString *f = file ? [@(file) lastPathComponent] : @"?";
    NSString *fn = function ? @(function) : @"?";
    NSLog(@"[%@] %@:%d %@ - %@", CLMLogLevelToString(level), f, line, fn, message);
}
- (BOOL)shouldLogForLevel:(CLMLogLevel)level {
    return level >= CLMLogLevelInfo;
}
@end
