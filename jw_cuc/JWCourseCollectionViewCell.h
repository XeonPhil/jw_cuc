//
//  JWCourseCollectionViewCell.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/6.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWCourseCollectionViewCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *classRoomLabel;
@property (nonatomic)NSUInteger height;
@end
