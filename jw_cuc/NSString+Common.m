//
//  NSString+Common.m
//  CUCMOOC
//
//  Created by  Phil Guo on 16/11/16.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "NSString+Common.h"

@implementation NSString (Common)
+(instancetype)stringWithNumber:(NSNumber *)num {
    return [NSString stringWithFormat:@"%@",num];
}
+ (instancetype)chineseStringWithNumber:(NSUInteger)number {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_Hans"];
    formatter.locale = locale;
    formatter.numberStyle = NSNumberFormatterRoundHalfDown;
    NSNumber *numberObj = [NSNumber numberWithUnsignedInteger:number];
    NSString *s = [formatter stringFromNumber:numberObj];
    return s;
}
+ (instancetype)chineseWeekStringWithNumber:(NSUInteger)number {
    if (number >= 1 && number <=6) {
        return [self chineseStringWithNumber:number];
    }else if (number == 7) {
        return @"日";
    }else {
        @throw [NSException exceptionWithName:@"JWInvalidArgumentException" reason:@"number not in 1-7" userInfo:nil];
    }
}
- (NSNumber *)numberObject {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    NSNumber *number = [formatter numberFromString:self];
    return number;
}
//- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
//    CGSize resultSize = CGSizeZero;
//    if (self.length <= 0) {
//        return resultSize;
//    }
//    NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
//    style.lineBreakMode = NSLineBreakByWordWrapping;
//    resultSize = [self boundingRectWithSize:CGSizeMake(floor(size.width), floor(size.height))//用相对小的 width 去计算 height / 小 heigth 算 width
//                                    options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin)
//                                 attributes:@{NSFontAttributeName: font,
//                                              NSParagraphStyleAttributeName: style}
//                                    context:nil].size;
//    resultSize = CGSizeMake(floor(resultSize.width + 1), floor(resultSize.height + 1));//上面用的小 width（height） 来计算了，这里要 +1
//    return resultSize;
//}
//
//- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
//    return [self getSizeWithFont:font constrainedToSize:size].height;
//}
//- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size{
//    return [self getSizeWithFont:font constrainedToSize:size].width;
//}
- (BOOL)isEmpty {
    return [[self trimWhitespace] length] == 0;
}
- (instancetype)trimWhitespace {
    NSMutableString *str = [self mutableCopy];
    [str replaceOccurrencesOfString:@" " withString:@"" options:(NSStringCompareOptions)0 range:NSMakeRange(0, str.length)];
    return str;
}
- (instancetype)stringAtIndex:(NSUInteger)index {
    return [self substringWithRange:NSMakeRange(index, 1)];
}
- (NSUInteger)firstIndexOfString:(NSString *)stringToFind {
    NSRange range = [self rangeOfString:stringToFind];
    return range.location;
}
- (BOOL)isAlphanumeric {
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_-"];
    s = [s invertedSet];
    NSRange range = [self rangeOfCharacterFromSet:s];
    if (range.location != NSNotFound) {
        return NO;
    }
    return YES;
    
}

@end
