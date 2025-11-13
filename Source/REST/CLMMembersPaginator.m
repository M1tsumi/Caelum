#import "CLMMembersPaginator.h"
@interface CLMMembersPaginator ()
@property (nonatomic, strong) CLMDiscordRESTClient *client;
@property (nonatomic, copy) NSString *guildID;
@property (nonatomic, strong) NSNumber *pageSize;
@property (nonatomic, copy, nullable) NSString *afterCursor;
@property (nonatomic, assign) BOOL hasMoreHint;
@end
@implementation CLMMembersPaginator
- (instancetype)initWithClient:(CLMDiscordRESTClient *)client guildID:(NSString *)guildID pageSize:(NSNumber *)pageSize {
    if ((self=[super init])) { _client = client; _guildID = [guildID copy]; _pageSize = pageSize ?: @(1000); }
    return self;
}
- (void)nextPageWithCompletion:(CLMRESTCompletion)completion {
    __weak typeof(self) weakSelf = self;
    [self.client listMembersInGuild:self.guildID limit:self.pageSize after:self.afterCursor completion:^(CLMRESTResponse *response) {
        __strong typeof(weakSelf) self = weakSelf;
        if (!self) { if (completion) completion(response); return; }
        if (!response.error && [response.JSONObject isKindOfClass:[NSArray class]]) {
            NSArray *arr = (NSArray *)response.JSONObject;
            self.hasMoreHint = (arr.count == self.pageSize.integerValue);
            NSDictionary *last = arr.lastObject;
            NSString *lastID = [last isKindOfClass:[NSDictionary class]] ? last[@"user"][@"id"] ?: last[@"id"] : nil;
            if (lastID.length > 0) { self.afterCursor = lastID; }
        }
        if (completion) completion(response);
    }];
}
@end
