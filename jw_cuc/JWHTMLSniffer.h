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
    JWLoginFailureUnupdated
};
@interface JWHTMLSniffer : NSObject
+ (instancetype) sharedSniffer;
//-(void) getCaptchaWithBlock:(void (^)(NSData * data))block;
//-(void) requestLoginChallengeWithName:(NSString *)name andPassword:(NSString *)pass andCaptcha:(NSString *)captcha success:(void (^)(void))success failure:(void (^)(void))failure;
//-(void) requestCourseHTMLWithYear:(NSInteger)year term:(NSInteger)term andWeek:(NSInteger)week withBlock:(void (^)(NSArray<NSData *> *dataArray))block;
- (void)getCourseWithStudentID:(NSString *)ID password:(NSString *)password term:(JWTerm *)term andBlock:(CommonEmptyBlock)block failure:(void (^)(JWLoginFailure code))failure;
- (void)getCourseAtTerm:(JWTerm *)term andBlock:(CommonEmptyBlock)block failure:(void (^)(JWLoginFailure code))failure;
@end
