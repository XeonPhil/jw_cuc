//
//  JWLoginViewController.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/17.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

@class JWTermPickerView;

@interface JWLoginViewController : UIViewController <UITextFieldDelegate,UIPickerViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *studentID;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)login:(UIButton *)sender;

@end
