//
//  ViewController.m
//  jw_cuc
//
//  Created by  Phil Guo on 16/12/24.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "ViewController.h"
#import "Ono.h"
#import "JWHTMLSniffer.h"
#import "HTMLParser.h"
#import "TesseractOCR/TesseractOCR.h"
#import "JWCourseStore.h"
@interface ViewController ()<G8TesseractDelegate>
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (weak, nonatomic) IBOutlet UIImageView *captchaImageView;
@property (strong,nonatomic) NSDictionary *header;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UITextField *captchaField;
@property (strong,nonatomic) NSURLSession *session;
@property (weak, nonatomic) IBOutlet UILabel *result;
@property (nonatomic) NSUInteger count;
@property (weak, nonatomic) IBOutlet UITextView *textField;
@property (strong,nonatomic) UIImage *image;
@end

@implementation ViewController
-(void)setImage:(UIImage *)image {
    _image = image;
    _captchaImageView.image = image;
}
-(void)viewDidLoad {
    [super viewDidLoad];
    _textField.hidden = YES;
    _operationQueue = [NSOperationQueue new];
    
}
-(void)recognizeImage:(UIImage *)image withBlock:(void (^)(G8Tesseract *tesseract))block{
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];

    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeSingleLine;
    operation.delegate = self;
    operation.tesseract.charWhitelist = @"0123456789";
    if (!image) {
        operation.tesseract.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://jw.cuc.edu.cn/academic/getCaptcha.do"]]];
    }else {
        operation.tesseract.image = image;
    }
    operation.tesseract.rect = CGRectMake(0, 0, 70, 16);
    
    // Specify the function block that should be executed when Tesseract
    // finishes performing recognition on the image
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        // Fetch the recognized text
        
        block(tesseract);
    };
    
    [_operationQueue addOperation:operation];

}
- (BOOL)shouldCancelImageRecognitionForTesseract:(G8Tesseract *)tesseract {
    return NO;  // return YES, if you need to cancel recognition prematurely
}
- (IBAction)connect:(UIButton *)sender {
    [[JWHTMLSniffer sharedSniffer] getCaptchaWithBlock:^(NSData *data){
        _image = [UIImage imageWithData:data];
    }];
}
- (IBAction)login:(UIButton *)sender {
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"900" ofType:@"html"];
    ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:[NSData dataWithContentsOfFile:filepath] error:nil];
    NSArray *courseTableArray = [[document.rootElement firstChildWithXPath:@"/html/body/table"] children];
    NSMutableArray *courseArray = [NSMutableArray arrayWithArray:courseTableArray];
    [courseArray removeObjectAtIndex:0];
    NSMutableArray *courses = [NSMutableArray array];
    for (ONOXMLElement *element in courseArray) {
        NSMutableDictionary *course = [NSMutableDictionary dictionary];
        course[@"date"] = [element.children[0] stringValue];
        course[@"name"] = [element.children[1] stringValue];
        course[@"day"] = [element.children[5] stringValue];
        course[@"start"] = [[element.children[6] stringValue] substringWithRange:NSMakeRange(1, 1)];
        course[@"end"] = [[element.children[6] stringValue] substringWithRange:NSMakeRange(3,1)];
        course[@"building"] = [element.children[9] stringValue];
        course[@"classroom"] = [element.children[10] stringValue];
        [courses addObject:course];
    }
    NSLog(@"%@",courses);
}
- (IBAction)getTable:(id)sender {
    [[JWHTMLSniffer sharedSniffer] getCaptchaWithBlock:^(NSData *data){
        _image = [UIImage imageWithData:data];
        [self recognizeImage:_image withBlock:^(G8Tesseract *tesseract) {
            NSString *recognizedText = [tesseract.recognizedText stringByReplacingOccurrencesOfString:@" " withString:@""];
            _result.text = recognizedText;
            [[JWHTMLSniffer sharedSniffer] requestLoginChallengeWithName:@"201410513013" andPassword:@"2014105130gc" andCaptcha:recognizedText success:^{
                [[JWHTMLSniffer sharedSniffer] requestCourseHTMLWithYear:2017 term:1 andWeek:0 withBlock:^(NSArray<NSData *> *array){
//                    HTMLParser *parser = [HTMLParser new];
//                    NSMutableArray *courseArray = [NSMutableArray array];
//                    for (NSData *data in array) {
//                        [courseArray addObject:[parser parseHTML:data]];
//                    }
//                    NSLog(@"%lu",(unsigned long)[courseArray count]);
                    [[JWCourseStore sharedStore] establishCourseStoreWithArray:array];
                }];
            }failure:^(void){
                [self getTable:nil];
            }];
        }];
    }];
}
- (void)getCourse {
    [[JWHTMLSniffer sharedSniffer] getCaptchaWithBlock:^(NSData *data){
        _image = [UIImage imageWithData:data];
        [self recognizeImage:_image withBlock:^(G8Tesseract *tesseract) {
            NSString *recognizedText = [tesseract.recognizedText stringByReplacingOccurrencesOfString:@" " withString:@""];
            _result.text = recognizedText;
            [[JWHTMLSniffer sharedSniffer] requestLoginChallengeWithName:@"201410513013" andPassword:@"2014105130gc" andCaptcha:recognizedText success:^{
                [[JWHTMLSniffer sharedSniffer] requestCourseHTMLWithYear:2017 term:1 andWeek:0 withBlock:^(NSArray<NSData *> *array){
                    HTMLParser *parser = [HTMLParser new];
                    NSMutableArray *courseArray = [NSMutableArray array];
                    for (NSData *data in array) {
                        [courseArray addObject:[parser parseHTML:data]];
                    }
                    NSLog(@"%lu",(unsigned long)[courseArray count]);
                }];
            }failure:^(void){
                [self getTable:nil];
            }];
        }];
    }];
}

@end
