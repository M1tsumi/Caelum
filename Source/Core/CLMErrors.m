#import "CLMErrors.h"
NSErrorDomain const CLMErrorDomain = @"com.caelum.discord";

NSError *CLMErrorMake(CLMErrorCode code, NSString *description, NSDictionary *extraUserInfo) {
    NSMutableDictionary *ui = [NSMutableDictionary dictionary];
    if (description.length > 0) ui[NSLocalizedDescriptionKey] = description;
    [ui addEntriesFromDictionary:extraUserInfo ?: @{}];
    return [NSError errorWithDomain:CLMErrorDomain code:code userInfo:[ui copy]];
}

CLMErrorCode CLMErrorCodeForHTTPStatus(NSInteger statusCode) {
    switch (statusCode) {
        case 400: return CLMErrorBadRequest;
        case 401: return CLMErrorUnauthorized;
        case 403: return CLMErrorForbidden;
        case 404: return CLMErrorNotFound;
        case 429: return CLMErrorRateLimited;
        default:
            if (statusCode >= 500) return CLMErrorServer;
            return CLMErrorUnknown;
    }
}
