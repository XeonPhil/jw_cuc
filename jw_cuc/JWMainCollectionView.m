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
+ (instancetype)defaultCollectionView {
    JWMainCollectionView *view = [[self alloc] initWithFrame:CGRectZero collectionViewLayout:[JWMainCourseFlowLayout new]];
    view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    return view;
}
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
- (NSArray <NSLayoutConstraint *> *)layout {
    NSLayoutConstraint *alignX = [NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.jw_superSuperView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0];
    NSLayoutConstraint *equthWidth = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.jw_superSuperView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
    NSLayoutConstraint *bottomSpace = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];
    NSLayoutConstraint *topSpace = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.superview attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
    NSArray *constraints = @[alignX,equthWidth,bottomSpace,topSpace];
    [NSLayoutConstraint activateConstraints:constraints];
    return constraints;
    
}
@end
