#import "CLMRESTRequest.h"
@implementation CLMRESTRequest
+ (instancetype)requestWithMethod:(NSString *)method route:(NSString *)route {
    CLMRESTRequest *r = [CLMRESTRequest new];
    r.method = method; r.route = route; return r;
}
@end
