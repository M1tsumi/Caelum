#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CLMAutoModTriggerType) {
    CLMAutoModTriggerKeyword = 1,
    CLMAutoModTriggerSpam = 3,
    CLMAutoModTriggerKeywordPreset = 4,
    CLMAutoModTriggerMentionSpam = 5,
};

typedef NS_ENUM(NSInteger, CLMAutoModKeywordPreset) {
    CLMAutoModKeywordPresetProfanity = 1,
    CLMAutoModKeywordPresetSexualContent = 2,
    CLMAutoModKeywordPresetSlurs = 3,
};

@interface CLMAutoModTrigger : NSObject
@property (nonatomic, assign) CLMAutoModTriggerType type;
// keyword
@property (nonatomic, copy, nullable) NSArray<NSString *> *keywordFilter;
@property (nonatomic, copy, nullable) NSArray<NSString *> *regexPatterns;
@property (nonatomic, copy, nullable) NSArray<NSString *> *allowList;
// mention spam
@property (nonatomic, strong, nullable) NSNumber *mentionTotalLimit;
// presets
@property (nonatomic, copy, nullable) NSArray<NSNumber *> *presets; // CLMAutoModKeywordPreset
+ (instancetype)fromJSON:(NSDictionary *)json type:(CLMAutoModTriggerType)type;
- (NSDictionary *)toJSON;
@end
