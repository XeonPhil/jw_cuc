//
//  JWCalendarTest.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/3/4.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//
#import "JWCalendar.h"
#import <XCTest/XCTest.h>

@interface JWCalendarTest : XCTestCase
@property JWCalendar *c;
@end

@implementation JWCalendarTest

- (void)setUp {
    [super setUp];
    _c = [JWCalendar defaultCalendar];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    XCTAssert(_c.currentAcademicYear == 2016);
    XCTAssert(_c.currentStage == JWStageSpringTerm);
    XCTAssert(_c.currentWeek == 1);
    NSLog(@"%ld",_c.daysRemain);
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
