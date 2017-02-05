//
//  JWCourseStore+mainViewLayout.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/5.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWCourseStore+mainViewLayout.h"

@implementation JWCourseStore (mainViewLayout)
-(CGSize)sizeForCellAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger day = indexPath.section;
    if (day == 0) {
        return CGSizeMake(25.0, kSingleRowHeight);
    }else {
        NSUInteger magicNum = arc4random() % 3 + 1;
        return CGSizeMake(50.0, magicNum * 48.5);
        
    }
}
-(CGFloat)cellPositionYOffsetAtIndexpath:(NSIndexPath *)indexpath {
    NSUInteger num = arc4random() % 3;
    return kSingleRowHeight * num;
}
@end
