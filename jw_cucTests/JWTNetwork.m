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

}
- (void)testWrong {

}

@end
