#import <XCTest/XCTest.h>
#import "CLMDiscordRESTClient.h"
#import "CLMMockURLProtocol.h"
#import "../Core/CLMErrors.h"

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
        XCTAssertEqualObjects(response.error.domain, CLMErrorDomain);
        XCTAssertEqual(response.error.code, CLMErrorUnauthorized);
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
        XCTAssertEqualObjects(response.error.domain, CLMErrorDomain);
        XCTAssertEqual(response.error.code, CLMErrorRateLimited);
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
        XCTAssertEqualObjects(response.error.domain, CLMErrorDomain);
        XCTAssertEqual(response.error.code, CLMErrorServer);
        XCTAssertEqualObjects(response.error.userInfo[@"statusCode"], @(503));
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
    [CLMMockURLProtocol reset];
}

- (void)testAuditLogHeaderPropagation_EncodedProperly {
    __block NSString *capturedHeader = nil;
    __block XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];
    NSDictionary *ok = @{};
    NSData *data = [NSJSONSerialization dataWithJSONObject:ok options:0 error:nil];
    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        capturedHeader = [request valueForHTTPHeaderField:@"X-Audit-Log-Reason"];
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return data;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    NSString *reason = @"Pinning message: café & news";
    [client editMessageInChannel:@"123" messageID:@"456" newContent:@"updated" auditLogReason:reason completion:nil];

    [self waitForExpectations:@[provExp] timeout:2];
    NSString *expected = [reason stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    XCTAssertEqualObjects(capturedHeader, expected);
    [CLMMockURLProtocol reset];
}

- (void)testSendMessage_POST_WithJSONBody {
    __block NSString *capturedMethod = nil;
    __block NSString *capturedContentType = nil;
    __block NSData *capturedBody = nil;
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];
    NSDictionary *payload = @{ @"id": @"999" };
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        capturedMethod = request.HTTPMethod;
        capturedContentType = [request valueForHTTPHeaderField:@"Content-Type"];
        capturedBody = request.HTTPBody;
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return data;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    [client sendMessage:@"Hello!" toChannel:@"789" completion:^(CLMRESTResponse *response) {
        XCTAssertNil(response.error);
        XCTAssertEqualObjects(response.JSONObject[@"id"], @"999");
    }];

    [self waitForExpectations:@[provExp] timeout:2];
    XCTAssertEqualObjects(capturedMethod, @"POST");
    XCTAssertTrue([capturedContentType containsString:@"application/json"]);
    XCTAssertNotNil(capturedBody);
    NSDictionary *body = [NSJSONSerialization JSONObjectWithData:capturedBody options:0 error:nil];
    XCTAssertEqualObjects(body[@"content"], @"Hello!");
    [CLMMockURLProtocol reset];
}

- (void)testSendMessage_POST_AuditLogReason {
    __block NSString *capturedHeader = nil;
    __block NSData *capturedBody = nil;
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];
    NSDictionary *payload = @{};
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        capturedHeader = [request valueForHTTPHeaderField:@"X-Audit-Log-Reason"];
        capturedBody = request.HTTPBody;
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return data;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    [client sendMessage:@"test" toChannel:@"1" auditLogReason:@"spam filter" completion:nil];

    [self waitForExpectations:@[provExp] timeout:2];
    XCTAssertEqualObjects(capturedHeader, @"spam%20filter");
    NSDictionary *body = [NSJSONSerialization JSONObjectWithData:capturedBody options:0 error:nil];
    XCTAssertEqualObjects(body[@"content"], @"test");
    [CLMMockURLProtocol reset];
}

- (void)testDeleteChannel_DELETE {
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];
    NSDictionary *payload = @{@"id": @"123"};
    NSData *data = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        XCTAssertEqualObjects(request.HTTPMethod, @"DELETE");
        XCTAssertTrue([request.URL.absoluteString containsString:@"channels/999"]);
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return data;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    [client deleteChannelWithID:@"999" completion:^(CLMRESTResponse *response) {
        XCTAssertNil(response.error);
    }];

    [self waitForExpectations:@[provExp] timeout:2];
    [CLMMockURLProtocol reset];
}

- (void)testDeleteChannel_DELETE_WithAuditLogReason {
    __block NSString *capturedHeader = nil;
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        capturedHeader = [request valueForHTTPHeaderField:@"X-Audit-Log-Reason"];
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:204 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return nil;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    [client deleteChannelWithID:@"555" auditLogReason:@"cleanup" completion:^(CLMRESTResponse *response) {
        XCTAssertNil(response.error);
        XCTAssertEqual(response.statusCode, 204);
    }];

    [self waitForExpectations:@[provExp] timeout:2];
    XCTAssertEqualObjects(capturedHeader, @"cleanup");
    [CLMMockURLProtocol reset];
}

