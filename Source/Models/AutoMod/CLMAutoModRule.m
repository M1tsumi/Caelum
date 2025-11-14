#import "CLMAutoModRule.h"

@implementation CLMAutoModRule

+ (instancetype)fromJSON:(NSDictionary *)json {
    CLMAutoModRule *r = [CLMAutoModRule new];
    r.ruleId = [json[@"id"] description] ?: @"";
    r.guildId = [json[@"guild_id"] description];
    r.name = json[@"name"] ?: @"";
    r.eventType = [json[@"event_type"] integerValue];
    r.triggerType = (CLMAutoModTriggerType)[json[@"trigger_type"] integerValue];
    NSDictionary *md = json[@"trigger_metadata"];
    if ([md isKindOfClass:[NSDictionary class]]) {
        r.triggerMetadata = [CLMAutoModTrigger fromJSON:md type:r.triggerType];
    }
    NSArray *actions = json[@"actions"];
    if ([actions isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[actions count]];
        for (NSDictionary *a in actions) { [arr addObject:[CLMAutoModAction fromJSON:a]]; }
        r.actions = arr;
    } else { r.actions = @[]; }
    r.enabled = [json[@"enabled"] boolValue];
    if ([json[@"exempt_roles"] isKindOfClass:[NSArray class]]) r.exemptRoles = json[@"exempt_roles"];
    if ([json[@"exempt_channels"] isKindOfClass:[NSArray class]]) r.exemptChannels = json[@"exempt_channels"];
    return r;
}

- (NSDictionary *)toJSON {
    NSMutableDictionary *d = [NSMutableDictionary new];
    if (self.name.length) d[@"name"] = self.name;
    d[@"event_type"] = @(self.eventType ?: 1);
    d[@"trigger_type"] = @(self.triggerType);
    if (self.triggerMetadata) d[@"trigger_metadata"] = [self.triggerMetadata toJSON];
    if (self.actions.count) {
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:self.actions.count];
        for (CLMAutoModAction *a in self.actions) { [arr addObject:[a toJSON]]; }
        d[@"actions"] = arr;
    }
    d[@"enabled"] = @(self.isEnabled);
    if (self.exemptRoles) d[@"exempt_roles"] = self.exemptRoles;
    if (self.exemptChannels) d[@"exempt_channels"] = self.exemptChannels;
    return d;
}

@end
