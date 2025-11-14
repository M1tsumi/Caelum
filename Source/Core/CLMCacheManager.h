#import <Foundation/Foundation.h>
#import "CLMCachePolicy.h"

@interface CLMCacheEntry : NSObject
@property (nonatomic, strong) id value;
@property (nonatomic, strong) NSDate *insertedAt;
@end

@interface CLMCacheManager : NSObject
@property (nonatomic, strong) CLMCachePolicy *policy;
- (instancetype)initWithPolicy:(CLMCachePolicy *)policy;
// Entity caches (generic): keys are string IDs
- (void)setObject:(id)obj forKey:(NSString *)key inNamespace:(NSString *)ns;
- (id)objectForKey:(NSString *)key inNamespace:(NSString *)ns; // returns nil if expired or missing
- (void)removeObjectForKey:(NSString *)key inNamespace:(NSString *)ns;
- (void)removeAllInNamespace:(NSString *)ns;
- (void)pruneExpired;
@end
