//
//  JWCollectionView.m
//  jw_cuc
//
//  Created by  Phil Guo on 16/12/26.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "JWCollectionView.h"

@implementation JWCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        
    }
    return self;
}

@end
