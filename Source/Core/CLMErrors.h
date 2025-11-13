#import <Foundation/Foundation.h>
FOUNDATION_EXPORT NSErrorDomain const CLMErrorDomain;
typedef NS_ERROR_ENUM(CLMErrorDomain, CLMErrorCode) {
    CLMErrorUnknown = 0,
    CLMErrorNetwork = 1,
    CLMErrorDecode = 2,
    CLMErrorUnauthorized = 3,
    CLMErrorRateLimited = 4,
};
