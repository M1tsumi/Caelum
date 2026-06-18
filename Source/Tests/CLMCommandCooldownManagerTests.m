#import <XCTest/XCTest.h>
#import "CLMCommandCooldownManager.h"

@interface CLMCommandCooldownManagerTests : XCTestCase
@property (nonatomic, strong) CLMCommandCooldownManager *manager;
@end

@implementation CLMCommandCooldownManagerTests

- (void)setUp {
    [super setUp];
    self.manager = [[CLMCommandCooldownManager alloc] initWithQueue:nil];
}

- (void)testCanExecute_NoCooldown {
    XCTAssertTrue([self.manager canExecuteCommand:@"ping" userId:@"user1" cooldown:0 now:1000]);
}

- (void)testCanExecute_NegativeCooldown {
    XCTAssertTrue([self.manager canExecuteCommand:@"ping" userId:@"user1" cooldown:-1 now:1000]);
}

- (void)testCanExecute_FirstExecution {
    XCTAssertTrue([self.manager canExecuteCommand:@"ping" userId:@"user1" cooldown:5 now:1000]);
}

- (void)testRecordThenCannotExecute {
    [self.manager recordExecutionForCommand:@"ping" userId:@"user1" at:1000];
    XCTAssertFalse([self.manager canExecuteCommand:@"ping" userId:@"user1" cooldown:5 now:1002]);
}

- (void)testCooldownExpired_CanExecute {
    [self.manager recordExecutionForCommand:@"ping" userId:@"user1" at:1000];
    XCTAssertTrue([self.manager canExecuteCommand:@"ping" userId:@"user1" cooldown:5 now:1006]);
}

- (void)testCooldownExactlyAtEdge_CanExecute {
    [self.manager recordExecutionForCommand:@"ping" userId:@"user1" at:1000];
    XCTAssertTrue([self.manager canExecuteCommand:@"ping" userId:@"user1" cooldown:5 now:1005]);
}

- (void)testCooldownJustBeforeEdge_CannotExecute {
    [self.manager recordExecutionForCommand:@"ping" userId:@"user1" at:1000];
    XCTAssertFalse([self.manager canExecuteCommand:@"ping" userId:@"user1" cooldown:5 now:1004.999]);
}

- (void)testDifferentCommands_IndependentCooldowns {
    [self.manager recordExecutionForCommand:@"ping" userId:@"user1" at:1000];
    XCTAssertTrue([self.manager canExecuteCommand:@"pong" userId:@"user1" cooldown:5 now:1002]);
}

- (void)testDifferentUsers_IndependentCooldowns {
    [self.manager recordExecutionForCommand:@"ping" userId:@"user1" at:1000];
    XCTAssertTrue([self.manager canExecuteCommand:@"ping" userId:@"user2" cooldown:5 now:1002]);
}

- (void)testMultipleConsecutiveRecordings {
    [self.manager recordExecutionForCommand:@"ping" userId:@"user1" at:1000];
    [self.manager recordExecutionForCommand:@"ping" userId:@"user1" at:1003];
    XCTAssertFalse([self.manager canExecuteCommand:@"ping" userId:@"user1" cooldown:5 now:1006]);
    XCTAssertTrue([self.manager canExecuteCommand:@"ping" userId:@"user1" cooldown:5 now:1009]);
}

@end
