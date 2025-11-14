#import <Foundation/Foundation.h>

@interface CLMMessageSnapshot : NSObject
@property (nonatomic, copy) NSString *messageId;
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy, nullable) NSString *guildId;
@property (nonatomic, copy, nullable) NSString *authorName;
@property (nonatomic, copy, nullable) NSString *authorId;
@property (nonatomic, copy, nullable) NSString *contentExcerpt; // trimmed
@property (nonatomic, copy, nullable) NSString *jumpURL; // https://discord.com/channels/{guildIdOr@me}/{channelId}/{messageId}
// Convenience to build an embed representing the snapshot
- (NSDictionary *)toEmbedJSON;
@end
