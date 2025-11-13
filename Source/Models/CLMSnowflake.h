#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface CLMSnowflake : NSObject
@property (nonatomic, readonly) unsigned long long value;
- (instancetype)initWithString:(NSString *)string;
- (NSString *)stringValue;
@end
NS_ASSUME_NONNULL_END
