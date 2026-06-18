#import "CLMRESTResponse.h"
#import "../Core/CLMErrors.h"

@implementation CLMRESTResponse

- (BOOL)isSuccess { return self.statusCode >= 200 && self.statusCode < 300 && !self.error; }

- (BOOL)isError { return self.error != nil || self.statusCode >= 400; }

- (BOOL)isRateLimited { return self.statusCode == 429; }

- (BOOL)isUnauthorized { return self.statusCode == 401; }

- (nullable NSString *)rateLimitBucket {
    return self.responseHeaders[@"X-RateLimit-Bucket"] ?: self.responseHeaders[@"x-ratelimit-bucket"];
}

- (nullable NSNumber *)rateLimitRemaining {
    NSString *v = self.responseHeaders[@"X-RateLimit-Remaining"] ?: self.responseHeaders[@"x-ratelimit-remaining"];
    return v ? @(v.integerValue) : nil;
}

- (nullable NSNumber *)rateLimitResetAfter {
    NSString *v = self.responseHeaders[@"X-RateLimit-Reset-After"] ?: self.responseHeaders[@"x-ratelimit-reset-after"];
    return v ? @(v.doubleValue) : nil;
}

- (BOOL)rateLimitGlobal {
    return (self.responseHeaders[@"X-RateLimit-Global"] ?: self.responseHeaders[@"x-ratelimit-global"]) != nil;
}

@end
