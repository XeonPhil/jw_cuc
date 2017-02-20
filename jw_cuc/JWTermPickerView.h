//
//  JWTermPickerView.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/20.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWTermPickerView : UIView
@property (nonatomic,strong)IBOutlet UIPickerView *picker;
@property (nonatomic)NSUInteger semester;
@property (nonatomic)NSUInteger grade;
@end
