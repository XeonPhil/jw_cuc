//
//  JWCalendar.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/21.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//
#import "JWCalendar.h"
#import "JWWeekCollectionViewCell.h"

static NSString *kJWFetchCourseNotification = @"JWFetchCourseNotification";
static NSString *kWeekCellIdentifier = @"collection-cell-week";
const static uint kYearMonthDayUnitFlags = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
const static uint kYearMonthDayWeekdayUnitFlags = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday);
@interface NSCalendar(jw_common)
- (BOOL)isDateComponents:(NSDateComponents *)date earlierThanComponents:(NSDateComponents *)anotherDate;
@end
@implementation NSCalendar(jw_common)
- (BOOL)isDateComponents:(NSDateComponents *)date earlierThanComponents:(NSDateComponents *)anotherDate {
    NSDateComponents *compareResult = [self components:NSCalendarUnitDay fromDateComponents:date toDateComponents:anotherDate options:0];
    return compareResult.day >= 0 ? YES : NO;
}
@end
@interface NSDateComponents(jw_common)
+ (instancetype)componentsWithYear:(NSUInteger)y month:(NSUInteger)m day:(NSUInteger)d;
@end
@implementation NSDateComponents (jw_common)
+ (instancetype)componentsWithYear:(NSUInteger)y month:(NSUInteger)m day:(NSUInteger)d {
    NSDateComponents *obj = [self new];
    obj.year = y;
    obj.month = m;
    obj.day = d;
    return obj;
}
+ (instancetype)componentsWithDateDictionary:(NSDictionary *)dic {
    return [self componentsWithYear:[dic[@"year"] integerValue]
                              month:[dic[@"month"] integerValue]
                                day:[dic[@"day"] integerValue]];
}

