//
//  JWTerm.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/10.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//


typedef NS_ENUM(NSUInteger, JWTermSeason) {
    JWTermSeasonNil    = -1,
    JWTermSeasonSpring = 1,
    JWTermSeasonAutumn = 3
};
typedef NS_ENUM(NSUInteger, JWTermGrade) {
    JWTermGradeNil = -1,
    JWTermGradeOne = 1,
    JWTermGradeTwo,
    JWTermGradeThree,
    JWTermGradeFour
};
typedef NS_ENUM(NSUInteger, JWTermSemester) {
    JWTermSemesterNil = -1,
    JWTermSemesterOne = 1,
    JWTermSemesterTwo
};
@interface JWTerm : NSObject
@property (nonatomic,readonly)JWTermGrade grade;
@property (nonatomic,readonly)JWTermSemester semester;

@property (nonatomic,readonly)JWTermSeason season;
@property (nonatomic)NSUInteger year;
@property (nonatomic,readonly)NSUInteger enrolmentYear;
+ (instancetype)termWithYear:(NSUInteger)year termSeason:(JWTermSeason)termSeason;
+ (instancetype)currentTermWithEnrolmentYear:(NSUInteger)enrolmentYear;
- (void)jw_setGrade:(JWTermGrade)grade andSemester:(JWTermSemester)semester;
- (instancetype)initWithYear:(NSUInteger)year termSeason:(JWTermSeason)termSeason enrolmentYear:(NSUInteger)enrolmentyear;
@end
