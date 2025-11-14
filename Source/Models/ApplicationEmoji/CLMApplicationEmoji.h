#import <Foundation/Foundation.h>

@interface CLMApplicationEmoji : NSObject
@property (nonatomic, copy) NSString *emojiId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) BOOL requiresColons;
@property (nonatomic, assign, getter=isManaged) BOOL managed;
@property (nonatomic, assign, getter=isAnimated) BOOL animated;
+ (instancetype)fromJSON:(NSDictionary *)json;
- (NSDictionary *)toJSONCreateWithImageDataURI:(NSString *)imageDataURI; // for create
- (NSDictionary *)toJSONPatch; // for modify
@end
