//
//  JWWeekCollectionViewCell.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/17.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWWeekCollectionViewCell.h"

@implementation JWWeekCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setActivitied:(BOOL)activitied {
    _line.hidden = NO;
}
- (void)prepareForReuse {
    _line.hidden = YES;
}
@end
