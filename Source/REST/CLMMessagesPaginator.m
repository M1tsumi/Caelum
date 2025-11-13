#import "CLMMessagesPaginator.h"
@interface CLMMessagesPaginator ()
@property (nonatomic, strong) CLMDiscordRESTClient *client;
@property (nonatomic, copy) NSString *channelID;
@property (nonatomic, strong) NSNumber *pageSize;
@property (nonatomic, copy, nullable) NSString *beforeCursor;
@property (nonatomic, assign) BOOL hasMoreHint;
@end
@implementation CLMMessagesPaginator
- (instancetype)initWithClient:(CLMDiscordRESTClient *)client channelID:(NSString *)channelID pageSize:(NSNumber *)pageSize {
    if ((self=[super init])) { _client = client; _channelID = [channelID copy]; _pageSize = pageSize ?: @(50); }
    return self;
}
- (void)nextPageWithCompletion:(CLMRESTCompletion)completion {
    __weak typeof(self) weakSelf = self;
    [self.client listMessagesInChannel:self.channelID limit:self.pageSize before:self.beforeCursor after:nil completion:^(CLMRESTResponse *response) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { if (completion) completion(response); return; }
        if (!response.error && [response.JSONObject isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)response.JSONObject;
            self.hasMoreHint = (arr.count == self.pageSize.integerValue);
            // Update cursor to the last message id to continue backward
            NSDictionary *last = arr.lastObject;
            NSString *lastID = [last isKindOfClass:[NSDictionary class]] ? last[@"id"] : nil;
            if (lastID.length > 0) { self.beforeCursor = lastID; }
        }
        if (completion) completion(response);
    }];
}
@end
