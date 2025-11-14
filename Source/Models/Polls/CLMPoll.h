#import <Foundation/Foundation.h>
#import "CLMPollAnswer.h"

@interface CLMPoll : NSObject
@property (nonatomic, copy) NSString *questionText;
@property (nonatomic, copy) NSArray<CLMPollAnswer *> *answers;
@property (nonatomic, assign) BOOL allowMultiselect;
@property (nonatomic, strong, nullable) NSNumber *durationMinutes; // poll will close after this many minutes
+ (instancetype)fromJSON:(NSDictionary *)json;
- (NSDictionary *)toJSON; // for message create payload under key "poll"
@end
