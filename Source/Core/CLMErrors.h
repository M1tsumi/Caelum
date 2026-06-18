#import <Foundation/Foundation.h>
FOUNDATION_EXPORT NSErrorDomain const CLMErrorDomain;
typedef NS_ERROR_ENUM(CLMErrorDomain, CLMErrorCode) {
    CLMErrorUnknown = 0,
    CLMErrorNetwork = 1,
    CLMErrorDecode = 2,
    CLMErrorUnauthorized = 3,
    CLMErrorRateLimited = 4,
    CLMErrorBadRequest = 5,
    CLMErrorForbidden = 6,
    CLMErrorServer = 7,
    CLMErrorNotFound = 8,
    CLMErrorWebSocket = 9,
};
NSError *CLMErrorMake(CLMErrorCode code, NSString *description, NSDictionary * _Nullable extraUserInfo);
