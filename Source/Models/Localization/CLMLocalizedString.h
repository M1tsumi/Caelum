#import <Foundation/Foundation.h>

@interface CLMLocalizedString : NSObject
@property (nonatomic, copy) NSString *base;
@property (nonatomic, copy) NSDictionary<NSString*, NSString*> *localizations; // localeKey -> text
+ (instancetype)localizedWithBase:(NSString *)base localizations:(NSDictionary<NSString*, NSString*> *)localizations;
- (NSDictionary *)toJSONDictionary; // for Discord payloads (e.g., name_localizations)
@end
