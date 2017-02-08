//
//  JWCourseStore+mainViewLayout.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/5.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWCourseStore+mainViewLayout.h"
#import "JWCourse.h"
@implementation JWCourseStore (mainViewLayout)
-(CGSize)sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger day = indexPath.section;
    if (day == 0) {
        return CGSizeMake(25.0, kSingleRowHeight);
    }else {
        JWCourse *course = [self courseForWeek:1 atDay:day atIndex:indexPath.row];
        CGFloat magicNum = course.duration;
        CGFloat height = magicNum * kSingleRowHeight;
        return CGSizeMake(50.0, height);
    }
}
-(CGFloat)cellPositionYOffsetAtIndexpath:(NSIndexPath *)indexpath {
    NSUInteger day = indexpath.section;
    NSUInteger index = indexpath.row;
    JWCourse *course = [self courseForWeek:1 atDay:day atIndex:index];
    if (index == 0) {
        return kSingleRowHeight * (course.start - 1);
    }else {
        JWCourse *lastCourse = [self courseForWeek:1 atDay:day atIndex:index-1];
        CGFloat num = course.start - lastCourse.end - 1;
        return kSingleRowHeight * num;
    }
}
@end
