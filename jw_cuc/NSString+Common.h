//
//  NSString+Common.h
//  CUCMOOC
//
//  Created by  Phil Guo on 16/11/16.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Common)
+(instancetype)stringWithNumber:(NSNumber *)num;
+ (instancetype)chineseStringWithNumber:(NSUInteger)number;
+ (instancetype)chineseWeekStringWithNumber:(NSUInteger)number;
- (CGSize)getSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGFloat)getHeightWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGFloat)getWidthWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (BOOL)isEmpty;
- (BOOL)isAlphanumeric;
@end
