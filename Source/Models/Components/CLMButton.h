#import <Foundation/Foundation.h>
#import "CLMComponents.h"

@interface CLMButton : NSObject
@property (nonatomic, assign) CLMButtonStyle style;
@property (nonatomic, copy, nullable) NSString *label;
@property (nonatomic, copy, nullable) NSString *emojiName;
@property (nonatomic, copy, nullable) NSString *emojiId;
@property (nonatomic, assign) BOOL emojiAnimated;
@property (nonatomic, copy, nullable) NSString *customId; // required unless Link
@property (nonatomic, copy, nullable) NSString *url; // required for Link
@property (nonatomic, assign, getter=isDisabled) BOOL disabled;
+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error;
- (NSDictionary *)toJSON;
@end
