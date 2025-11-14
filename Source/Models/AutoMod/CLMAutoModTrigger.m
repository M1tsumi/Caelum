#import "CLMAutoModTrigger.h"

@implementation CLMAutoModTrigger

+ (instancetype)fromJSON:(NSDictionary *)json type:(CLMAutoModTriggerType)type {
    CLMAutoModTrigger *t = [CLMAutoModTrigger new];
    t.type = type;
    if (type == CLMAutoModTriggerKeyword) {
        if ([json[@"keyword_filter"] isKindOfClass:[NSArray class]]) t.keywordFilter = json[@"keyword_filter"];
        if ([json[@"regex_patterns"] isKindOfClass:[NSArray class]]) t.regexPatterns = json[@"regex_patterns"];
        if ([json[@"allow_list"] isKindOfClass:[NSArray class]]) t.allowList = json[@"allow_list"];
    } else if (type == CLMAutoModTriggerMentionSpam) {
        if (json[@"mention_total_limit"]) t.mentionTotalLimit = json[@"mention_total_limit"];
    } else if (type == CLMAutoModTriggerKeywordPreset) {
        if ([json[@"presets"] isKindOfClass:[NSArray class]]) t.presets = json[@"presets"];
    }
    return t;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *md = [NSMutableDictionary new];
    switch (self.type) {
        case CLMAutoModTriggerKeyword:
            if (self.keywordFilter) md[@"keyword_filter"] = self.keywordFilter;
            if (self.regexPatterns) md[@"regex_patterns"] = self.regexPatterns;
            if (self.allowList) md[@"allow_list"] = self.allowList;
            break;
        case CLMAutoModTriggerMentionSpam:
            if (self.mentionTotalLimit) md[@"mention_total_limit"] = self.mentionTotalLimit;
            break;
        case CLMAutoModTriggerKeywordPreset:
            if (self.presets) md[@"presets"] = self.presets;
            break;
        default: break;
    }
    return md;
}

@end
