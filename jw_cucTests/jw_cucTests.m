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
    JWTerm *term = [JWTerm termWithYear:2017 termSeason:JWTermSeasonSpring];
    NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"201701" withExtension:@"html"];
    NSData *hData = [NSData dataWithContentsOfURL:url];
    XCTAssertNotNil(hData);
    [[JWCourseDataController defaultDateController] insertCoursesAtTerm:term withHTMLDataArray:@[hData]];
    NSError *err = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:0 userInfo:nil];
    [_controller.managedObjectiContext save:&err];
    XCTAssertEqual(err.code,0);
    NSFetchRequest *f = [[NSFetchRequest alloc] initWithEntityName:@"Course"];
    NSArray *a = [_controller.managedObjectiContext executeFetchRequest:f error:nil];
    XCTAssert(a.count > 0);
    //    unsigned int count=0;
    //    JWCourseMO *mo = a[0];
    //    objc_property_t *props = class_copyPropertyList([mo class],&count);
    //    for ( int i=0;i<count;i++ )
    //    {
    //        const char *name = property_getName(props[i]);
    //        NSString *prop = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
    //    }
    for (JWCourseMO *mo in a) {
        if ([mo.courseName isEqualToString:@"媒体内容安全技术"]) {
            XCTAssert(mo.start == 1);
            XCTAssert(mo.end == 4);
        }
//        unsigned int count=0;
//        objc_property_t *props = class_copyPropertyList([mo class],&count);
//        for ( int i=0;i<count;i++ )
//        {
//            const char *name = property_getName(props[i]);
//            NSString *prop = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
//            XCTAssertNotNil([mo valueForKey:prop]);
//            XCTAssertNotEqual(0, (NSUInteger)[mo valueForKey:prop]);
//        }
//        NSLog(@"%@",[mo description]);
    }
    XCTAssert([[JWCalendar defaultCalendar] daysRemain] == 5);
    XCTAssert([[JWCalendar defaultCalendar] currentWeek] == 0);
}
- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
}

@end
