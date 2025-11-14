#import <Foundation/Foundation.h>
#import "CLMAutoModTrigger.h"
#import "CLMAutoModAction.h"

@interface CLMAutoModRule : NSObject
@property (nonatomic, copy) NSString *ruleId;
@property (nonatomic, copy) NSString *guildId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger eventType; // 1 MESSAGE_SEND
@property (nonatomic, assign) CLMAutoModTriggerType triggerType;
@property (nonatomic, strong) CLMAutoModTrigger *triggerMetadata;
@property (nonatomic, copy) NSArray<CLMAutoModAction *> *actions;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;
@property (nonatomic, copy, nullable) NSArray<NSString *> *exemptRoles;
@property (nonatomic, copy, nullable) NSArray<NSString *> *exemptChannels;
+ (instancetype)fromJSON:(NSDictionary *)json;
- (NSDictionary *)toJSON; // for create/modify
@end
