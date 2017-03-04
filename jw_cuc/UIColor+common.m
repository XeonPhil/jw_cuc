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
+ (UIColor *)randomColorWithString:(NSString *)string {
    static NSMutableDictionary *indexsForColor;
    static dispatch_once_t dicOnceToken;
    dispatch_once(&dicOnceToken, ^{
        indexsForColor = [NSMutableDictionary dictionary];
    });
    static NSArray *colorArray;
    static dispatch_once_t arrayOnceToken;
    dispatch_once(&arrayOnceToken, ^{
        colorArray = @[kCellColorGrey,kCellColorGreen1,kCellColorGreen2,kCellColorOrange,kCellColorBlue,kCellColorPurplr,kCellColorYellow,kCellColorPink];
    });
    
    static NSMutableSet *colorSet;
    static dispatch_once_t setOnceToken;
    dispatch_once(&setOnceToken, ^{
        colorSet = [NSMutableSet set];
    });
    
    UIColor *color = indexsForColor[string];
    if (color) {
        return color;
    }else {
        NSUInteger index = [string hash] % 8;
        if ([colorSet count] == 8) {
            [colorSet removeAllObjects];
        }
        while ([colorSet containsObject:colorArray[index]]) {
            index = (index + 1) % 8;
        }
        UIColor *color = colorArray[index];
        [colorSet addObject:color];
        indexsForColor[string] = color;
        return color;
    }
    
    
}
@end
