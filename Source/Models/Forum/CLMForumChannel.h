#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CLMForumLayoutType) {
    CLMForumLayoutNotSet = 0,
    CLMForumLayoutListView = 1,
    CLMForumLayoutGalleryView = 2,
};

typedef NS_ENUM(NSInteger, CLMSortOrderType) {
    CLMSortOrderLatestActivity = 0,
    CLMSortOrderCreationDate = 1,
};

@class CLMForumTag;
@interface CLMForumChannel : NSObject
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy, nullable) NSArray<CLMForumTag *> *availableTags;
@property (nonatomic, copy, nullable) NSString *defaultReactionEmojiId;
@property (nonatomic, copy, nullable) NSString *defaultReactionEmojiName;
@property (nonatomic, assign) CLMSortOrderType defaultSortOrder;
@property (nonatomic, assign) CLMForumLayoutType defaultLayout;
@property (nonatomic, strong, nullable) NSNumber *defaultThreadRateLimitPerUser;
+ (instancetype)fromJSON:(NSDictionary *)json;
- (NSDictionary *)toJSONPatch; // for PATCH /channels/{id}
@end
