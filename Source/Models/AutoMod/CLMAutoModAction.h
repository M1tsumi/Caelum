#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CLMAutoModActionType) {
    CLMAutoModActionBlockMessage = 1,
    CLMAutoModActionSendAlertMessage = 2,
    CLMAutoModActionTimeout = 3,
};

@interface CLMAutoModAction : NSObject
@property (nonatomic, assign) CLMAutoModActionType type;
@property (nonatomic, copy, nullable) NSString *customMessage; // for block
@property (nonatomic, copy, nullable) NSString *channelId; // for alert
@property (nonatomic, strong, nullable) NSNumber *durationSeconds; // for timeout
+ (instancetype)fromJSON:(NSDictionary *)json;
- (NSDictionary *)toJSON;
@end
