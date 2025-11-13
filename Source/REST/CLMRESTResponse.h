#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface CLMRESTResponse : NSObject
@property (nonatomic) NSInteger statusCode;
@property (nonatomic, strong, nullable) id JSONObject;
@property (nonatomic, strong, nullable) NSError *error;
@end
NS_ASSUME_NONNULL_END
