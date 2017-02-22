//
//  JWTermPickerView.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/20.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWTermPickerView.h"
@interface JWTermPickerView()<UIPickerViewDataSource,UIPickerViewDelegate>

@end
@implementation JWTermPickerView
@synthesize semester = _semester;
@synthesize grade = _grade;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (NSUInteger)semester {
    return [_picker selectedRowInComponent:1] + 1;
}
- (void)setSemester:(NSUInteger)semester {
    if (semester < 1 || semester > 2) {
        return;
    }
    [_picker selectRow:semester - 1 inComponent:1 animated:YES];
}
- (NSUInteger)grade {
    return [_picker selectedRowInComponent:0] + 1;
}
- (void)setGrade:(NSUInteger)grade {
    if (grade < 1 || grade > 4) {
        return;
    }
    [_picker selectRow:grade - 1 inComponent:0 animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return 4;
        case 1:
            return 2;
        default:
            return 0;
    }
}
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component) {
        case 0: {
            switch (row) {
                case 0:
                    return [[NSAttributedString alloc] initWithString:@"大一"];
                case 1:
                    return [[NSAttributedString alloc] initWithString:@"大二"];
                case 2:
                    return [[NSAttributedString alloc] initWithString:@"大三"];
                case 3:
                    return [[NSAttributedString alloc] initWithString:@"大四"];
                default:
                    break;
            }
        }
        case 1: {
            switch (row) {
                case 0:
                    return [[NSAttributedString alloc] initWithString:@"上学期"];
                case 1:
                    return [[NSAttributedString alloc] initWithString:@"下学期"];
            }
        }
        default:
            return nil;
    }
}
@end
