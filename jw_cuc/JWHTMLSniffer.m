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
#pragma mark - constuction
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
- (void)getCourseWithStudentID:(NSString *)ID password:(NSString *)password term:(JWTerm *)term andBlock:(CommonEmptyBlock)block failure:(void (^)(JWLoginFailure code))failure{
    [[JWHTMLSniffer sharedSniffer] checkCaptchaWithBlock:^(NSData *data){
        _image = [UIImage imageWithData:data];
        [self recognizeImage:_image withBlock:^(G8Tesseract *tesseract) {
            NSString *recognizedText = [tesseract.recognizedText trimWhitespace];
            NSLog(@"captcha recognized as %@",recognizedText);
            [[JWHTMLSniffer sharedSniffer] requestLoginChallengeWithName:ID andPassword:password andCaptcha:recognizedText success:^{
                [[JWHTMLSniffer sharedSniffer] requestCourseHTMLWithTerm:term andBlock:^(NSArray<NSData *> *array){
                    [[JWCourseDataController defaultDateController] insertCoursesAtTerm:term withHTMLDataArray:array];
                    block();
                }];
            }failure:^(JWLoginFailure code){
                NSLog(@"failure code as %ld",(unsigned long)code);
                switch (code) {
                    case JWLoginFailureErrorCaptcha:
                        [self getCourseWithStudentID:ID password:password term:term andBlock:block failure:failure];
                        break;
                    default:
                        failure(code);
                        break;
                };
            }];
        }];
    }];
}
#pragma mark - private method
#pragma mark - 1.construct cookie and get captcha image
-(void)checkCaptchaWithBlock:(void (^)(NSData *))block {
    if (!_cookieHeader) {
        [self getCookieWithBlock:^{
            [self requestCaptchaWithBlock:block];
        }];
    }else {
        [self requestCaptchaWithBlock:block];
    }
    
}
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
#pragma mark - 2.OCR recognize captcha
-(void)recognizeImage:(UIImage *)image withBlock:(void (^)(G8Tesseract *tesseract))block {
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
#pragma mark - 3.request login challenge
-(void)requestLoginChallengeWithName:(NSString *)name andPassword:(NSString *)pass andCaptcha:(NSString *)captcha success:(void (^)(void))success failure:(void (^)(JWLoginFailure code))failure {
    NSString *postBody = [NSString stringWithFormat:@"j_username=%@&j_password=%@&j_captcha=%@",name,pass,captcha];
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
        NSString *query = response.URL.query;
        if (query) {
            ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:data error:nil];
            NSString *xpath = @"//*[@id=\"error\"]";
            NSString *error = [[document firstChildWithXPath:xpath] stringValue];
            if ([error containsString:@"验证码"] ) {
                failure(JWLoginFailureErrorCaptcha);
            }else if ([error containsString:@"不存在"]) {
                failure(JWLoginFailureUnexistUser);
            }else if ([error containsString:@"不匹配"]) {
                failure(JWLoginFailureWrongPassword);
            }else {
                failure(JWLoginFailureUnknown);
            }
        }else {
            NSLog(@"login!");
            success();
        }
    }];
    [task resume];
}
#pragma mark - 4.preload course
-(void)preloadCourseWithTerm:(JWTerm *)term andBlock:(void (^)(void))block {
    NSString *queryString = [NSString stringWithFormat:@"?year=%ld&term=%ld",(unsigned long)term.year-1980,(unsigned long)term.season];
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
#pragma mark - 5.download course
-(void)requestCourseHTMLWithTerm:(JWTerm *)term andBlock:(void (^)(NSArray<NSData *> *dataArray))block {
    NSMutableArray *array = [NSMutableArray arrayWithObjectType:[NSData class] count:16];
    [self preloadCourseWithTerm:term andBlock:^(void){
        dispatch_group_t group = dispatch_group_create();
        dispatch_queue_t quene = dispatch_queue_create("course_download", DISPATCH_QUEUE_SERIAL);
        for (NSUInteger week = 1; week <= 16; week++) {
            dispatch_group_async(group, quene, ^{
                [self requestSingleWeekCourseHTMLWithTerm:term andWeek:week andBlock:^(NSData *data,NSInteger whichWeek){
                    array[whichWeek-1] = data;
                    }];
            });
        }
        dispatch_group_notify(group,dispatch_get_main_queue(), ^{
            block(array);
        });
    }];
}
-(void)requestSingleWeekCourseHTMLWithTerm:(JWTerm *)term andWeek:(NSInteger)week andBlock:(void (^)(NSData *,NSInteger whichWeek))block {
    NSString *queryString = [NSString stringWithFormat:@"?yearid=%ld&termid=%ld&whichWeek=%ld",(unsigned long)term.year-1980,(unsigned long)term.season,(unsigned long)week];
    NSString *urlString = [COURSE_URL_STRING stringByAppendingString:queryString];
    NSURL *URL = [NSURL URLWithString:urlString relativeToURL:BASE_URL];
    NSData *data = [NSData dataWithContentsOfURL:URL];
    block(data,week);
}
@end
