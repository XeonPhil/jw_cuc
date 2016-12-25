//
//  JWHTMLSniffer.h
//  jw_cuc
//
//  Created by  Phil Guo on 16/12/25.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWHTMLSniffer : NSObject
+(instancetype) sharedSniffer;
-(void) getCaptchaWithCookie:( id)cookie andBlock:(void (^)(NSData * data))block;
-(void) requestCourseHTMLWithParameters:( NSDictionary *)parameters andBlock:(void (^)(NSData * data))block;
@end
