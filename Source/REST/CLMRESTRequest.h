#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface CLMRESTRequest : NSObject
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *route;
@property (nonatomic, strong, nullable) NSDictionary *jsonBody;
@property (nonatomic, copy, nullable) NSString *auditLogReason; // X-Audit-Log-Reason
+ (instancetype)requestWithMethod:(NSString *)method route:(NSString *)route;
@end
NS_ASSUME_NONNULL_END
