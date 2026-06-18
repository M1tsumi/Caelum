# Logging

**Protocol:** `CLMLogger`  
**Header:** `Core/CLMLogger.h`

## Log Levels

```objc
typedef NS_ENUM(NSUInteger, CLMLogLevel) {
    CLMLogLevelDebug = 0,   // verbose diagnostics
    CLMLogLevelInfo = 1,    // normal operational messages
    CLMLogLevelWarning = 2, // something unexpected but recoverable
    CLMLogLevelError = 3,   // failures
};
```

## Logger Protocol

```objc
@protocol CLMLogger <NSObject>
- (void)logWithLevel:(CLMLogLevel)level
             message:(NSString *)message
                file:(const char *)file
                line:(int)line
            function:(const char *)function;
@optional
- (BOOL)shouldLogForLevel:(CLMLogLevel)level;
@end
```

## CLMLog() Macro

```objc
#define CLMLog(_logger, _level, _fmt, ...)
```

Usage:
```objc
CLMLog(self.logger, CLMLogLevelDebug, @"Sending %@ %@", method, route);
CLMLog(self.logger, CLMLogLevelError, @"Request failed: %@", error.localizedDescription);
```

The macro:
- Checks if logger is non-nil
- Calls `shouldLogForLevel:` if implemented (skips logging if returns NO)
- Automatically passes `__FILE__`, `__LINE__`, `__PRETTY_FUNCTION__`
- Supports format strings with variable arguments

## Default Logger

```objc
@interface CLMDefaultLogger : NSObject <CLMLogger>
@end
```

Output format:
```
[LEVEL] file:line function - message
```

Example:
```
[INFO] CLMDiscordRESTClient.m:94 -[CLMDiscordRESTClient performRequest:completion:] - channels/123/messages -> 200
```

Default `shouldLogForLevel:` returns YES for `CLMLogLevelInfo` and above (suppresses Debug).

## Custom Logger Implementation

```objc
@interface MyOSLogLogger : NSObject <CLMLogger>
@end
@implementation MyOSLogLogger
- (void)logWithLevel:(CLMLogLevel)level message:(NSString *)message
                file:(const char *)file line:(int)line function:(const char *)function {
    os_log_with_type(OS_LOG_DEFAULT,
                     level >= CLMLogLevelError ? OS_LOG_TYPE_ERROR : OS_LOG_TYPE_DEFAULT,
                     "%{public}@", message);
}
- (BOOL)shouldLogForLevel:(CLMLogLevel)level {
    return YES; // log everything
}
@end
```

## Injection Points

Set the logger on these objects:

```objc
client.logger = [CLMDefaultLogger new];            // CLMDiscordClient
client.rest.logger = client.logger;                // CLMDiscordRESTClient (auto if not set)

CLMCommandRouter *router = [[CLMCommandRouter alloc] initWithREST:... gateway:...];
router.logger = client.logger;
```

If you set `client.logger`, it propagates to the REST client. Command routers need their logger set separately.
