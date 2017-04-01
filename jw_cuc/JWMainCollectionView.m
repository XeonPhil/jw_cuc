//
//  JWMainCollectionView.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/18.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWMainCollectionView.h"

@interface JWMainCollectionView()<UICollectionViewDelegateFlowLayout>
@property (nonatomic,assign,readwrite)BOOL isCurrentShownView;
@end
@implementation JWMainCollectionView
- (void)makeViewShown {
    _isCurrentShownView = YES;
    self.leftView.isCurrentShownView = NO;
    self.rightView.isCurrentShownView = NO;
}
- (BOOL)isLeftShownView {
    return self.rightView.isCurrentShownView;
}
- (BOOL)isRightShownView {
    return self.leftView.isCurrentShownView;
}
- (void)setRightView:(JWMainCollectionView *)rightView {
    _rightView = rightView;
    rightView.leftView = self;
}
- (JWMainCourseFlowLayout *)myLayout {
    return (JWMainCourseFlowLayout *)self.collectionViewLayout;
}
@end
