//
//  UIImage+common.m
//  CUCMOOC
//
//  Created by  Phil Guo on 16/12/3.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "UIImage+common.h"

@implementation UIImage (common)
-(UIImage *)cropTo:(CGRect)rect {
    CGImageRef CGImg = [self CGImage];
    CGImageRef cropppedImage = CGImageCreateWithImageInRect(CGImg, rect);
    CFAutorelease(cropppedImage);
    return [UIImage imageWithCGImage:cropppedImage];   
}
@end
