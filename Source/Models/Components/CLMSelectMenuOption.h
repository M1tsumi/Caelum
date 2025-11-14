#import <Foundation/Foundation.h>

@interface CLMSelectMenuOption : NSObject
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy, nullable) NSString *descriptionText;
@property (nonatomic, copy, nullable) NSString *emojiName;
@property (nonatomic, copy, nullable) NSString *emojiId;
@property (nonatomic, assign) BOOL emojiAnimated;
@property (nonatomic, assign, getter=isDefaultSelected) BOOL defaultSelected;
+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error;
- (NSDictionary *)toJSON;
@end
