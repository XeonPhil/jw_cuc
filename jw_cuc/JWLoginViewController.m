//
//  JWLoginViewController.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/17.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWLoginViewController.h"
#import "JWCourseDataController.h"
#import "JWHTMLSniffer.h"
#import "JWTerm.h"
#import "JWTermPickerView.h"
#import "JWCalendar.h"
@interface JWLoginViewController ()
@property (nonatomic,strong)JWTerm *customTerm;
@property (nonatomic,strong)JWTerm *currentTerm;
@property (nonatomic,strong,readonly)NSDateComponents *dateComponentsNow;
@end

@implementation JWLoginViewController
@synthesize customTerm = _customTerm;
@synthesize currentTerm = _currentTerm;
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
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - accessor method
- (void)setCustomTerm:(JWTerm *)customTerm {
    if (customTerm) {
        _customTerm = customTerm;
    }
    [self refreshTermLabel];
}
- (void)setCurrentTerm:(JWTerm *)currentTerm {
    if (currentTerm) {
        _currentTerm = currentTerm;
        _customTerm = nil;
        
        _pickerView.grade = currentTerm.grade;
        _pickerView.semester = currentTerm.semester;
        
        _termLabel.hidden = NO;
//        _changeTermButton.hidden = NO;
        [self refreshTermLabel];
    }
}
#pragma mark - button presses
- (IBAction)done:(id)sender {
    _pickerView.hidden = YES;
    JWTerm *term = [JWTerm currentTermWithEnrolmentYear:_currentTerm.enrolmentYear];
    [term jw_setGrade:_pickerView.grade andSemester:_pickerView.semester];
    self.customTerm = term;
}

- (IBAction)changeTerm:(id)sender {
    _pickerView.hidden = NO;
}

- (IBAction)login:(UIButton *)sender {
    [self.view endEditing:YES];
//    [self refreshTermLabel];
    NSLog(@"start request");
    if ([self isInputValid]) {
        JWTerm *term = _customTerm ? _customTerm : _currentTerm;
        [[JWHTMLSniffer sharedSniffer] getCourseWithStudentID:_studentID.text password:_password.text term:term andBlock:^{
            NSLog(@"stop request and success");
            JWTerm *term = _customTerm ? _customTerm : _currentTerm;
            [self.navigationController popViewControllerAnimated:YES];
            NSUInteger week = [[JWCalendar defaultCalendar] currentWeek];
            if (!week) {
                week = 1;
            }
            [[JWCourseDataController defaultDateController] resetTerm:term andWeek:week];
        }failure:^(JWLoginFailure code) {
            NSLog(@"failure with code %lu",(unsigned long)code);
        }];
    }
}
#pragma mark - others
- (void)textChanged:(id)sender {
    if (_studentID.text.length >= 4) {
        NSInteger enrolmentYear = [[_studentID.text substringToIndex:4] integerValue];
        if (enrolmentYear) {
            self.currentTerm = [JWTerm currentTermWithEnrolmentYear:enrolmentYear];
        }
    }else {
        _termLabel.hidden = YES;
        _changeTermButton.hidden = YES;
        _pickerView.hidden = YES;
    }
    
    BOOL isValid = _studentID.text.length == 12 && _password.text.length > 0;
    _loginButton.enabled = isValid;
}

- (void)refreshTermLabel {
    if (_customTerm) {
        BOOL isTermSpring = _customTerm.season == JWTermSeasonSpring;
        NSString *gradeString = [NSString chineseStringWithNumber:_customTerm.grade];
        _termLabel.text = isTermSpring ? [NSString stringWithFormat:@"大%@下学期",gradeString] : [NSString stringWithFormat:@"大%@上学期",gradeString];
    }else {
        BOOL isTermSpring = _currentTerm.season == JWTermSeasonSpring;
        NSString *gradeString = [NSString chineseStringWithNumber:_currentTerm.grade];
        _termLabel.text = isTermSpring ? [NSString stringWithFormat:@"大%@下学期",gradeString] : [NSString stringWithFormat:@"大%@上学期",gradeString];
    }
}

- (BOOL)isInputValid {
    BOOL isValid = _studentID.text.length == 12 && _password.text.length > 0;
    return isValid;
}
@end
