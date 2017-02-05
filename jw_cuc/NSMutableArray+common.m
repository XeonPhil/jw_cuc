//
//  NSMutableArray+common.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/26.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "NSMutableArray+common.h"

@implementation NSMutableArray (common)
+(instancetype)arrayWithObjectType:(Class)type count:(NSUInteger)count {
    NSArray *array = [super arrayWithObjectType:type count:count];
    return [array mutableCopy];
}
@end
