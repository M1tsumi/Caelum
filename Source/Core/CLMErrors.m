#import "CLMErrors.h"
NSErrorDomain const CLMErrorDomain = @"com.caelum.discord";

NSError *CLMErrorMake(CLMErrorCode code, NSString *description, NSDictionary *extraUserInfo) {
    NSMutableDictionary *ui = [NSMutableDictionary dictionary];
    if (description.length > 0) ui[NSLocalizedDescriptionKey] = description;
    [ui addEntriesFromDictionary:extraUserInfo ?: @{}];
    return [NSError errorWithDomain:CLMErrorDomain code:code userInfo:[ui copy]];
}
