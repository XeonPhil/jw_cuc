//
//  JWWeekCollectionViewCell.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/17.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWWeekCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *weekLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIView *line;
@property (nonatomic,getter=isActivitied) BOOL activitied;
@end
