//
//  UITextView+View.h
//  CUCMOOC
//
//  Created by  Phil Guo on 16/11/16.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextView (View)
+(CGFloat)textViewHeightForText:(NSString *)text andWidth:(CGFloat)width andMaxHeight:(CGFloat)maxHeight;
@end
