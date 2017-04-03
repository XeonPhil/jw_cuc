//
//  UIView+size.h
//  CUCMOOC
//
//  Created by  Phil Guo on 17/1/10.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//


@interface UIView (common)
@property (nonatomic,assign,readwrite) CGFloat jw_frameHeight;
@property (nonatomic,assign,readwrite) CGFloat jw_frameWidth;
@property (nonatomic,assign,readwrite) CGFloat jw_frameX;
@property (nonatomic,assign,readwrite) CGFloat jw_frameY;
@property (nonatomic,weak,readonly)UIView *jw_superSuperView;
@end
