//
//  JWCourseStore.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/18.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#define kSingleRowHeight 48.0
@class JWCourse;
@interface JWCourseStore : NSObject
@property (nonatomic,strong) NSArray *totalCourseArray;
+(instancetype)sharedStore;
+(instancetype)storeWithTerm:(NSUInteger)term;
-(void)establishCourseStoreWithArray:(NSArray *)array;
-(NSArray *)courseArrayForWeek:(NSUInteger)week;
-(JWCourse *)courseForWeek:(NSUInteger)week atDay:(NSUInteger)day atIndex:(NSUInteger)index;
-(NSUInteger)numberOfCourseAtWeek:(NSUInteger)week atDay:(NSUInteger)day;
@end
