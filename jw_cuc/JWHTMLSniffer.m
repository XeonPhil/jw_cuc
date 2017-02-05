//
//  JWHTMLSniffer.m
//  jw_cuc
//
//  Created by  Phil Guo on 16/12/25.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "JWHTMLSniffer.h"
#import "Ono.h"
#import "JWHTMLSniffer.h"
#import "HTMLParser.h"
#import "TesseractOCR/TesseractOCR.h"
#import "JWCourseStore.h"
//#define JW_DISPATCH_QUENE 233
@interface JWHTMLSniffer()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic,strong)  NSDictionary     *cookieHeader;
@property (nonatomic,strong)  NSURLSession     *session;
@property (strong,nonatomic)  UIImage          *image;
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
        _operationQueue = [NSOperationQueue new];
    }
    return self;
}
-(void)recognizeImage:(UIImage *)image withBlock:(void (^)(G8Tesseract *tesseract))block{
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];
    
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeSingleLine;
    operation.tesseract.charWhitelist = @"0123456789";
    if (!image) {
        operation.tesseract.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://jw.cuc.edu.cn/academic/getCaptcha.do"]]];
    }else {
        operation.tesseract.image = image;
    }
    operation.tesseract.rect = CGRectMake(0, 0, 70, 16);
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        block(tesseract);
    };
    [_operationQueue addOperation:operation];
    
}
- (void)getCourseWithBlock:(EmptyBlock)block {
    [[JWHTMLSniffer sharedSniffer] getCaptchaWithBlock:^(NSData *data){
        _image = [UIImage imageWithData:data];
        [self recognizeImage:_image withBlock:^(G8Tesseract *tesseract) {
            NSString *recognizedText = [tesseract.recognizedText stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSLog(@"captcha recognized as %@",recognizedText);
            [[JWHTMLSniffer sharedSniffer] requestLoginChallengeWithName:@"201410513013" andPassword:@"2014105130gc" andCaptcha:recognizedText success:^{
                [[JWHTMLSniffer sharedSniffer] requestCourseHTMLWithYear:2017 term:1 andWeek:0 withBlock:^(NSArray<NSData *> *array){
                    [[JWCourseStore sharedStore] establishCourseStoreWithArray:array];
                    block();
                }];
            }failure:^(void){
                [self getCourseWithBlock:block];
            }];
        }];
    }];
}
#pragma mark - login&captcha
-(void)getCookieWithBlock:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),^{
        NSData *temp = [NSData dataWithContentsOfURL:INDEX_URL];
        if (temp.length) {
            NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:INDEX_URL];
            _cookieHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
            NSLog(@"%@\n%lu",_cookieHeader,(unsigned long)temp.length);
            block();
        }
    });
}
-(void)getCaptchaWithBlock:(void (^)(NSData *))block {
    if (!_cookieHeader) {
        [self getCookieWithBlock:^{
            [self requestCaptchaWithBlock:block];
        }];
    }else {
        [self requestCaptchaWithBlock:block];
    }
    
}
-(void)requestLoginChallengeWithName:(NSString *)name andPassword:(NSString *)pass andCaptcha:(NSString *)captcha success:(void (^)(void))success failure:(void (^)(void))failure {    NSString *postBody = [NSString stringWithFormat:@"j_username=%@&j_password=%@&j_captcha=%@",name,pass,captcha];
//    NSString *postBody = [NSString stringWithFormat:@"j_username=201410513013&j_password=2014105130gc&j_captcha=%@",_captchaField.text];
    NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)postBody.length];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:LOGIN_CHALLENGE_URL];
    NSAssert(_cookieHeader != nil, @"cookie header nil");
    [request setAllHTTPHeaderFields:_cookieHeader];
    request.HTTPMethod = @"POST";
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        if (response.URL.query) {
            failure();
        }else {
            NSLog(@"login!");
            success();
        }
    }];
    [task resume];
}
-(void)requestCaptchaWithBlock:(void (^)(NSData *))block {
    NSAssert(_cookieHeader != nil, @"_header nil");
    NSMutableURLRequest *captchaRequest = [NSMutableURLRequest requestWithURL:CAPTCHA_URL];
    [captchaRequest setAllHTTPHeaderFields:_cookieHeader];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:captchaRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^(void){
            block(data);
        });
    }];
    [task resume];
}
#pragma mark - course
-(void)preloadCourseWithYear:(NSInteger)year term:(NSInteger)term andBlock:(void (^)(void))block {
    NSString *queryString = [NSString stringWithFormat:@"?year=%ld&term=%ld",year-1980,term];
    NSString *urlString = [PRELOAD_COURSE_URL_STRING stringByAppendingString:queryString];
    NSURL *URL = [NSURL URLWithString:urlString relativeToURL:BASE_URL];
    NSMutableURLRequest *tableRequest = [NSMutableURLRequest requestWithURL:URL];
    tableRequest.HTTPMethod = @"GET";
    [tableRequest setAllHTTPHeaderFields:_cookieHeader];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:tableRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        block();
    }];
    [task resume];
}
-(void)requestSingleWeekCourseHTMLWithYear:(NSInteger)year term:(NSInteger)term andWeek:(NSInteger)week andBlock:(void (^)(NSData *,NSInteger whichWeek))block {
    NSString *queryString = [NSString stringWithFormat:@"?yearid=%ld&termid=%ld&whichWeek=%ld",year-1980,term,week];
    NSString *urlString = [COURSE_URL_STRING stringByAppendingString:queryString];
    NSURL *URL = [NSURL URLWithString:urlString relativeToURL:BASE_URL];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    block(data,week);
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
//    
//    request.HTTPMethod = @"GET";
//    [request setValue:PRELOAD_COURSE_URL_STRING forHTTPHeaderField:@"Referer"];
//    [request setAllHTTPHeaderFields:_cookieHeader];
//    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
//        block(data);
//    }];
//    [task resume];
}
-(void)requestCourseHTMLWithYear:(NSInteger)year term:(NSInteger)term andWeek:(NSInteger)week withBlock:(void (^)(NSArray<NSData *> *dataArray))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:16];
    [self preloadCourseWithYear:year term:term andBlock:^(void){
        for (NSInteger i = 0; i < 16; i++) {
            [array addObject:[NSNull null]];
        }
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t quene = dispatch_queue_create("course_download", DISPATCH_QUEUE_CONCURRENT);
        for (NSUInteger i = 0; i < 16; i++) {
            dispatch_group_async(group, quene, ^{
                [self requestSingleWeekCourseHTMLWithYear:year term:term andWeek:i+1 andBlock:^(NSData *data,NSInteger whichWeek){
                    [array replaceObjectAtIndex:i withObject:data];
                    }];
            });
        }
        dispatch_group_notify(group,dispatch_get_main_queue(), ^{
            block(array);
        });
    }];
}
@end
