//
//  JWMainCourseFlowLayout.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/22.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWMainCourseFlowLayout.h"
#import "JWMainViewController.h"
@implementation JWMainCourseFlowLayout
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
        CGSize size = attribute.frame.size;
        CGPoint origin = attribute.frame.origin;
        
        origin.y = self.cellPositionY(indexpath);
        origin.x += size.width * self.cellPositionXOffsetNum(indexpath);
        attribute.frame = CGRectMake(origin.x, origin.y, size.width, size.height);
        [attributeArray addObject:attribute];
    }
    return attributeArray;
}
-(void)awakeFromNib {
    [super awakeFromNib];
}
@end
