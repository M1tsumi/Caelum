#import <XCTest/XCTest.h>
#import "CLMDiscordRESTClient.h"
#import "CLMMockURLProtocol.h"

@interface CLMTestTokenProvider : NSObject <CLMTokenProvider>
@property (nonatomic, copy) NSString *token;
@end
@implementation CLMTestTokenProvider
- (NSString *)botToken { return self.token; }
@end

@interface CLMTestRESTClient : CLMDiscordRESTClient
@property (nonatomic, strong) NSURLSession *testSession;
@end
@implementation CLMTestRESTClient
- (NSURLSession *)session { return self.testSession ?: [super session]; }
@end

@interface CLMDiscordRESTClientTests : XCTestCase
@end

@implementation CLMDiscordRESTClientTests

- (CLMTestRESTClient *)makeClientWithMockProtocol {
    CLMRESTConfiguration *cfg = [CLMRESTConfiguration defaultConfiguration];
    CLMTestTokenProvider *tp = [CLMTestTokenProvider new];
    tp.token = @"TEST_TOKEN";
    cfg.tokenProvider = tp;

    NSURLSessionConfiguration *urlCfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    urlCfg.protocolClasses = @[ CLMMockURLProtocol.class ];
    CLMTestRESTClient *client = [[CLMTestRESTClient alloc] initWithConfiguration:cfg];
    client.testSession = [NSURLSession sessionWithConfiguration:urlCfg];
    return client;
}

- (void)testGetCurrentUser_Success {
    NSDictionary *payload = @{ @"id": @"123", @"username": @"tester" };
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        XCTAssertEqualObjects(request.HTTPMethod, @"GET");
        XCTAssertTrue([request.URL.absoluteString hasSuffix:@"users/@me"]);
        XCTAssertEqualObjects([request valueForHTTPHeaderField:@"Accept"], @"application/json");
        XCTAssertEqualObjects([request valueForHTTPHeaderField:@"Content-Type"], @"application/json");
        XCTAssertEqualObjects([request valueForHTTPHeaderField:@"Authorization"], @"Bot TEST_TOKEN");
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        return data;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"];
    [client getCurrentUser:^(CLMRESTResponse *response) {
        XCTAssertNil(response.error);
        XCTAssertEqual(response.statusCode, 200);
        XCTAssertTrue([response.JSONObject isKindOfClass:NSDictionary.class]);
        XCTAssertEqualObjects(response.JSONObject[@"username"], @"tester");
        [exp fulfill];
    }];

    [self waitForExpectationsWithTimeout:2 handler:nil];
    [CLMMockURLProtocol reset];
}

- (void)testJSONDecodeError_ProducesError {
    NSData *badData = [@"not-json" dataUsingEncoding:NSUTF8StringEncoding];
    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        return badData;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"];
    [client getCurrentUser:^(CLMRESTResponse *response) {
        XCTAssertNotNil(response.error);
        XCTAssertEqual(response.statusCode, 200);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    [CLMMockURLProtocol reset];
}

- (void)testHTTPStatus401_UnauthorizedMapsToErrorCode3 {
    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:401 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        return nil;
    }];
    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"]; 
    [client getCurrentUser:^(CLMRESTResponse *response) {
        XCTAssertNotNil(response.error);
        XCTAssertEqual(response.statusCode, 401);
        XCTAssertEqualObjects(response.error.domain, @"com.caelum.discord");
        XCTAssertEqual(response.error.code, 3);
        XCTAssertEqualObjects(response.error.userInfo[@"statusCode"], @(401));
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    [CLMMockURLProtocol reset];
}

- (void)testHTTPStatus429_RateLimitedMapsToErrorCode4 {
    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:429 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        return nil;
    }];
    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"]; 
    [client getCurrentUser:^(CLMRESTResponse *response) {
        XCTAssertNotNil(response.error);
        XCTAssertEqual(response.statusCode, 429);
        XCTAssertEqualObjects(response.error.domain, @"com.caelum.discord");
        XCTAssertEqual(response.error.code, 4);
        XCTAssertEqualObjects(response.error.userInfo[@"statusCode"], @(429));
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    [CLMMockURLProtocol reset];
}

- (void)testHTTPStatus500_ServerMapsToGenericServerErrorCode7 {
    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:503 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        return nil;
    }];
    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"]; 
    [client getCurrentUser:^(CLMRESTResponse *response) {
        XCTAssertNotNil(response.error);
        XCTAssertEqual(response.statusCode, 503);
        XCTAssertEqualObjects(response.error.domain, @"com.caelum.discord");
        XCTAssertEqual(response.error.code, 7);
        XCTAssertEqualObjects(response.error.userInfo[@"statusCode"], @(503));
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    [CLMMockURLProtocol reset];
}

- (void)testAuditLogHeaderPropagation_EncodedProperly {
    __block NSString *capturedHeader = nil;
    NSDictionary *ok = @{};
    NSData *data = [NSJSONSerialization dataWithJSONObject:ok options:0 error:nil];
    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        capturedHeader = [request valueForHTTPHeaderField:@"X-Audit-Log-Reason"];
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        return data;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    NSString *reason = @"Pinning message: café & news";
    // Use an endpoint with auditLogReason variant
    [client editMessageInChannel:@"123" messageID:@"456" newContent:@"updated" auditLogReason:reason completion:^(CLMRESTResponse *response) {
        // no-op
    }];

    // Allow the provider to be invoked
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *expected = [reason stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        XCTAssertEqualObjects(capturedHeader, expected);
        [exp fulfill];
    });
    [self waitForExpectationsWithTimeout:2 handler:nil];
    [CLMMockURLProtocol reset];
}

@end
