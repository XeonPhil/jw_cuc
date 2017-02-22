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

//#define JW_DISPATCH_QUENE 233

@interface JWHTMLSniffer()
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic,strong)  NSDictionary     *cookieHeader;
@property (nonatomic,strong)  NSURLSession     *session;
@property (nonatomic,readonly)dispatch_queue_t quene;
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
- (void)requestDataWithUrl:(NSURL *)url andCompletionHandler:(void (^)(NSData *data,NSURLResponse *response,NSError *error))handler {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setAllHTTPHeaderFields:_cookieHeader];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:handler];
    [task resume];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 2.0;
        _session = [NSURLSession sessionWithConfiguration:configuration];
        _operationQueue = [NSOperationQueue new];
    }
    return self;
}
- (void)getCourseWithStudentID:(NSString *)ID password:(NSString *)password term:(JWTerm *)term andBlock:(CommonEmptyBlock)block failure:(void (^)(JWLoginFailure code))failure{
    void (^failureBlock)(JWLoginFailure) = ^(JWLoginFailure code){
        switch (code) {
            case JWLoginFailureErrorCaptcha:
                [self getCourseWithStudentID:ID password:password term:term andBlock:block failure:failure];
                break;
            default:
                NSLog(@"failure code as %lu",(unsigned long)code);
                failure(code);
                break;
        };
    };
    
    [self requestCaptchaWithBlock:^(NSData *data){
        [self recognizeImage:[UIImage imageWithData:data] withBlock:^(G8Tesseract *tesseract) {
            [self requestLoginChallengeWithName:ID andPassword:password andCaptcha:tesseract.recognizedText success:^{
                [self requestCourseHTMLWithTerm:term andBlock:^(NSArray<NSData *> *array){
                    [[JWCourseDataController defaultDateController] insertCoursesAtTerm:term withHTMLDataArray:array];
                    _cookieHeader = nil;
                    block();
                }failure:failureBlock];
            }failure:failureBlock];
        }];
    }failure:failureBlock];
}
#pragma mark - private method
#pragma mark - 1.construct cookie and get captcha image

-(void)getCookieWithBlock:(CommonEmptyBlock)block failure:(void (^)(JWLoginFailure code))failure{
    [self requestDataWithUrl:INDEX_URL andCompletionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error.code) {
            NSLog(@"occur as %@",[error description]);
            failure(JWLoginFailureUnknown);
        }
        if (data.length) {
            NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:INDEX_URL];
            _cookieHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
            NSLog(@"%@\n%lu",_cookieHeader,(unsigned long)data.length);
            block();
        }
    }];
}
-(void)requestCaptchaWithBlock:(void (^)(NSData *))block failure:(void (^)(JWLoginFailure code))failure{
    void (^requestCaptchaBlock)(void) = ^{
        NSAssert(_cookieHeader != nil, @"_header nil");
        [self requestDataWithUrl:CAPTCHA_URL andCompletionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
            if (error.code) {
                failure(JWLoginFailureUnknown);
            }
            block(data);
        }];
    };
    
    if (!_cookieHeader) {
        [self getCookieWithBlock:requestCaptchaBlock failure:failure];
    }else {
        requestCaptchaBlock();
    }
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
        NSString *recognizedText = [tesseract.recognizedText trimWhitespace];
        NSLog(@"captcha recognized as %@",recognizedText);
    };
    [_operationQueue addOperation:operation];
    
}
#pragma mark - 3.request login challenge
-(void)requestLoginChallengeWithName:(NSString *)name andPassword:(NSString *)pass andCaptcha:(NSString *)captcha success:(void (^)(void))success failure:(void (^)(JWLoginFailure code))failure {
    NSString *postBody = [NSString stringWithFormat:@"j_username=%@&j_password=%@&j_captcha=%@",name,pass,captcha];
    NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)postBody.length];
    //post request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:LOGIN_CHALLENGE_URL];
    NSAssert(_cookieHeader != nil, @"cookie header nil");
    [request setAllHTTPHeaderFields:_cookieHeader];
    request.HTTPMethod = @"POST";
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        if (error.code) {
            failure(JWLoginFailureUnknown);
        }
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
-(void)preloadCourseWithTerm:(JWTerm *)term andBlock:(void (^)(void))block failure:(void (^)(JWLoginFailure code))failure{
    NSString *queryString = [NSString stringWithFormat:@"?year=%ld&term=%ld",(unsigned long)term.year-1980,(unsigned long)term.season];
    NSString *urlString = [PRELOAD_COURSE_URL_STRING stringByAppendingString:queryString];
    NSURL *URL = [NSURL URLWithString:urlString relativeToURL:BASE_URL];
    [self requestDataWithUrl:URL andCompletionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        if (error.code) {
            failure(JWLoginFailureUnknown);
        }
        block();
    }];
}
#pragma mark - 5.download course
-(void)requestCourseHTMLWithTerm:(JWTerm *)term andBlock:(void (^)(NSArray<NSData *> *dataArray))block failure:(void (^)(JWLoginFailure code))failure{
    NSMutableArray *array = [NSMutableArray arrayWithObjectType:[NSData class] count:16];
    [self preloadCourseWithTerm:term andBlock:^(void){
        dispatch_group_t group = dispatch_group_create();
        _quene = dispatch_queue_create("course_download", DISPATCH_QUEUE_SERIAL);
#warning make quene concurrent
        for (NSUInteger week = 1; week <= 16; week++) {
            dispatch_group_enter(group);
            void (^handle)(NSData *data,NSInteger whichWeek) = ^(NSData *data,NSInteger whichWeek){
                array[whichWeek-1] = data;
                dispatch_group_leave(group);
            };
            dispatch_async(_quene, ^{
                [self requestSingleWeekCourseHTMLWithTerm:term andWeek:week andBlock:[handle copy] failure:failure];
            });
        }
        dispatch_group_notify(group,dispatch_get_main_queue(), ^{
            block(array);
        });
    }failure:failure];
}
-(void)requestSingleWeekCourseHTMLWithTerm:(JWTerm *)term andWeek:(NSInteger)week andBlock:(void (^)(NSData *,NSInteger whichWeek))block failure:(void (^)(JWLoginFailure code))failure{
    NSString *queryString = [NSString stringWithFormat:@"?yearid=%ld&termid=%ld&whichWeek=%ld",(unsigned long)term.year-1980,(unsigned long)term.season,(unsigned long)week];
    NSString *urlString = [COURSE_URL_STRING stringByAppendingString:queryString];
    NSURL *URL = [NSURL URLWithString:urlString relativeToURL:BASE_URL];
//    dispatch_barrier_sync(_quene, ^{
//    });
    NSData *data = [NSData dataWithContentsOfURL:URL];
    block(data,week);
//    [self ggg:data sd:week];
}
//- (void)ggg:(NSData *)data sd:(NSUInteger)whichWeek{
//    ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:data error:nil];
//    ONOXMLElement *elr = [[[document firstChildWithXPath:@"/html/body/table"] children] objectAtIndex:1];
//    NSLog(@"array element %ld:%@",whichWeek,[elr.children[0] stringValue]);
//}
@end
