#import <Foundation/Foundation.h>
#import "Models/Components/CLMComponents.h"

@interface CLMComponentInteraction : NSObject
@property (nonatomic, copy) NSString *interactionId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy, nullable) NSString *applicationId;
@property (nonatomic, copy, nullable) NSString *guildId;
@property (nonatomic, copy, nullable) NSString *channelId;
@property (nonatomic, assign) NSInteger type; // 3 = MESSAGE_COMPONENT, 5 = MODAL_SUBMIT
@property (nonatomic, assign) CLMComponentType componentType; // for component interactions
@property (nonatomic, copy) NSString *customId;
@property (nonatomic, copy, nullable) NSArray<NSString *> *values; // select values
@property (nonatomic, strong, nullable) NSDictionary *resolved; // users/members/roles/channels
@property (nonatomic, strong, nullable) NSDictionary<NSString*, NSString*> *modalValues; // customId -> value for modal submit
+ (instancetype)fromGatewayPayload:(NSDictionary *)payload; // INTERACTION_CREATE d
@end
