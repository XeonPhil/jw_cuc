//
//  JWTerm.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/10.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWTerm.h"
@interface JWTerm()
@property (nonatomic,readwrite)NSUInteger enrolmentYear;
@property (nonatomic,readwrite)JWTermGrade grade;
@property (nonatomic,readwrite)JWTermSemester semester;

@end
@implementation JWTerm
@synthesize enrolmentYear = _enrolmentYear;
+ (instancetype)currentTerm {
    return [self currentTermWithEnrolmentYear:0];
}
+ (instancetype)termWithYear:(NSUInteger)year termSeason:(JWTermSeason)termSeason {
    JWTerm *termObj = [[JWTerm alloc] initWithYear:year
                                        termSeason:termSeason
                                     enrolmentYear:0];
    return termObj;
}
+ (instancetype)currentTermWithEnrolmentYear:(NSUInteger)enrolmentYear {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitflags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *dateComponents = [calendar components:unitflags fromDate:[NSDate date]];
    
    BOOL isTermSpring = dateComponents.month < 8 && dateComponents.month > 1;
    
    JWTermSeason season = isTermSpring ? JWTermSeasonSpring : JWTermSeasonAutumn;
    JWTerm *termObj = [[JWTerm alloc] initWithYear:dateComponents.year
                                        termSeason:season
                                     enrolmentYear:enrolmentYear];
    if (termObj.grade >= 1 && termObj.grade <= 4) {
        return termObj;
    }else {
        return nil;
    }
}
- (instancetype)initWithYear:(NSUInteger)year termSeason:(JWTermSeason)termSeason enrolmentYear:(NSUInteger)enrolmentyear {
    self = [super init];
    if (self) {
        _year = year;
        _season = termSeason;
        _enrolmentYear = enrolmentyear;
    }
    return self;
}
- (void)jw_setGrade:(JWTermGrade)grade andSemester:(JWTermSemester)semester {
    _season = semester == JWTermSemesterOne ? JWTermSeasonAutumn : JWTermSeasonSpring;

    if (_enrolmentYear) {
        switch (_season) {
            case JWTermSeasonSpring:
                _year = _enrolmentYear + grade;
                break;
            case JWTermSeasonAutumn:
                _year = _enrolmentYear + grade - 1;
                break;
            case JWTermSeasonNil:
                break;
        }
    }
}
- (JWTermGrade)grade {
    if (_enrolmentYear) {
        if (self.season == JWTermSeasonSpring) {
            return (JWTermGrade)self.year - _enrolmentYear;
        }else {
            return (JWTermGrade)self.year - _enrolmentYear + 1;
        }
    }else {
        return JWTermGradeNil;
    }
}
//- (void)setGrade:(JWTermGrade)grade {
//    if (_enrolmentYear) {
//        switch (_season) {
//            case JWTermSeasonSpring:
//                _year = _enrolmentYear + grade;
//                break;
//            case JWTermSeasonAutumn:
//                _year = _enrolmentYear + grade - 1;
//                break;
//            case JWTermSeasonNil:
//                break;
//        }
//    }
//}
- (JWTermSemester)semester {
    if (self.season != JWTermSeasonNil) {
        if (self.season == JWTermSeasonSpring) {
            return JWTermSemesterTwo;
        }else {
            return JWTermSemesterOne;
        }
    }else {
        return JWTermSemesterNil;
    }
}
//- (void)setSemester:(JWTermSemester)semester {
//    _season = semester == JWTermSemesterOne ? JWTermSeasonAutumn : JWTermSeasonSpring;
//}
- (NSString *)description
{
    return [NSString stringWithFormat:@"<JWTerm: %p>\n\tyear=%lu\n\tseason=%lu\n\tenrolmentYear=%lu\n\tgrade=%lu\n\tsemester=%lu\n", &self,(unsigned long)_year,(unsigned long)_season,(unsigned long)_enrolmentYear,(unsigned long)_grade,(unsigned long)_semester];
}
@end
