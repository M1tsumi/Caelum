#import "CLMRESTRequest.h"
@implementation CLMRESTFilePart
+ (instancetype)partWithField:(NSString *)fieldName filename:(NSString *)filename mimeType:(NSString *)mimeType data:(NSData *)data {
    CLMRESTFilePart *p = [CLMRESTFilePart new];
    p.fieldName = fieldName ?: @"file";
    p.filename = filename ?: @"file.bin";
    p.mimeType = mimeType ?: @"application/octet-stream";
    p.data = data ?: [NSData data];
    return p;
}
@end
@implementation CLMRESTRequest
+ (instancetype)requestWithMethod:(NSString *)method route:(NSString *)route {
    CLMRESTRequest *r = [CLMRESTRequest new];
    r.method = method; r.route = route; return r;
}
@end
