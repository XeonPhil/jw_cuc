//
//  JWLoginViewController.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/17.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWLoginViewController.h"
#import "JWCourseDataController.h"
#import "JWKeyChainWrapper.h"
#import "JWHTMLSniffer.h"
#import "JWTerm.h"
#import "JWCalendar.h"
static NSString *kKeyChainIDKey = @"com.jwcuc.kKeyChainIDKey";
static NSString *kKeyChainPassKey = @"com.jwcuc.kKeyChainPassKey";
@interface JWLoginViewController ()
@property (nonatomic,strong,readonly)NSDateComponents *dateComponentsNow;
@end

@implementation JWLoginViewController
#pragma mark - common
- (void)awakeFromNib {
    [super awakeFromNib];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(studentIDTextChange) name:UITextFieldTextDidChangeNotification object:nil];
}
- (void)viewDidLoad {
    
    [_studentID addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    [_password addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - button presses
- (IBAction)login:(UIButton *)sender {
    [self.view endEditing:YES];
    _loginButton.hidden = YES;
    if ([self isInputValid]) {
        [JWKeyChainWrapper keyChainSaveID:_studentID.text];
        [JWKeyChainWrapper keyChainSavePassword:_password.text];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - others
- (void)textChanged:(id)sender {
    if (_studentID.text.length >= 4) {
    }
    
    BOOL isValid = _studentID.text.length == 12 && _password.text.length > 0;
    _loginButton.enabled = isValid;
}
- (BOOL)isInputValid {
    BOOL isValid = _studentID.text.length == 12 && _password.text.length > 0;
    return isValid;
}
@end
