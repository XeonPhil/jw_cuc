//
//  JWTerm.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/10.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//


typedef NS_ENUM(NSUInteger, JWTermSeason) {
    JWTermSeasonSpring = 1,
    JWTermSeasonAutumn = 3,
};
@interface JWTerm : NSIndexPath
@property (nonatomic,readonly)NSUInteger year;
@property (nonatomic,readonly)JWTermSeason season;
+ (instancetype)termWithYear:(NSUInteger)year termSeason:(JWTermSeason)termSeason;
@end
