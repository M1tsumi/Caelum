#import "CLMMockURLProtocol.h"

static CLMURLResponseDataProvider _provider = nil;

@implementation CLMMockURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (void)setResponseProvider:(CLMURLResponseDataProvider)provider {
    _provider = [provider copy];
}

+ (void)reset {
    _provider = nil;
}

- (void)startLoading {
    if (_provider) {
        NSHTTPURLResponse *resp = nil;
        NSError *err = nil;
        NSData *data = _provider(self.request, &resp, &err);
        if (resp) {
            [self.client URLProtocol:self didReceiveResponse:resp cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        }
        if (data) {
            [self.client URLProtocol:self didLoadData:data];
        }
        if (err) {
            [self.client URLProtocol:self didFailWithError:err];
        } else {
            [self.client URLProtocolDidFinishLoading:self];
        }
    } else {
        // No provider; just finish.
        [self.client URLProtocolDidFinishLoading:self];
    }
}

- (void)stopLoading {
    // No-op
}

@end
