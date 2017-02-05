//
//  NSArray+common.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/26.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "NSArray+common.h"

@implementation NSArray (common)
+(instancetype)arrayWithObjectType:(Class)type count:(NSUInteger)count  {
    NSMutableArray *array = [NSMutableArray array];
    for (NSUInteger i = 0; i < count; i++) {
        [array addObject:[type new]];
    }
    return array;
}
@end
