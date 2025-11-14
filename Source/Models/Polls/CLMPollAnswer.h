#import <Foundation/Foundation.h>

@interface CLMPollAnswer : NSObject
@property (nonatomic, copy) NSString *answerId; // stringified id in Discord payloads
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, copy, nullable) NSString *emojiName;
@property (nonatomic, copy, nullable) NSString *emojiId;
@property (nonatomic, assign) BOOL emojiAnimated;
+ (instancetype)fromJSON:(NSDictionary *)json;
- (NSDictionary *)toJSON; // for message create payload
@end
