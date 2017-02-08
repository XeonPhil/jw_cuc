//
//  JWMainCourseFlowLayout.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/22.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWMainCourseFlowLayout.h"
#import "JWCourseStore+mainViewLayout.h"
@implementation JWMainCourseFlowLayout\
-(void)prepareLayout {
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = 0.0;
    self.minimumInteritemSpacing = 0.0;
}
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    NSMutableArray *attributeArray = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *theAttribute in array) {
        UICollectionViewLayoutAttributes *attribute = [theAttribute copy];
        NSIndexPath *indexpath = attribute.indexPath;
        NSUInteger day = indexpath.section;
        if (day == 0) {
            [attributeArray addObject:attribute];
            continue;
        }
        CGFloat magicNum = [[JWCourseStore sharedStore] cellPositionYOffsetAtIndexpath:attribute.indexPath];
        CGPoint origin = attribute.center;
        origin.y += magicNum;
        attribute.center = origin;
        [attributeArray addObject:attribute];
    }
    return attributeArray;
}
-(void)awakeFromNib {
    [super awakeFromNib];
}
@end
