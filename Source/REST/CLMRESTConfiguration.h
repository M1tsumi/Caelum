#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@protocol CLMTokenProvider <NSObject>
- (nullable NSString *)botToken;
@end
@interface CLMRESTConfiguration : NSObject
@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, weak, nullable) id<CLMTokenProvider> tokenProvider;
@property (nonatomic) NSTimeInterval timeout;
+ (instancetype)defaultConfiguration;
@end
NS_ASSUME_NONNULL_END
