# Models

All model classes are under `Source/Models/`. They typically implement `fromJSON:` / `toJSON` for serialization.

## Snowflake

```objc
@interface CLMSnowflake : NSObject
// Wrapper around Discord snowflake IDs
@property (nonatomic, readonly) uint64_t value;
- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithUInt64:(uint64_t)value;
- (NSDate *)timestamp; // extract timestamp from snowflake
@end
```

## Components

### ActionRow

```objc
@interface CLMActionRow : NSObject
@property (nonatomic, strong) NSArray *components; // CLMButton, CLMSelectMenu, or CLMTextInput
+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error;
- (NSDictionary *)toJSON;
+ (NSError *)validateComponents:(NSArray *)components; // validates row constraints
@end
```

### Button

```objc
typedef NS_ENUM(NSInteger, CLMButtonStyle) {
    CLMButtonStylePrimary   = 1,
    CLMButtonStyleSecondary = 2,
    CLMButtonStyleSuccess   = 3,
    CLMButtonStyleDanger    = 4,
    CLMButtonStyleLink      = 5,
};

@interface CLMButton : NSObject
@property (nonatomic) CLMButtonStyle style;
@property (nonatomic, copy) NSString *customId;  // nil for link buttons
@property (nonatomic, copy) NSString *label;
@property (nonatomic) BOOL disabled;
+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error;
- (NSDictionary *)toJSON;
@end
```

### SelectMenu

```objc
@interface CLMSelectMenu : NSObject
@property (nonatomic) NSInteger type; // CLMComponentTypeSelectString (3), SelectUser (5), SelectRole (6), etc.
@property (nonatomic, copy) NSString *customId;
@property (nonatomic, strong) NSArray<CLMSelectMenuOption *> *options;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic) NSInteger minValues;
@property (nonatomic) NSInteger maxValues;
@property (nonatomic) BOOL disabled;
+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error;
- (NSDictionary *)toJSON;
@end

@interface CLMSelectMenuOption : NSObject
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, strong) CLMEmoji *emoji;
@property (nonatomic) BOOL isDefault;
- (NSDictionary *)toJSON;
@end
```

### TextInput

```objc
typedef NS_ENUM(NSInteger, CLMTextInputStyle) {
    CLMTextInputStyleShort = 1,
    CLMTextInputStyleParagraph = 2,
};

@interface CLMTextInput : NSObject
@property (nonatomic, copy) NSString *customId;
@property (nonatomic) CLMTextInputStyle style;
@property (nonatomic, copy) NSString *label;
@property (nonatomic) NSInteger minLength;
@property (nonatomic) NSInteger maxLength;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *value;
@property (nonatomic) BOOL required;
+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error;
- (NSDictionary *)toJSON;
@end
```

## Modals

```objc
@interface CLMModal : NSObject
@property (nonatomic, copy) NSString *customId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray<CLMActionRow *> *components;
+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error;
- (NSDictionary *)toJSON;
@end

@interface CLMModalBuilder : NSObject
- (instancetype)customId:(NSString *)customId;
- (instancetype)title:(NSString *)title;
- (instancetype)addTextInput:(CLMTextInput *)textInput;
- (CLMModal *)build:(NSError **)error; // validates all constraints
@end
```

## Interactions

```objc
@interface CLMComponentInteraction : NSObject
@property (nonatomic, copy) NSString *interactionId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic) NSInteger type; // 2=ping, 3=component, 4=command, 5=modal
@property (nonatomic, copy) NSString *customId;
@property (nonatomic, strong) NSArray *values;   // select menu values
@property (nonatomic, copy) NSString *channelId;
@property (nonatomic, copy) NSString *guildId;
@property (nonatomic, strong) NSDictionary *raw;
+ (instancetype)fromGatewayPayload:(NSDictionary *)payload;
@end
```

## AutoMod

