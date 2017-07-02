//
//  JWCourseMO+CoreDataClass.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/9.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWCourseMO+CoreDataClass.h"
@interface JWCourseMO()
@property (nonatomic,strong)NSDateComponents *dateComponents;
@end
@implementation JWCourseMO
@synthesize dateComponents = _dateComponents;
@synthesize length = _length;
@synthesize dateString = _dateString;
- (NSUInteger)length {
    if (self.end && self.start) {
        return self.end - self.start + 1;
    }else {
        return 0;
    }
    
}
- (NSString *)dateString {
    NSUInteger month = self.dateComponents.month;
    NSUInteger day   = self.dateComponents.day;
    if (month && day) {
        return [NSString stringWithFormat:@"%ld-%ld",(unsigned long)month,day];
    }else {
        return [NSString string];
    }
    
}
@end
