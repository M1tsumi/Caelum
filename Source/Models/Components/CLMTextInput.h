#import <Foundation/Foundation.h>
#import "CLMComponents.h"

typedef NS_ENUM(NSInteger, CLMTextInputStyle) { CLMTextInputStyleShort = 1, CLMTextInputStyleParagraph = 2 };

@interface CLMTextInput : NSObject
@property (nonatomic, copy) NSString *customId;
@property (nonatomic, assign) CLMTextInputStyle style; // 1 short, 2 paragraph
@property (nonatomic, copy) NSString *label; // 1-45 chars
@property (nonatomic, assign) NSInteger minLength; // 0-4000
@property (nonatomic, assign) NSInteger maxLength; // 1-4000
@property (nonatomic, assign, getter=isRequired) BOOL required;
@property (nonatomic, copy, nullable) NSString *value; // prefill <= 4000
@property (nonatomic, copy, nullable) NSString *placeholder; // <=100
+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error;
- (NSDictionary *)toJSON;
@end