- (void)testEditMessage_PATCH_WithJSONBody {
    __block NSString *capturedMethod = nil;
    __block NSData *capturedBody = nil;
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        capturedMethod = request.HTTPMethod;
        capturedBody = request.HTTPBody;
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return [NSJSONSerialization dataWithJSONObject:@{} options:0 error:nil];
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    [client editMessageInChannel:@"111" messageID:@"222" newContent:@"edited" completion:nil];

    [self waitForExpectations:@[provExp] timeout:2];
    XCTAssertEqualObjects(capturedMethod, @"PATCH");
    NSDictionary *body = [NSJSONSerialization JSONObjectWithData:capturedBody options:0 error:nil];
    XCTAssertEqualObjects(body[@"content"], @"edited");
    [CLMMockURLProtocol reset];
}

- (void)testListMessages_WithQueryParams {
    __block NSString *capturedURL = nil;
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        capturedURL = request.URL.absoluteString;
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return [NSJSONSerialization dataWithJSONObject:@[] options:0 error:nil];
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    [client listMessagesInChannel:@"333" limit:@50 before:@"100" after:nil completion:nil];

    [self waitForExpectations:@[provExp] timeout:2];
    XCTAssertTrue([capturedURL containsString:@"channels/333/messages"]);
    XCTAssertTrue([capturedURL containsString:@"limit=50"]);
    XCTAssertTrue([capturedURL containsString:@"before=100"]);
    [CLMMockURLProtocol reset];
}

- (void)testListMessages_NoQueryParams {
    __block NSString *capturedURL = nil;
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        capturedURL = request.URL.absoluteString;
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return [NSJSONSerialization dataWithJSONObject:@[] options:0 error:nil];
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    [client listMessagesInChannel:@"333" limit:nil before:nil after:nil completion:nil];

    [self waitForExpectations:@[provExp] timeout:2];
    XCTAssertEqualObjects(capturedURL, @"https://discord.com/api/v10/channels/333/messages");
    [CLMMockURLProtocol reset];
}

- (void)testNetworkError_ProducesCLMErrorNetwork {
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        *outErr = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:@{NSLocalizedDescriptionKey: @"no connection"}];
        [provExp fulfill];
        return nil;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"];
    [client getCurrentUser:^(CLMRESTResponse *response) {
        XCTAssertNotNil(response.error);
        XCTAssertEqualObjects(response.error.domain, CLMErrorDomain);
        XCTAssertEqual(response.error.code, CLMErrorNetwork);
        NSError *underlying = response.error.userInfo[NSUnderlyingErrorKey];
        XCTAssertEqualObjects(underlying.domain, NSURLErrorDomain);
        XCTAssertEqual(underlying.code, NSURLErrorNotConnectedToInternet);
        [exp fulfill];
    }];

    [self waitForExpectations:@[provExp, exp] timeout:2];
    [CLMMockURLProtocol reset];
}

- (void)testHTTPStatus204_NoContent_Success {
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:204 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return nil;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"];
    // deleteMessage returns 204 with no content
    [client deleteMessageInChannel:@"1" messageID:@"2" completion:^(CLMRESTResponse *response) {
        XCTAssertNil(response.error);
        XCTAssertEqual(response.statusCode, 204);
        XCTAssertNil(response.JSONObject);
        XCTAssertTrue(response.isSuccess);
        [exp fulfill];
    }];

    [self waitForExpectations:@[provExp, exp] timeout:2];
    [CLMMockURLProtocol reset];
}

- (void)testHTTPStatus400_BadRequestMapsToCLMErrorBadRequest {
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:400 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return nil;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"];
    [client getCurrentUser:^(CLMRESTResponse *response) {
        XCTAssertNotNil(response.error);
        XCTAssertEqualObjects(response.error.domain, CLMErrorDomain);
        XCTAssertEqual(response.error.code, CLMErrorBadRequest);
        XCTAssertEqualObjects(response.error.userInfo[@"statusCode"], @(400));
        [exp fulfill];
    }];

    [self waitForExpectations:@[provExp, exp] timeout:2];
    [CLMMockURLProtocol reset];
}

- (void)testHTTPStatus403_ForbiddenMapsToCLMErrorForbidden {
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:403 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return nil;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"];
    [client getCurrentUser:^(CLMRESTResponse *response) {
        XCTAssertNotNil(response.error);
        XCTAssertEqual(response.error.code, CLMErrorForbidden);
        [exp fulfill];
    }];

    [self waitForExpectations:@[provExp, exp] timeout:2];
    [CLMMockURLProtocol reset];
}

