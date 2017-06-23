//
//  jw_cucTests.m
//  jw_cucTests
//
//  Created by  Phil Guo on 17/2/13.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JWTerm.h"
#import "JWCourseDataController.h"
#import "JWCourseMO+CoreDataClass.h"
#import "JWCourseMO+CoreDataProperties.h"
#import <objc/runtime.h>
#import "JWCalendar.h"
@interface jw_cucTests : XCTestCase
@property (nonatomic,strong,readonly)JWCourseDataController *controller;
@end

@implementation jw_cucTests

- (void)setUp {
    [super setUp];
    [JWCalendar defaultCalendar];
    _controller = [JWCourseDataController new];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocati[[=[0-----------------------------------0.on of each test method in the class.
    [super tearDown];
}
-(void)testCoreData {
    for (int i = 1; i<=16; i++) {
        for (int j = 1; j<=5; i++) {
            NSLog(@"%@",[_controller coursesAtWeek:i andWeekDay:j]);
        }
    }
}
- (void)testExample {
    JWTerm *st = [JWTerm termWithYear:2017 termSeason:JWTermSeasonSpring];
    JWTerm *at = [JWTerm termWithYear:2017 termSeason:JWTermSeasonAutumn];
    XCTAssert([_controller hasDownloadCourseInTerm:st]);
    XCTAssert(![_controller hasDownloadCourseInTerm:at]);
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        _controller = [JWCourseDataController new];
    }];
}

@end
