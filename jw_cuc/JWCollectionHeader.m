//
//  JWCollectionHeader.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/15.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWCollectionHeader.h"
#import "JWMainViewController.h"
@interface JWCollectionHeader()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
@implementation JWCollectionHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(375.0 / 6, 76);
    layout.minimumInteritemSpacing = 0;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"kCell"];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"kCell" forIndexPath:indexPath];
    cell.backgroundColor = [self randomColor];
    return cell;
}
-(UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return color;
}

@end
