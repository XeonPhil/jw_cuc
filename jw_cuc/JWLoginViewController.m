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
#import "JWLoginTextField.h"
static NSString *kKeyChainIDKey = @"com.jwcuc.kKeyChainIDKey";
static NSString *kKeyChainPassKey = @"com.jwcuc.kKeyChainPassKey";
static CGFloat originalBottomConstraintsConstant = 130.0;
@interface JWLoginViewController ()
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic,strong,readonly)NSDateComponents *dateComponentsNow;
@end

@implementation JWLoginViewController
#pragma mark - common
- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)viewDidLoad {
    UIColor *white = [UIColor whiteColor];
    _loginButton.layer.cornerRadius = 25;
//    [_loginButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    
    _IDTextFieldView = [self.view viewWithTag:100];
    _IDTextField = _IDTextFieldView.textField;
    _IDTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入学号" attributes:@{NSForegroundColorAttributeName: white}];
    _IDTextFieldView.imageView.image = [UIImage imageNamed:@"phone.png"];
    
    
    _passwordTextFieldView = [self.view viewWithTag:101];
    _passwordTextFieldView.imageView.image = [UIImage imageNamed:@"key"];
    _passwordTextField = _passwordTextFieldView.textField;
    _passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入密码" attributes:@{NSForegroundColorAttributeName: white}];
    
    [_IDTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
#ifdef DEBUG

    _loginButton.enabled = YES;
#endif
    [_passwordTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}
- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (keyboardEndFrame.size.height <= 0) {
        return;
    }
    _bottomConstraint.constant = kScreen_Height - keyboardEndFrame.origin.y + 50.0;
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];
    return;
}
- (void)keyboardWillHide:(NSNotification *)notification {
    _bottomConstraint.constant = originalBottomConstraintsConstant;
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];
    return;
}
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - button presses
- (IBAction)login:(UIButton *)sender {
    [self.view endEditing:YES];
    _loginButton.backgroundColor = [UIColor whiteColor];
    if ([self isInputValid]) {
        [JWKeyChainWrapper keyChainSaveID:_IDTextField.text];
        [JWKeyChainWrapper keyChainSavePassword:_passwordTextField.text];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)loginPressed:(id)sender {
    _loginButton.backgroundColor = [UIColor grayColor];
}

- (IBAction)loginPressedOutside:(id)sender {
    _loginButton.backgroundColor = [UIColor whiteColor];
}
#pragma mark - others
- (void)textChanged:(id)sender {
    if (_IDTextField.text.length >= 4) {
    }
    
    BOOL isValid = _IDTextField.text.length == 12 && _passwordTextField.text.length > 0;
    _loginButton.enabled = isValid;
}
- (BOOL)isInputValid {
    BOOL isValid = _IDTextField.text.length == 12 && _passwordTextField.text.length > 0;
    return isValid;
}
@end
