//
//  JWMainCollectionView.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/18.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWMainCollectionView.h"

@interface JWMainCollectionView()<UICollectionViewDelegateFlowLayout>

@end
@implementation JWMainCollectionView
- (JWMainCourseFlowLayout *)myLayout {
    return (JWMainCourseFlowLayout *)self.collectionViewLayout;
}
@end
