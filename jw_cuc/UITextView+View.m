//
//  UITextView+View.m
//  CUCMOOC
//
//  Created by  Phil Guo on 16/11/16.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "UITextView+View.h"

@implementation UITextView (View)
+(CGFloat)textViewHeightForText:(NSString *)text andWidth:(CGFloat)width andMaxHeight:(CGFloat)maxHeight{
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, maxHeight)];
    return size.height > maxHeight ? maxHeight :size.height;
}
@end
