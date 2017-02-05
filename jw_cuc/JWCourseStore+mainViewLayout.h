//
//  JWCourseStore+mainViewLayout.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/5.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWCourseStore.h"

@interface JWCourseStore (mainViewLayout)
-(CGSize)sizeForCellAtIndexPath:(NSIndexPath *)indexPath;
-(CGFloat)cellPositionYOffsetAtIndexpath:(NSIndexPath *)indexpath;
@end
