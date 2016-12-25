//
//  ViewController.m
//  jw_cuc
//
//  Created by  Phil Guo on 16/12/24.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "ViewController.h"
#import "Ono.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *captchaImageView;
@property (strong,nonatomic) NSDictionary *header;
@property (weak, nonatomic) IBOutlet UITextField *captchaField;
@property (strong,nonatomic) NSURLSession *session;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)connect:(UIButton *)sender {
    NSURL *url = [NSURL URLWithString:@"index.jsp" relativeToURL:BASE_URL];
    NSURL *captchaURL = [NSURL URLWithString:@"http://jw.cuc.edu.cn/academic/getCaptcha.do"];
    //cookie
    NSData *temp = [NSData dataWithContentsOfURL:url];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    NSDictionary *cookieHeader = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    NSLog(@"%@\n%lu",cookieHeader,(unsigned long)temp.length);
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:cookieHeader];
//    headers[@"User-Agent"] = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36";
//    headers[@"Accept"] = @"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";
//    headers[@"Accept-Language"] = @"zh-cn";
    _header = cookieHeader;
    //send request
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSMutableURLRequest *captchaRequest = [NSMutableURLRequest requestWithURL:captchaURL];
    [captchaRequest setAllHTTPHeaderFields:headers];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:captchaRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        NSLog(@"Length:%lu\n",(unsigned long)data.length);
        dispatch_async(dispatch_get_main_queue(), ^(void){
            _captchaImageView.image = [UIImage imageWithData:data];
        });
    }];
    [task resume];
}
- (IBAction)login:(UIButton *)sender {
    if (_captchaField.text.length == 0) {
        return;
    }
    NSURL *loginURL = [NSURL URLWithString:@"http:jw.cuc.edu.cn/academic/j_acegi_security_check"];
    NSString *postBody = [NSString stringWithFormat:@"j_username=201410513013&j_password=2014105130gc&j_captcha=%@",_captchaField.text];
    NSData *postData = [postBody dataUsingEncoding:NSASCIIStringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)postBody.length];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loginURL];
    [request setAllHTTPHeaderFields:_header];
    request.HTTPMethod = @"POST";
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        NSLog(@"login!");
    }];
    [task resume];
}
- (IBAction)getTable:(id)sender {
    NSURL *courseURL = [NSURL URLWithString:@"http:jw.cuc.edu.cn/academic/student/currcourse/currcourse.jsdo"];
    NSMutableURLRequest *tableRequest = [NSMutableURLRequest requestWithURL:courseURL];
    tableRequest.HTTPMethod = @"GET";
    [tableRequest setAllHTTPHeaderFields:_header];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:tableRequest completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        [self getCourse];
    }];
    [task resume];
    
    
}
- (void)getCourse {
    NSURL *weekCourseURL = [NSURL URLWithString:@"http://jw.cuc.edu.cn/academic/manager/coursearrange/studentWeeklyTimetable.do?yearid=36&termid=3"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:weekCourseURL];
    request.HTTPMethod = @"GET";
    [request setValue:@"http://jw.cuc.edu.cn/academic/student/currcourse/currcourse.jsdo?groupId=&moduleId=2000" forHTTPHeaderField:@"Referer"];
    [request setAllHTTPHeaderFields:_header];
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error){
        ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:data error:nil];
        NSLog(@"%@",document);
    }];
    [task resume];
}

@end
