#import <Foundation/Foundation.h>
#import "CLMRESTConfiguration.h"
#import "CLMGatewayConfiguration.h"
NS_ASSUME_NONNULL_BEGIN
@interface CLMClientConfiguration : NSObject
@property (nonatomic, strong) CLMRESTConfiguration *restConfiguration;
@property (nonatomic, strong) CLMGatewayConfiguration *gatewayConfiguration;
+ (instancetype)defaultConfiguration;
@end
NS_ASSUME_NONNULL_END
