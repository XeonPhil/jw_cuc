//
//  JWHTMLSniffer.h
//  jw_cuc
//
//  Created by  Phil Guo on 16/12/25.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JWLoginFailure) {
    JWLoginFailureUnknown,
    JWLoginFailureErrorCaptcha,
    JWLoginFailureWrongPassword,
    JWLoginFailureUnexistUser,
    JWLoginFailureUnupdated,
    JWLoginFailureBadNetWork
};
@interface JWHTMLSniffer : NSObject
//+ (instancetype)sharedSniffer;
+ (instancetype)newSniffer;
+ (BOOL)hasConnected;
- (void)getCourseWithStudentID:(NSString *)ID password:(NSString *)password term:(JWTerm *)term andBlock:(CommonEmptyBlock)block failure:(void (^)(JWLoginFailure code))failure;
- (void)getCourseAtTerm:(JWTerm *)term andBlock:(CommonEmptyBlock)block failure:(void (^)(JWLoginFailure code))failure;
@end
