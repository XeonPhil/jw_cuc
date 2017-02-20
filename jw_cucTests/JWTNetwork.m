//
//  JWTNetwork.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/20.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JWTerm.h"
#import "JWHTMLSniffer.h"
#define kRightID @"201410513013"
#define kRightPass @"2014105130gc"
#define kWrongID @"201413223222"
#define kWrongPass @"201413223222"
@interface JWTNetwork : XCTestCase
@property (nonatomic,strong,readonly)JWTerm *term;
@end

@implementation JWTNetwork

- (void)setUp {
    [super setUp];
    _term = [JWTerm termWithYear:2017 termSeason:JWTermSeasonSpring];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRight {
//    NSLog(@"%@\n%lu",[@[] description] ,(unsigned long)13);
    XCTestExpectation *expectationTrue = [self expectationWithDescription:@"right"];
    [[JWHTMLSniffer sharedSniffer] getCourseWithStudentID:kRightID password:kRightPass term:_term andBlock:^{
        XCTAssert(true);
        [expectationTrue fulfill];
    }failure:^(JWLoginFailure code){
        XCTAssert(false);
        [expectationTrue fulfill];
    }];
    [self waitForExpectationsWithTimeout:120 handler:^(NSError * _Nullable error) {
        NSLog(@"right");
    }];
}
- (void)testWrong {
    XCTestExpectation *expectationFalse = [self expectationWithDescription:@"wrong"];
    [[JWHTMLSniffer sharedSniffer] getCourseWithStudentID:kWrongID password:kWrongID term:_term andBlock:^{
        XCTAssert(false);
        [expectationFalse fulfill];
    }failure:^(JWLoginFailure code){
        XCTAssert(true);
        NSLog(@"wrong pass");
        [expectationFalse fulfill];
    }];
    [self waitForExpectationsWithTimeout:120 handler:^(NSError * _Nullable error) {
        NSLog(@"wrong");
    }];
}

@end
