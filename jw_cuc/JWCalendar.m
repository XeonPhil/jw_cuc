//
//  JWCalendar.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/21.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//
#define kJWFetchCourseNotification @"JWFetchCourseNotification"
#import "JWCalendar.h"
#import "JWWeekCollectionViewCell.h"
#define kWeekCellIdentifier @"collection-cell-week"
#define kUnitFlags (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
@interface JWCalendar()
@property (nonatomic,strong,readonly)NSCalendar *calendar;
@end
@implementation JWCalendar
+ (instancetype)defaultCalendar {
    static JWCalendar *calendar;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        calendar = [JWCalendar new];
    });
    return calendar;
}
- (NSDateComponents *)currentDateComponents {
    return [_calendar components:kUnitFlags fromDate:[NSDate date]];
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents = [self currentDateComponents];
        BOOL isTermSpring = dateComponents.month < 8 && dateComponents.month > 1;
        JWTermSeason season = isTermSpring ? JWTermSeasonSpring : JWTermSeasonAutumn;
        _currentTerm = [JWTerm termWithYear:dateComponents.year termSeason:season];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:@"JWFetchCourseNotification" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            if (!_beginDay) {
                NSDateComponents *dateComponents = note.userInfo[@"date"];
                NSDate *date = [_calendar dateFromComponents:dateComponents];
                NSUInteger       dayNum = [note.userInfo[@"day"] integerValue];
                NSDate *beginDate = [_calendar dateByAddingUnit:NSCalendarUnitDay value:dayNum - 1 toDate:date options:0];
                _beginDay = [_calendar components:kUnitFlags fromDate:beginDate];
                NSLog(@"receive notification and begin day as %@",_beginDay);
            }
            
        }];
    }
    return self;
}
- (NSUInteger)daysRemain {
    if (!_beginDay) {
        return 0;
    }else {
        return [[_calendar components:NSCalendarUnitDay
              fromDateComponents:[self currentDateComponents]
                toDateComponents:_beginDay
                         options:0]
                day];
    }
}
- (NSUInteger)currentWeek {
    if (!_beginDay) {
        return 0;
    }
    NSInteger days = [[_calendar components:NSCalendarUnitDay
                     fromDateComponents:_beginDay
                       toDateComponents:[self currentDateComponents]
                                options:0]
                       day];
    NSLog(@"current week:%ld",(long)days);
    if (days >= 0 && days < 16 * 7) {
        return days / 7 + 1;
    }else {
        return 0;
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JWWeekCollectionViewCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWeekCellIdentifier forIndexPath:indexPath];
    cell.weekLabel.text = [self weekStringForIndex:indexPath.row];
    if (!_beginDay) {
        cell.dateLabel.text = @"12-21";
        return cell;
    }else {
        NSDateComponents *beginComponents = [_beginDay copy];
        beginComponents.hour = 1;
        beginComponents.minute = 1;
        beginComponents.second = 1;
        NSDate *beginDate = [_calendar dateFromComponents:beginComponents];
        NSDateComponents *components = [NSDateComponents new];
        NSUInteger currentWeek = [self currentWeek];
        if (currentWeek) {
            components.day = currentWeek - 1 + indexPath.row;
        }else {
            components.day = indexPath.row;
        }
        NSDate *currentDate = [_calendar dateByAddingComponents:components toDate:beginDate options:0];
        NSDateComponents *currentComponents = [_calendar components:kUnitFlags fromDate:currentDate];
        cell.dateLabel.text = [NSString stringWithFormat:@"%lu-%lu",currentComponents.month,currentComponents.day];
        cell.weekLabel.text = [self weekStringForIndex:indexPath.row];
        return cell;
    }
    
}
-(NSString *)weekStringForIndex:(NSUInteger)index {
    static NSString *week = @"周";
    NSString *weekNumString = [NSString chineseWeekStringWithNumber:index+1];
    return [week stringByAppendingString:weekNumString];
}
@end
