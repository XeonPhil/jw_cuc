//
//  JWCourseDataController.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/8.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

@class JWTerm;
@interface JWCourseDataController : NSObject
@property (strong)NSManagedObjectContext *managedObjectiContext;
+ (instancetype)defaultDateController;
- (void)insertCoursesAtTerm:(JWTerm *)term withHTMLDataArray:(NSArray *)htmlDataArray;
- (void)insertCourseWithDic:(NSDictionary *)dic;
@end
