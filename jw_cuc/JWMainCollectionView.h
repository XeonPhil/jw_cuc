//
//  JWMainCollectionView.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/18.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JWMainCourseFlowLayout.h"
@interface JWMainCollectionView : UICollectionView<UICollectionViewDelegateFlowLayout>
@property (nonatomic,readonly)JWMainCourseFlowLayout *myLayout;
@end
