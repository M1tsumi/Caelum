#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface CLMRESTResponse : NSObject
@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong, nullable) id JSONObject;
@property (nonatomic, strong, nullable) NSError *error;
@property (nonatomic, copy, nullable) NSDictionary *responseHeaders;
@property (nonatomic, readonly) BOOL isSuccess;
@property (nonatomic, readonly) BOOL isError;
@property (nonatomic, readonly) BOOL isRateLimited;
@property (nonatomic, readonly) BOOL isUnauthorized;
@property (nonatomic, readonly, nullable) NSString *rateLimitBucket;
@property (nonatomic, readonly, nullable) NSNumber *rateLimitRemaining;
@property (nonatomic, readonly, nullable) NSNumber *rateLimitResetAfter;
@property (nonatomic, readonly) BOOL rateLimitGlobal;
@end
NS_ASSUME_NONNULL_END
