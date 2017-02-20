//
//  JWTTermTest.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/20.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JWTerm.h"
@interface JWTTermTest : XCTestCase
@property (nonatomic,strong)JWTerm *curTerm;
@property (nonatomic,strong)JWTerm *term;
@end

@implementation JWTTermTest

- (void)setUp {
    [super setUp];
    _curTerm = [JWTerm currentTermWithEnrolmentYear:2014];
    _term = [JWTerm termWithYear:2017 termSeason:JWTermSeasonSpring];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)testTerm {
    [_curTerm jw_setGrade:JWTermGradeTwo andSemester:JWTermSemesterOne];
    
    XCTAssert(_curTerm != nil);
    XCTAssert(_curTerm.year == 2015);
    XCTAssert(_curTerm.season == JWTermSeasonAutumn);
}

- (void)testExample {
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
