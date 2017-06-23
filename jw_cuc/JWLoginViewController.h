//
//  JWLoginViewController.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/17.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

@class JWTermPickerView;
@class JWLoginTextField;

@interface JWLoginViewController : UIViewController <UITextFieldDelegate,UIPickerViewDelegate>
@property (strong, nonatomic) UITextField *IDTextField;
@property (strong, nonatomic) UITextField *passwordTextField;
@property (strong, nonatomic) JWLoginTextField *IDTextFieldView;
@property (strong, nonatomic) JWLoginTextField *passwordTextFieldView;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)login:(UIButton *)sender;

@end
