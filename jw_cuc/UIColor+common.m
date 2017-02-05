//
//  UIColorExtension.m
//  CUCMOOC
//
//  Created by  Phil Guo on 16/10/19.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "UIColor+common.h"

@implementation UIColor (UIColor_Expanded)
+(UIColor *)colorWithHexString:(NSString *)hexColor {
    NSScanner *scanner = [NSScanner scannerWithString:hexColor];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) {
        return nil;
    }
    return [UIColor colorWithRGBHex:hexNum];
}
+(UIColor *)colorWithRGBHex:(unsigned)hexRGB {
    int R = (hexRGB >> 16) & 0xff;
    int G = (hexRGB >> 8)  & 0xff;
    int B = hexRGB & 0xff;
    return [UIColor colorWithRed:R /255.0f
                           green:G /255.0f
                            blue:B /255.0f
                           alpha:1.0f];
}
+(UIColor *)randomCellColor {
    static NSArray *colorArray;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        colorArray = @[kCellColorGrey,kCellColorGreen1,kCellColorGreen2,kCellColorOrange,kCellColorBlue,kCellColorPurplr,kCellColorYellow,kCellColorPink];
    });
    NSUInteger i = arc4random() % 8;
    return colorArray[i];
}
@end