- (void)testHTTPStatus404_NotFoundMapsToCLMErrorNotFound {
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:404 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return nil;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"];
    [client getCurrentUser:^(CLMRESTResponse *response) {
        XCTAssertNotNil(response.error);
        XCTAssertEqual(response.error.code, CLMErrorNotFound);
        [exp fulfill];
    }];

    [self waitForExpectations:@[provExp, exp] timeout:2];
    [CLMMockURLProtocol reset];
}

- (void)testCreateDM_POST_WithRecipientBody {
    __block NSString *capturedMethod = nil;
    __block NSData *capturedBody = nil;
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        capturedMethod = request.HTTPMethod;
        capturedBody = request.HTTPBody;
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return [NSJSONSerialization dataWithJSONObject:@{@"id": @"dm-1"} options:0 error:nil];
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    [client createDMWithRecipientID:@"user-42" completion:nil];

    [self waitForExpectations:@[provExp] timeout:2];
    XCTAssertEqualObjects(capturedMethod, @"POST");
    NSDictionary *body = [NSJSONSerialization JSONObjectWithData:capturedBody options:0 error:nil];
    XCTAssertEqualObjects(body[@"recipient_id"], @"user-42");
    [CLMMockURLProtocol reset];
}

- (void)testGetUserWithID_GET {
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];
    XCTestExpectation *exp = [self expectationWithDescription:@"completion"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        XCTAssertTrue([request.URL.absoluteString containsString:@"users/user-99"]);
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return [NSJSONSerialization dataWithJSONObject:@{@"id": @"user-99", @"username": @"bot"} options:0 error:nil];
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    [client getUserWithID:@"user-99" completion:^(CLMRESTResponse *response) {
        XCTAssertEqualObjects(response.JSONObject[@"username"], @"bot");
        [exp fulfill];
    }];

    [self waitForExpectations:@[provExp, exp] timeout:2];
    [CLMMockURLProtocol reset];
}

- (void)testGetCurrentUserGuilds_WithQueryParams {
    __block NSString *capturedURL = nil;
    XCTestExpectation *provExp = [self expectationWithDescription:@"provider invoked"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        capturedURL = request.URL.absoluteString;
        *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
        [provExp fulfill];
        return [NSJSONSerialization dataWithJSONObject:@[] options:0 error:nil];
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    [client getCurrentUserGuildsWithBefore:nil after:@"456" limit:@10 withCounts:@1 completion:nil];

    [self waitForExpectations:@[provExp] timeout:2];
    XCTAssertTrue([capturedURL containsString:@"users/@me/guilds"]);
    XCTAssertTrue([capturedURL containsString:@"after=456"]);
    XCTAssertTrue([capturedURL containsString:@"limit=10"]);
    XCTAssertTrue([capturedURL containsString:@"with_counts=1"]);
    [CLMMockURLProtocol reset];
}

- (void)testPerformRequest_DoesNotCrashWithNilCompletion {
    CLMRESTRequest *req = [CLMRESTRequest requestWithMethod:@"GET" route:@"users/@me"];
    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTAssertNoThrow([client performRequest:req completion:nil]);
}

- (void)testConcurrentRequests_EachGetsCorrectResponse {
    XCTestExpectation *prov1 = [self expectationWithDescription:@"provider 1"];
    XCTestExpectation *prov2 = [self expectationWithDescription:@"provider 2"];

    [CLMMockURLProtocol setResponseProvider:^NSData * _Nullable(NSURLRequest *request, NSHTTPURLResponse **outResp, NSError **outErr) {
        if ([request.URL.absoluteString containsString:@"users/@me"]) {
            *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
            [prov1 fulfill];
            return [NSJSONSerialization dataWithJSONObject:@{@"tag": @"user"} options:0 error:nil];
        } else if ([request.URL.absoluteString containsString:@"gateway"]) {
            *outResp = [[NSHTTPURLResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:@{}];
            [prov2 fulfill];
            return [NSJSONSerialization dataWithJSONObject:@{@"url": @"wss://gateway"} options:0 error:nil];
        }
        return nil;
    }];

    CLMTestRESTClient *client = [self makeClientWithMockProtocol];
    XCTestExpectation *exp1 = [self expectationWithDescription:@"completion 1"];
    XCTestExpectation *exp2 = [self expectationWithDescription:@"completion 2"];
    __block NSString *result1 = nil;
    __block NSString *result2 = nil;

    [client getCurrentUser:^(CLMRESTResponse *response) {
        result1 = response.JSONObject[@"tag"];
        [exp1 fulfill];
    }];
    [client getGatewayWithCompletion:^(CLMRESTResponse *response) {
        result2 = response.JSONObject[@"url"];
        [exp2 fulfill];
    }];

    [self waitForExpectations:@[prov1, prov2, exp1, exp2] timeout:2];
    XCTAssertEqualObjects(result1, @"user");
    XCTAssertEqualObjects(result2, @"wss://gateway");
    [CLMMockURLProtocol reset];
}

@end
