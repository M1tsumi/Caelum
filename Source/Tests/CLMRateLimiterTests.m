#import <XCTest/XCTest.h>
#import "CLMRateLimiter.h"

@interface CLMRateLimiterTests : XCTestCase
@property (nonatomic, strong) CLMRateLimiter *limiter;
@end

@implementation CLMRateLimiterTests

- (void)setUp {
    [super setUp];
    self.limiter = [[CLMRateLimiter alloc] init];
}

- (void)testEnqueueRoute_ExecutesBlock {
    XCTestExpectation *exp = [self expectationWithDescription:@"block executed"];
    [self.limiter enqueueRoute:@"channels/123/messages" perform:^{
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testUpdateBucket_SetsReset {
    XCTestExpectation *exp = [self expectationWithDescription:@"bucket delayed"];
    [self.limiter updateBucket:@"channels" remaining:0 resetAfter:0.1 isGlobal:NO];
    __block CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [self.limiter enqueueRoute:@"channels/123/messages" perform:^{
        CFAbsoluteTime elapsed = CFAbsoluteTimeGetCurrent() - start;
        XCTAssertGreaterThanOrEqual(elapsed, 0.08);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testUpdateBucket_SkipsZeroReset {
    XCTestExpectation *exp = [self expectationWithDescription:@"immediate"];
    [self.limiter updateBucket:@"channels" remaining:5 resetAfter:0 isGlobal:NO];
    __block CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [self.limiter enqueueRoute:@"channels/999" perform:^{
        CFAbsoluteTime elapsed = CFAbsoluteTimeGetCurrent() - start;
        XCTAssertLessThan(elapsed, 0.5);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testUpdateBucket_GlobalRateLimit {
    XCTestExpectation *exp = [self expectationWithDescription:@"global delayed"];
    [self.limiter updateBucket:@"" remaining:0 resetAfter:0.1 isGlobal:YES];
    __block CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [self.limiter enqueueRoute:@"channels/123/messages" perform:^{
        CFAbsoluteTime elapsed = CFAbsoluteTimeGetCurrent() - start;
        XCTAssertGreaterThanOrEqual(elapsed, 0.08);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testUpdateBucket_GlobalClearsBucketLimits {
    XCTestExpectation *exp = [self expectationWithDescription:@"global-before-bucket"];
    [self.limiter updateBucket:@"channels" remaining:0 resetAfter:0.5 isGlobal:NO];
    [self.limiter updateBucket:@"" remaining:0 resetAfter:0.05 isGlobal:YES];
    __block CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [self.limiter enqueueRoute:@"channels/123" perform:^{
        CFAbsoluteTime elapsed = CFAbsoluteTimeGetCurrent() - start;
        XCTAssertGreaterThanOrEqual(elapsed, 0.03);
        XCTAssertLessThan(elapsed, 0.4);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testEnqueueRoute_DispatchesToMainQueue {
    XCTestExpectation *exp = [self expectationWithDescription:@"main queue"];
    [self.limiter enqueueRoute:@"test" perform:^{
        XCTAssertTrue([NSThread isMainThread]);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testDifferentBucket_NotAffected {
    XCTestExpectation *exp = [self expectationWithDescription:@"other bucket fine"];
    [self.limiter updateBucket:@"channels" remaining:0 resetAfter:10 isGlobal:NO];
    __block CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    [self.limiter enqueueRoute:@"guilds/456" perform:^{
        CFAbsoluteTime elapsed = CFAbsoluteTimeGetCurrent() - start;
        XCTAssertLessThan(elapsed, 1);
        [exp fulfill];
    }];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

@end
