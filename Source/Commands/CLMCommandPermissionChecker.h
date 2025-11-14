#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CLMCommandPermissionChecker <NSObject>
- (BOOL)userId:(NSString *)userId
       hasPermissions:(NSArray<NSString *> *)requiredPermissions
              inGuild:(nullable NSString *)guildId
                error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
