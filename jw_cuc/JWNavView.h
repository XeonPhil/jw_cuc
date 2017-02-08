//
//  JWNavView.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/17.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWNavView : UIView 
@property (nonatomic,weak) IBOutlet UILabel *weekLabel;
@property (nonatomic,weak) IBOutlet UICollectionView *weekCollectionView;
@end
