//
//  JWMainCourseFlowLayout.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/22.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWMainCourseFlowLayout : UICollectionViewFlowLayout
@property (nonatomic,copy)CGFloat (^cellPositionY)(NSIndexPath *indexpath);
@end
