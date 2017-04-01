//
//  JWCourseDataController.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/8.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//
#import <CoreData/CoreData.h>
#import "JWCourseMO+CoreDataClass.h"
#import "JWCourseMO+CoreDataProperties.h"

#define kSingleRowHeight 48
@class JWTerm;
@interface JWCourseDataController : NSObject <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong)NSManagedObjectContext *managedObjectiContext;
+ (instancetype)defaultDateController;
- (BOOL)insertCoursesAtTerm:(JWTerm *)term withHTMLDataArray:(NSArray *)htmlDataArray;
- (void)insertCourseWithDic:(NSDictionary *)dic;
- (BOOL)hasDownloadCourseInTerm:(JWTerm *)term;
#pragma mark - data source
@property (nonatomic,readonly)NSUInteger week;
@property (nonatomic,strong,readonly)JWTerm *term;
@property (nonatomic,strong,readonly)NSDictionary<NSNumber *,NSArray<JWCourseMO *> *> *courseDic;
- (void)resetTerm:(JWTerm *)term andWeek:(NSUInteger)week;
#pragma mark - layout 
@end
