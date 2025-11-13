#import <Foundation/Foundation.h>
#import "CLMDiscordRESTClient.h"
NS_ASSUME_NONNULL_BEGIN
@interface CLMMessagesPaginator : NSObject
- (instancetype)initWithClient:(CLMDiscordRESTClient *)client channelID:(NSString *)channelID pageSize:(NSNumber *)pageSize;
- (void)nextPageWithCompletion:(CLMRESTCompletion)completion;
@property (nonatomic, readonly) BOOL hasMoreHint; // heuristic based on page size
@end
NS_ASSUME_NONNULL_END
