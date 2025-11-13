#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface CLMRESTFilePart : NSObject
@property (nonatomic, copy) NSString *fieldName; // e.g., files[0]
@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSString *mimeType;
@property (nonatomic, strong) NSData *data;
+ (instancetype)partWithField:(NSString *)fieldName filename:(NSString *)filename mimeType:(NSString *)mimeType data:(NSData *)data;
@end
@interface CLMRESTRequest : NSObject
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *route;
@property (nonatomic, strong, nullable) NSDictionary *jsonBody;
@property (nonatomic, copy, nullable) NSString *auditLogReason; // X-Audit-Log-Reason
@property (nonatomic, strong, nullable) NSArray<CLMRESTFilePart *> *files; // multipart
+ (instancetype)requestWithMethod:(NSString *)method route:(NSString *)route;
@end
NS_ASSUME_NONNULL_END
