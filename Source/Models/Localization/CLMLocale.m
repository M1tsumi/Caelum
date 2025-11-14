#import "CLMLocale.h"

CLMLocale const CLMLocale_enUS = @"en-US";
CLMLocale const CLMLocale_enGB = @"en-GB";
CLMLocale const CLMLocale_esES = @"es-ES";
CLMLocale const CLMLocale_fr   = @"fr";
CLMLocale const CLMLocale_de   = @"de";
CLMLocale const CLMLocale_ptBR = @"pt-BR";
CLMLocale const CLMLocale_ru   = @"ru";
CLMLocale const CLMLocale_tr   = @"tr";
CLMLocale const CLMLocale_ja   = @"ja";
CLMLocale const CLMLocale_ko   = @"ko";
CLMLocale const CLMLocale_zhCN = @"zh-CN";
CLMLocale const CLMLocale_zhTW = @"zh-TW";

@implementation CLMLocaleUtils
+ (NSArray<CLMLocale> *)allSupportedLocales {
    return @[CLMLocale_enUS, CLMLocale_enGB, CLMLocale_esES, CLMLocale_fr, CLMLocale_de,
             CLMLocale_ptBR, CLMLocale_ru, CLMLocale_tr, CLMLocale_ja, CLMLocale_ko,
             CLMLocale_zhCN, CLMLocale_zhTW];
}
+ (BOOL)isSupported:(NSString *)localeKey { return [[self allSupportedLocales] containsObject:localeKey]; }
@end
