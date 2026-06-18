#import <XCTest/XCTest.h>
#import "CLMRESTResponse.h"
#import "../Core/CLMErrors.h"

@interface CLMRESTResponseTests : XCTestCase
@end

@implementation CLMRESTResponseTests

- (CLMRESTResponse *)responseWithStatusCode:(NSInteger)code headers:(NSDictionary *)headers {
    CLMRESTResponse *r = [CLMRESTResponse new];
    r.statusCode = code;
    r.responseHeaders = headers;
    return r;
}

- (void)testIsSuccess_2xxNoError {
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:nil];
    XCTAssertTrue(r.isSuccess);
    XCTAssertFalse(r.isError);
}

- (void)testIsSuccess_3xxNoError {
    CLMRESTResponse *r = [self responseWithStatusCode:301 headers:nil];
    XCTAssertFalse(r.isSuccess);
    XCTAssertTrue(r.isError);
}

- (void)testIsError_4xx {
    CLMRESTResponse *r = [self responseWithStatusCode:404 headers:nil];
    XCTAssertFalse(r.isSuccess);
    XCTAssertTrue(r.isError);
}

- (void)testIsError_5xx {
    CLMRESTResponse *r = [self responseWithStatusCode:500 headers:nil];
    XCTAssertFalse(r.isSuccess);
    XCTAssertTrue(r.isError);
}

- (void)testIsSuccess_2xxWithError {
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:nil];
    r.error = [NSError errorWithDomain:CLMErrorDomain code:CLMErrorDecode userInfo:nil];
    XCTAssertFalse(r.isSuccess);
    XCTAssertTrue(r.isError);
}

- (void)testIsRateLimited_429 {
    CLMRESTResponse *r = [self responseWithStatusCode:429 headers:nil];
    XCTAssertTrue(r.isRateLimited);
}

- (void)testIsRateLimited_Non429 {
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:nil];
    XCTAssertFalse(r.isRateLimited);
}

- (void)testIsUnauthorized_401 {
    CLMRESTResponse *r = [self responseWithStatusCode:401 headers:nil];
    XCTAssertTrue(r.isUnauthorized);
}

- (void)testIsUnauthorized_Non401 {
    CLMRESTResponse *r = [self responseWithStatusCode:403 headers:nil];
    XCTAssertFalse(r.isUnauthorized);
}

- (void)testRateLimitBucket_ExactCase {
    NSDictionary *h = @{@"X-RateLimit-Bucket": @"bucket-abc"};
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:h];
    XCTAssertEqualObjects(r.rateLimitBucket, @"bucket-abc");
}

- (void)testRateLimitBucket_LowerCase {
    NSDictionary *h = @{@"x-ratelimit-bucket": @"bucket-123"};
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:h];
    XCTAssertEqualObjects(r.rateLimitBucket, @"bucket-123");
}

- (void)testRateLimitBucket_Missing {
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:@{}];
    XCTAssertNil(r.rateLimitBucket);
}

- (void)testRateLimitRemaining_ExactCase {
    NSDictionary *h = @{@"X-RateLimit-Remaining": @"42"};
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:h];
    XCTAssertEqualObjects(r.rateLimitRemaining, @(42));
}

- (void)testRateLimitRemaining_LowerCase {
    NSDictionary *h = @{@"x-ratelimit-remaining": @"0"};
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:h];
    XCTAssertEqualObjects(r.rateLimitRemaining, @(0));
}

- (void)testRateLimitRemaining_Missing {
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:@{}];
    XCTAssertNil(r.rateLimitRemaining);
}

- (void)testRateLimitResetAfter_ExactCase {
    NSDictionary *h = @{@"X-RateLimit-Reset-After": @"1.5"};
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:h];
    XCTAssertEqualWithAccuracy(r.rateLimitResetAfter.doubleValue, 1.5, 0.001);
}

- (void)testRateLimitResetAfter_LowerCase {
    NSDictionary *h = @{@"x-ratelimit-reset-after": @"0.25"};
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:h];
    XCTAssertEqualWithAccuracy(r.rateLimitResetAfter.doubleValue, 0.25, 0.001);
}

- (void)testRateLimitResetAfter_Missing {
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:@{}];
    XCTAssertNil(r.rateLimitResetAfter);
}

- (void)testRateLimitGlobal_ExactCase {
    NSDictionary *h = @{@"X-RateLimit-Global": @"true"};
    CLMRESTResponse *r = [self responseWithStatusCode:429 headers:h];
    XCTAssertTrue(r.rateLimitGlobal);
}

- (void)testRateLimitGlobal_LowerCase {
    NSDictionary *h = @{@"x-ratelimit-global": @"1"};
    CLMRESTResponse *r = [self responseWithStatusCode:429 headers:h];
    XCTAssertTrue(r.rateLimitGlobal);
}

- (void)testRateLimitGlobal_Missing {
    CLMRESTResponse *r = [self responseWithStatusCode:429 headers:@{}];
    XCTAssertFalse(r.rateLimitGlobal);
}

- (void)testRateLimitGlobal_Non429_Ignored {
    NSDictionary *h = @{@"X-RateLimit-Global": @"true"};
    CLMRESTResponse *r = [self responseWithStatusCode:200 headers:h];
    XCTAssertFalse(r.isRateLimited);
    XCTAssertTrue(r.rateLimitGlobal);
}

@end
