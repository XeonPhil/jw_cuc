//
//  JWTDemo.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/3/4.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "JWKeyChainWrapper.h"
static NSString *kKeyChainIDKey = @"com.jwcuc.kKeyChainIDKey";
static NSString *kKeyChainPassKey = @"com.jwcuc.kKeyChainPassKey";
@interface JWTDemo : XCTestCase
@property (nonatomic,readonly)JWKeyChainWrapper *wrapper;
@property (nonatomic,readonly)JWCourseDataController *d;
@end

@implementation JWTDemo

- (void)setUp {
    [super setUp];
    _wrapper =[JWKeyChainWrapper new];
    _d = [JWCourseDataController defaultDateController];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
- (void)testExample {
    [JWKeyChainWrapper keyChainDeleteIDAndkey];
//    XCTAssert(![_d hasSavedStudentID])
//    XCTAssert([_d hasSavedStudentID]);
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
