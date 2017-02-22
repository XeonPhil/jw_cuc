//
//  JWCalendar.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/21.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWTerm.h"
@interface JWCalendar : NSObject <UICollectionViewDataSource>
@property (nonatomic,strong)JWTerm *currentTerm;
@property (nonatomic,strong)NSDateComponents *beginDay;
@property (nonatomic,readonly)NSUInteger daysRemain;
@property (nonatomic,readonly)NSUInteger currentWeek;
+ (instancetype)defaultCalendar;
//+ (NSUInteger)currentWeek;
//- (NSDateComponents *)beginDayForTerm:(JWTerm *)term;
@end
