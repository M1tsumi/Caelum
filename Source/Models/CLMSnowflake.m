#import "CLMSnowflake.h"
@implementation CLMSnowflake {
    unsigned long long _value;
}
- (instancetype)initWithString:(NSString *)string { if ((self=[super init])) { _value = strtoull(string.UTF8String, NULL, 10); } return self; }
- (unsigned long long)value { return _value; }
- (NSString *)stringValue { return [NSString stringWithFormat:@"%llu", _value]; }
@end
