//
//  NSMutableArray+common.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/26.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (common)
+(instancetype)arrayWithObjectType:(Class)type count:(NSUInteger)count;
@end
