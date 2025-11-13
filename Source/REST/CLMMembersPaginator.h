#import <Foundation/Foundation.h>
#import "CLMDiscordRESTClient.h"
NS_ASSUME_NONNULL_BEGIN
@interface CLMMembersPaginator : NSObject
- (instancetype)initWithClient:(CLMDiscordRESTClient *)client guildID:(NSString *)guildID pageSize:(NSNumber *)pageSize;
- (void)nextPageWithCompletion:(CLMRESTCompletion)completion; // uses 'after' cursor
@property (nonatomic, readonly) BOOL hasMoreHint; // heuristic based on page size
@end
NS_ASSUME_NONNULL_END
