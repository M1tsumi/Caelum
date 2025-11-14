#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CLMCommandContext;

typedef void (^CLMCommandCompletion)(NSError *_Nullable error);

typedef BOOL (^CLMCommandMiddleware)(CLMCommandContext *context, NSError **error);

@protocol CLMCommand <NSObject>
@required
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly, nullable) NSString *commandDescription;
@property (nonatomic, copy, readonly, nullable) NSArray<NSString *> *aliases;
@property (nonatomic, assign, readonly) NSTimeInterval cooldownSeconds; // 0 for none
@property (nonatomic, copy, readonly, nullable) NSArray<NSString *> *requiredPermissions; // symbolic names (e.g., "MANAGE_MESSAGES")
- (void)executeWithContext:(CLMCommandContext *)context completion:(CLMCommandCompletion)completion;
@end

NS_ASSUME_NONNULL_END
