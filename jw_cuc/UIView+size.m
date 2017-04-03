//
//  UIView+size.m
//  CUCMOOC
//
//  Created by  Phil Guo on 17/1/10.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "UIView+size.h"

@implementation UIView (size)
-(CGFloat)jw_frameWidth {
    return self.frame.size.width;
}
-(CGFloat)jw_frameHeight {
    return self.frame.size.height;
}
- (CGFloat)jw_frameX {
    return self.frame.origin.x;
}
- (CGFloat)jw_frameY {
    return self.frame.origin.y;
}
- (void)setJw_frameWidth:(CGFloat)jw_frameWidth {
    self.frame = CGRectMake(self.jw_frameX, self.jw_frameY, jw_frameWidth, self.jw_frameHeight);
}
- (void)setJw_frameHeight:(CGFloat)jw_frameHeight {
    self.frame = CGRectMake(self.jw_frameX, self.jw_frameY, self.jw_frameWidth, jw_frameHeight);
}
- (void)setJw_frameX:(CGFloat)jw_frameX {
    self.frame = CGRectMake(jw_frameX, self.jw_frameY, self.jw_frameWidth, self.jw_frameHeight);
}
- (void)setJw_frameY:(CGFloat)jw_frameY {
    self.frame = CGRectMake(self.jw_frameX, jw_frameY, self.jw_frameWidth, self.jw_frameHeight);
}
@end
