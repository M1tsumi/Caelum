#import "CLMPoll.h"

@implementation CLMPoll
+ (instancetype)fromJSON:(NSDictionary *)json {
    CLMPoll *p = [CLMPoll new];
    NSDictionary *q = json[@"question"];
    if ([q isKindOfClass:[NSDictionary class]]) {
        p.questionText = q[@"text"] ?: @"";
    } else {
        p.questionText = @"";
    }
    NSArray *answers = json[@"answers"];
    if ([answers isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[answers count]];
        for (NSDictionary *a in answers) { [arr addObject:[CLMPollAnswer fromJSON:a]]; }
        p.answers = arr;
    } else {
        p.answers = @[];
    }
    p.allowMultiselect = [json[@"allow_multiselect"] boolValue];
    if (json[@"duration"] && [json[@"duration"] isKindOfClass:[NSDictionary class]]) {
        NSNumber *minutes = json[@"duration"][@"days"]; // not official; keep minimal, prefer duration_minutes when sending
        (void)minutes;
    }
    if (json[@"duration_minutes"]) p.durationMinutes = json[@"duration_minutes"];
    return p;
}
- (NSDictionary *)toJSON {
    NSMutableDictionary *d = [NSMutableDictionary new];
    d[@"question"] = @{ @"text": self.questionText ?: @"" };
    if (self.answers.count) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.answers.count];
        for (CLMPollAnswer *a in self.answers) { [arr addObject:[a toJSON]]; }
        d[@"answers"] = arr;
    } else {
        d[@"answers"] = @[];
    }
    if (self.allowMultiselect) d[@"allow_multiselect"] = @YES;
    if (self.durationMinutes) d[@"duration_minutes"] = self.durationMinutes;
    return d;
}
@end
