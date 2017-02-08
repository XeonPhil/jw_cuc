//
//  JWCourseCollectionViewCell.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/6.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWCourseCollectionViewCell.h"

@implementation JWCourseCollectionViewCell
@synthesize height = _height;
-(void)setHeight:(NSUInteger)height {
    _height = height;
    NSUInteger labelTextLineFactor = height / 2;
    if (labelTextLineFactor == 0) {
        labelTextLineFactor ++;
    }
    NSInteger labelTextLineNum = 3 * labelTextLineFactor;
    _nameLabel.numberOfLines = labelTextLineNum;
    _classRoomLabel.numberOfLines = labelTextLineNum;
    
}
@end
