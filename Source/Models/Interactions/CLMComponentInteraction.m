#import "CLMComponentInteraction.h"

@implementation CLMComponentInteraction

+ (instancetype)fromGatewayPayload:(NSDictionary *)payload {
    CLMComponentInteraction *it = [CLMComponentInteraction new];
    NSString *typeStr = [payload[@"type"] description];
    it.type = [payload[@"type"] integerValue];
    NSDictionary *d = payload ?: @{};
    it.interactionId = [d[@"id"] description] ?: @"";
    it.token = d[@"token"] ?: @"";
    it.applicationId = [d[@"application_id"] description];
    it.guildId = [d[@"guild_id"] description];
    it.channelId = [d[@"channel_id"] description];
    NSDictionary *data = d[@"data"];
    if ([data isKindOfClass:[NSDictionary class]]) {
        it.customId = data[@"custom_id"] ?: @"";
        it.componentType = (CLMComponentType)[data[@"component_type"] integerValue];
        NSArray *values = data[@"values"];
        if ([values isKindOfClass:[NSArray class]]) {
            NSMutableArray *strs = [NSMutableArray arrayWithCapacity:values.count];
            for (id v in values) { [strs addObject:[v description]]; }
            it.values = strs;
        }
        NSDictionary *resolved = data[@"resolved"];
        if ([resolved isKindOfClass:[NSDictionary class]]) {
            it.resolved = resolved; // keeping raw; mapping to models can be added later
        }
        // Modal submit values: data.components -> rows -> components (text inputs with custom_id/value)
        if (it.type == 5) { // MODAL_SUBMIT
            NSArray *rows = data[@"components"];
            if ([rows isKindOfClass:[NSArray class]]) {
                NSMutableDictionary<NSString*, NSString*> *vals = [NSMutableDictionary new];
                for (NSDictionary *row in rows) {
                    NSArray *comps = row[@"components"];
                    if (![comps isKindOfClass:[NSArray class]]) continue;
                    for (NSDictionary *ti in comps) {
                        NSString *cid = ti[@"custom_id"]; NSString *val = ti[@"value"]; if (cid && val) { vals[cid] = val; }
                    }
                }
                if (vals.count) it.modalValues = vals;
            }
        }
    }
    (void)typeStr; // silence unused if compiled with warnings
    return it;
}

@end
