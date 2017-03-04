//
//  JWCalendar.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/21.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWTerm.h"
typedef NS_ENUM(NSUInteger,JWStage) {
    JWStageAutumnTerm = 1,
    JWStageAutumnExam,
    JWStageWinterVacation,
    JWStageSpringTerm,
    JWStageSpringExam,
    JWStageSummerTerm,
    JWStageSummerVacation
};

@interface JWCalendar : NSObject <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong)JWTerm *currentTerm;
@property (nonatomic,readonly)NSUInteger daysRemain;
@property (nonatomic,readonly)NSUInteger currentWeek;
@property (nonatomic,readonly)NSUInteger enrolmentYear;
@property (nonatomic,readonly)NSUInteger currentAcademicYear;
@property (nonatomic,readonly)JWStage currentStage;
@property (nonatomic,strong)NSDateComponents *beginDay;


+ (instancetype)defaultCalendar;
@end
