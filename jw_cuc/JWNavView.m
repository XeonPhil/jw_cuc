//
//  JWNavView.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/17.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWNavView.h"
#import "JWWeekCollectionViewCell.h"
#define kCellIdentifier @"collection-cell-week"
@interface JWNavView()

@end
@implementation JWNavView
-(void)awakeFromNib {
    [super awakeFromNib];
//    UINib *weekCellNib = [UINib nibWithNibName:@"JWWeekCollectionViewCell" bundle:[NSBundle mainBundle]];
//    [_weekCollectionView registerNib:weekCellNib forCellWithReuseIdentifier:kCellIdentifier];
}
-(IBAction)addButtonTapped:(id)sender {
    
}
-(IBAction)settingButonTapped:(id)sender {
    
}

-(void)layoutSubviews {
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)_weekCollectionView.collectionViewLayout;
    layout.minimumInteritemSpacing = 0.0;
//    NSUInteger number = [_weekCollectionView numberOfItemsInSection:0];
    layout.itemSize = CGSizeMake(339 / 7.0, _weekCollectionView.frame.size.height);
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end