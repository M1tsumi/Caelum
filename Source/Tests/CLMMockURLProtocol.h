#import <Foundation/Foundation.h>

typedef NSData* _Nullable (^CLMURLResponseDataProvider)(NSURLRequest *request, NSHTTPURLResponse **outResponse, NSError **outError);

@interface CLMMockURLProtocol : NSURLProtocol
+ (void)setResponseProvider:(CLMURLResponseDataProvider)provider;
+ (void)reset;
@end
