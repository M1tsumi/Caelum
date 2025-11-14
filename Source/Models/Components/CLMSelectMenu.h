#import <Foundation/Foundation.h>
#import "CLMComponents.h"
@class CLMSelectMenuOption;

@interface CLMSelectMenu : NSObject
@property (nonatomic, assign) CLMComponentType type;
@property (nonatomic, copy) NSString *customId;
@property (nonatomic, assign) NSInteger minValues;
@property (nonatomic, assign) NSInteger maxValues;
@property (nonatomic, assign, getter=isDisabled) BOOL disabled;
@property (nonatomic, copy, nullable) NSString *placeholder;
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *channelTypes;
@property (nonatomic, copy, nullable) NSArray<CLMSelectMenuOption *> *options;
+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error;
- (NSDictionary *)toJSON;
@end

@interface CLMSelectMenuBuilder : NSObject
@property (nonatomic, strong, readonly) CLMSelectMenu *menu;
- (instancetype)type:(CLMComponentType)type;
- (instancetype)customId:(NSString *)customId;
- (instancetype)placeholder:(NSString *)placeholder;
- (instancetype)minValues:(NSInteger)min;
- (instancetype)maxValues:(NSInteger)max;
- (instancetype)options:(NSArray<CLMSelectMenuOption *> *)options;
- (instancetype)channelTypes:(NSArray<NSNumber *> *)types;
- (CLMSelectMenu *)build:(NSError **)error;
@end
