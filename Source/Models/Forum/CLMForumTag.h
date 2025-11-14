#import <Foundation/Foundation.h>

@interface CLMForumTag : NSObject
@property (nonatomic, copy) NSString *tagId; // id
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL moderated;
@property (nonatomic, copy, nullable) NSString *emojiId;
@property (nonatomic, copy, nullable) NSString *emojiName;
+ (instancetype)fromJSON:(NSDictionary *)json;
- (NSDictionary *)toJSON;
@end
