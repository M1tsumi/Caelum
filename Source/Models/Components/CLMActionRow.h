#import <Foundation/Foundation.h>
#import "CLMComponents.h"
@class CLMButton, CLMSelectMenu;

@interface CLMActionRow : NSObject
@property (nonatomic, copy) NSArray *components; // of CLMButton or CLMSelectMenu
+ (instancetype)fromJSON:(NSDictionary *)json error:(NSError **)error;
- (NSDictionary *)toJSON;
+ (NSError *)validateComponents:(NSArray *)components;
@end
