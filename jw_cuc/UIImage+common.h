//
//  UIImage+common.h
//  CUCMOOC
//
//  Created by  Phil Guo on 16/12/3.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (common)
//+(instancetype)imageWithURL:(NSURL *)url andBlock:(void (^)(UIImage *image))block;
-(UIImage *)cropTo:(CGRect)rect;
@end
