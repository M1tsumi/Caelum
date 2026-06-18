#import <XCTest/XCTest.h>
#import "../Core/CLMErrors.h"

@interface CLMErrorsTests : XCTestCase
@end

@implementation CLMErrorsTests

- (void)testCLMErrorDomainConstant {
    XCTAssertEqualObjects(CLMErrorDomain, @"com.caelum.discord");
}

- (void)testCLMErrorMake_WithDescriptionAndUserInfo {
    NSError *err = CLMErrorMake(CLMErrorUnauthorized, @"not allowed", @{@"statusCode": @(401)});
    XCTAssertEqualObjects(err.domain, CLMErrorDomain);
    XCTAssertEqual(err.code, CLMErrorUnauthorized);
    XCTAssertEqualObjects(err.userInfo[NSLocalizedDescriptionKey], @"not allowed");
    XCTAssertEqualObjects(err.userInfo[@"statusCode"], @(401));
}

- (void)testCLMErrorMake_WithNilDescription {
    NSError *err = CLMErrorMake(CLMErrorNetwork, nil, nil);
    XCTAssertEqualObjects(err.domain, CLMErrorDomain);
    XCTAssertEqual(err.code, CLMErrorNetwork);
    XCTAssertNil(err.userInfo[NSLocalizedDescriptionKey]);
}

- (void)testCLMErrorMake_WithNilExtraUserInfo {
    NSError *err = CLMErrorMake(CLMErrorDecode, @"decode failed", nil);
    XCTAssertEqualObjects(err.domain, CLMErrorDomain);
    XCTAssertEqual(err.code, CLMErrorDecode);
    XCTAssertEqualObjects(err.userInfo[NSLocalizedDescriptionKey], @"decode failed");
}

- (void)testCLMErrorMake_OverlappingKeys_ExtraWins {
    NSError *err = CLMErrorMake(CLMErrorRateLimited, @"original",
                                @{NSLocalizedDescriptionKey: @"overridden"});
    XCTAssertEqualObjects(err.userInfo[NSLocalizedDescriptionKey], @"overridden");
}

- (void)testCLMErrorCodeForHTTPStatus_400 {
    XCTAssertEqual(CLMErrorCodeForHTTPStatus(400), CLMErrorBadRequest);
}

- (void)testCLMErrorCodeForHTTPStatus_401 {
    XCTAssertEqual(CLMErrorCodeForHTTPStatus(401), CLMErrorUnauthorized);
}

- (void)testCLMErrorCodeForHTTPStatus_403 {
    XCTAssertEqual(CLMErrorCodeForHTTPStatus(403), CLMErrorForbidden);
}

- (void)testCLMErrorCodeForHTTPStatus_404 {
    XCTAssertEqual(CLMErrorCodeForHTTPStatus(404), CLMErrorNotFound);
}

- (void)testCLMErrorCodeForHTTPStatus_429 {
    XCTAssertEqual(CLMErrorCodeForHTTPStatus(429), CLMErrorRateLimited);
}

- (void)testCLMErrorCodeForHTTPStatus_500 {
    XCTAssertEqual(CLMErrorCodeForHTTPStatus(500), CLMErrorServer);
}

- (void)testCLMErrorCodeForHTTPStatus_503 {
    XCTAssertEqual(CLMErrorCodeForHTTPStatus(503), CLMErrorServer);
}

- (void)testCLMErrorCodeForHTTPStatus_200 {
    XCTAssertEqual(CLMErrorCodeForHTTPStatus(200), CLMErrorUnknown);
}

- (void)testCLMErrorCodeForHTTPStatus_302 {
    XCTAssertEqual(CLMErrorCodeForHTTPStatus(302), CLMErrorUnknown);
}

- (void)testCLMErrorCodeForHTTPStatus_418 {
    XCTAssertEqual(CLMErrorCodeForHTTPStatus(418), CLMErrorUnknown);
}

- (void)testCLMErrorCodeForHTTPStatus_600 {
    XCTAssertEqual(CLMErrorCodeForHTTPStatus(600), CLMErrorServer);
}

@end