@end
@interface JWCalendar()
@property (nonatomic,strong,readonly)NSCalendar *calendar;
@property (nonatomic,readonly)NSDateComponents *currentDateComponents;
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
    return [_calendar components:kYearMonthDayWeekdayUnitFlags fromDate:[NSDate date]];
}
- (NSUInteger)daysRemain {
    if (!_beginDay) {
        return 0;
    }else {
        return [[_calendar components:NSCalendarUnitDay
                   fromDateComponents:self.currentDateComponents
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
                           toDateComponents:self.currentDateComponents
                                    options:0]
                      day];
    if (days >= 0 && days < 16 * 7) {
        return days / 7 + 1;
    }else {
        return 1;
    }
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *currentDate = [_calendar components:kYearMonthDayWeekdayUnitFlags fromDate:[NSDate date]];
        NSUInteger year = currentDate.year;
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"cuc-calendar" ofType:@"plist"];
        NSDictionary *calendarPlistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
        NSDictionary *formerAcademicYearCalendar = calendarPlistDictionary[[NSString stringWithNumber:@(year-1)]];
        NSDictionary *latterAcademicYearCalendar = calendarPlistDictionary[[NSString stringWithNumber:@(year)]];
        
        NSDateComponents *formerAcademicYearEndDate = [NSDateComponents componentsWithDateDictionary:formerAcademicYearCalendar[@"end"]];
        NSDateComponents *latterAcademicYearStartDate = [NSDateComponents componentsWithDateDictionary:latterAcademicYearCalendar[@"start"]];
        NSDictionary *currentAcademicYearCalendar;
        if ([_calendar isDateComponents:currentDate earlierThanComponents:formerAcademicYearEndDate]) {
            _currentAcademicYear = year - 1;
            currentAcademicYearCalendar = formerAcademicYearCalendar;
        }else if([_calendar isDateComponents:latterAcademicYearStartDate earlierThanComponents:currentDate]){
            _currentAcademicYear = year;
            currentAcademicYearCalendar = latterAcademicYearCalendar;
        }
        NSDictionary *periods = currentAcademicYearCalendar[@"period"];
        for (NSString *key in periods) {
            NSString *startKeypath = [key stringByAppendingString:@".start"];
            NSDictionary *startDateDictionary = [periods valueForKeyPath:startKeypath];
            NSDateComponents *startDateComponents = [NSDateComponents componentsWithDateDictionary:startDateDictionary];
            
            NSString *endKeypath = [key stringByAppendingString:@".end"];
            NSDictionary *endDateDictionary = [periods valueForKeyPath:endKeypath];
            NSDateComponents *endDateComponents = [NSDateComponents componentsWithDateDictionary:endDateDictionary];
            BOOL isEarlierThanStageEnd = [_calendar isDateComponents:currentDate earlierThanComponents:endDateComponents];
            BOOL isLatterThanStageStart = [_calendar isDateComponents:startDateComponents earlierThanComponents:currentDate];
            if (isEarlierThanStageEnd && isLatterThanStageStart) {
                _currentStage = [[key substringToIndex:1] integerValue];
                switch (_currentStage) {
                    case JWStageSpringExam:
                    case JWStageSummerTerm:
                    case JWStageSummerVacation:
                        _currentAcademicYear +=1;
                    case JWStageAutumnTerm: {
                        _currentTerm = [JWTerm termWithYear:_currentAcademicYear termSeason:JWTermSeasonAutumn];
                        break;
                    }
                    case JWStageAutumnExam:
                    case JWStageWinterVacation:
                    case JWStageSpringTerm: {
                        _currentTerm = [JWTerm termWithYear:_currentAcademicYear+1 termSeason:JWTermSeasonSpring];
                        break;
                    }
                }
                if (_currentStage == JWStageSpringTerm || _currentStage == JWStageAutumnTerm) {
                    _beginDay = startDateComponents;
                }
                break;
            }
        }
    }
    return self;
}
- (NSString *)description  {
    return [NSString stringWithFormat:@"<%@: %p>%@",[self class],&self,@{
                                                                         @"currentTerm":self.currentTerm,
                                                                         @"beginDay":self.beginDay,
                                                                         @"currentDateComponents":self.currentDateComponents,
                                                                         @"currentAcademicYear":@(self.currentAcademicYear),
                                                                         @"currentWeek":@(self.currentWeek),
                                                                         @"daysRemain":@(self.daysRemain),
                                                                         @"currentStage":@(self.currentStage)
                                                                         }];
    
    
    
}
#pragma mark - data source
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    BOOL isWeekendCourseShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"kShowWeekendCourse"];
    return isWeekendCourseShown ? 7 : 5;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JWWeekCollectionViewCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kWeekCellIdentifier forIndexPath:indexPath];
    cell.weekLabel.text = [self weekStringForIndex:indexPath.row];
    if (indexPath.row == 6 && self.currentDateComponents.weekday == 1) {
        cell.activitied = YES;
    }
    
    if (indexPath.row + 1 == self.currentDateComponents.weekday - 1) {
        cell.activitied = YES;
    }
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
            components.day = (currentWeek - 1) * 7 + indexPath.row;
        }else {
            components.day = indexPath.row;
        }
        NSDate *currentDate = [_calendar dateByAddingComponents:components toDate:beginDate options:0];
        NSDateComponents *currentComponents = [_calendar components:kYearMonthDayUnitFlags fromDate:currentDate];
        cell.dateLabel.text = [NSString stringWithFormat:@"%lu-%lu",(unsigned long)currentComponents.month,(unsigned long)currentComponents.day];
        cell.weekLabel.text = [self weekStringForIndex:indexPath.row];
        return cell;
    }
    
}
-(NSString *)weekStringForIndex:(NSUInteger)index {
    static NSString *week = @"周";
    NSString *weekNumString = [NSString chineseWeekStringWithNumber:index+1];
    return [week stringByAppendingString:weekNumString];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath  {
    CGFloat width = collectionView.frame.size.width / [collectionView numberOfItemsInSection:indexPath.section];
    CGFloat height = collectionView.frame.size.height;
    return CGSizeMake(width, height);
}
@end
