//
//  JWHTMLSniffer.m
//  jw_cuc
//
//  Created by  Phil Guo on 16/12/25.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "JWHTMLSniffer.h"
//#define JW_DISPATCH_QUENE 233
@interface JWHTMLSniffer()
@property (nonatomic,strong) NSDictionary *cookieHeader;
@property (nonatomic,strong) NSURLSession *session;
@end
@implementation JWHTMLSniffer
+(instancetype)sharedSniffer {
    static JWHTMLSniffer *sniffer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sniffer = [JWHTMLSniffer new];
    });
    return sniffer;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration];
    }
    return self;
}
-(void)getCookieWithBlock:(void (^)(NSDictionary *))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        NSData *temp = [NSData dataWithContentsOfURL:INDEX_URL];
        if (temp.length) {
            NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:INDEX_URL];
            _cookieHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
            NSLog(@"%@\n%lu",_cookieHeader,(unsigned long)temp.length);
            block(_cookieHeader);
        }
    });
}
-(void) requestLoginChallenge {
    
}
-(void)setHeadWithCookie:(NSDictionary *)cookieHeader {
    
}
-(void)getCaptchaWithCookie:(id)cookie andBlock:(void (^)(NSData *))block {
    
}
-(void)requestCourseHTMLWithParameters:(NSDictionary *)parameters andBlock:(void (^)(NSData *))block {
}
@end