```objc
typedef NS_ENUM(NSInteger, CLMAutoModTriggerType) {
    CLMAutoModTriggerKeyword = 1,
    CLMAutoModTriggerSpam = 3,
    CLMAutoModTriggerKeywordPreset = 4,
    CLMAutoModTriggerMentionSpam = 5,
};

@interface CLMAutoModTrigger : NSObject
@property (nonatomic) CLMAutoModTriggerType type;
@property (nonatomic, copy) NSArray<NSString *> *keywordFilter;
@property (nonatomic, copy) NSArray<NSString *> *regexPatterns;
@property (nonatomic, copy) NSArray<NSString *> *allowList;
@property (nonatomic, strong) NSNumber *mentionTotalLimit;
@property (nonatomic, copy) NSArray<NSNumber *> *presets;
+ (instancetype)fromJSON:(NSDictionary *)json type:(CLMAutoModTriggerType)type;
- (NSDictionary *)toJSON;
@end

@interface CLMAutoModAction : NSObject
// Block message, send alert, timeout, etc.
+ (instancetype)blockAction;
+ (instancetype)alertActionWithChannelId:(NSString *)channelId;
+ (instancetype)timeoutActionWithDuration:(NSInteger)seconds;
- (NSDictionary *)toJSON;
@end

@interface CLMAutoModRule : NSObject
@property (nonatomic, copy) NSString *ruleId;
@property (nonatomic, copy) NSString *guildId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSInteger eventType;
@property (nonatomic, strong) CLMAutoModTrigger *trigger;
@property (nonatomic, strong) NSArray<CLMAutoModAction *> *actions;
@property (nonatomic) BOOL enabled;
+ (instancetype)fromJSON:(NSDictionary *)json;
- (NSDictionary *)toJSON;
@end
```

## Polls

```objc
@interface CLMPollAnswer : NSObject
@property (nonatomic) NSInteger answerId;
@property (nonatomic, copy) NSString *content; // supports emoji
- (NSDictionary *)toJSON;
@end

@interface CLMPoll : NSObject
@property (nonatomic, copy) NSString *question;
@property (nonatomic, strong) NSArray<CLMPollAnswer *> *answers;
@property (nonatomic) NSInteger duration;     // hours
@property (nonatomic) BOOL allowMultiselect;
- (NSDictionary *)toJSON;
+ (instancetype)fromJSON:(NSDictionary *)json;
@end
```

## Forum

```objc
@interface CLMForumTag : NSObject
@property (nonatomic, copy) NSString *tagId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) BOOL moderated;
@property (nonatomic, copy) NSString *emojiName;
- (NSDictionary *)toJSON;
+ (instancetype)fromJSON:(NSDictionary *)json;
@end

@interface CLMForumChannel : NSObject
// Properties for forum channel metadata (default reaction, tags, etc.)
+ (instancetype)fromJSON:(NSDictionary *)json;
@end
```

## Localization

```objc
typedef NSString *CLMLocale NS_TYPED_EXTENSIBLE_ENUM;
extern CLMLocale const CLMLocaleEnglishUS;
extern CLMLocale const CLMLocaleEnglishGB;
// ... 12 locales total

@interface CLMLocalizedString : NSObject
@property (nonatomic, strong) NSMutableDictionary<CLMLocale, NSString *> *translations;
- (void)setString:(NSString *)string forLocale:(CLMLocale)locale;
- (NSDictionary *)toJSON;
@end
```

## Application Emoji

```objc
@interface CLMApplicationEmoji : NSObject
@property (nonatomic, copy) NSString *emojiId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *imageBase64; // data URI for create
- (NSDictionary *)toCreateJSON;
- (NSDictionary *)toUpdateJSON;
+ (instancetype)fromJSON:(NSDictionary *)json;
@end
```

## Message Snapshot

```objc
@interface CLMMessageSnapshot : NSObject
// Embed builder for forwarded messages
- (void)setContent:(NSString *)content;
- (void)setAuthor:(NSString *)name iconURL:(NSString *)iconURL;
- (NSDictionary *)toJSON;
@end
```

## Application Install

```objc
// Helpers for application command integration types and contexts
extern CLMApplicationIntegrationType const CLMApplicationIntegrationTypeGuildInstall;
extern CLMApplicationIntegrationType const CLMApplicationIntegrationTypeUserInstall;
// ... etc.
```
