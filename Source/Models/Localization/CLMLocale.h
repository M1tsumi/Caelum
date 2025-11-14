#import <Foundation/Foundation.h>

typedef NSString * CLMLocale NS_EXTENSIBLE_STRING_ENUM;
FOUNDATION_EXPORT CLMLocale const CLMLocale_enUS;
FOUNDATION_EXPORT CLMLocale const CLMLocale_enGB;
FOUNDATION_EXPORT CLMLocale const CLMLocale_esES;
FOUNDATION_EXPORT CLMLocale const CLMLocale_fr;
FOUNDATION_EXPORT CLMLocale const CLMLocale_de;
FOUNDATION_EXPORT CLMLocale const CLMLocale_ptBR;
FOUNDATION_EXPORT CLMLocale const CLMLocale_ru;
FOUNDATION_EXPORT CLMLocale const CLMLocale_tr;
FOUNDATION_EXPORT CLMLocale const CLMLocale_ja;
FOUNDATION_EXPORT CLMLocale const CLMLocale_ko;
FOUNDATION_EXPORT CLMLocale const CLMLocale_zhCN;
FOUNDATION_EXPORT CLMLocale const CLMLocale_zhTW;

@interface CLMLocaleUtils : NSObject
+ (NSArray<CLMLocale> *)allSupportedLocales;
+ (BOOL)isSupported:(NSString *)localeKey;
@end
