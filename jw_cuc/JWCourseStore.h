//
//  JWCourseStore.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/18.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#define kSingleRowHeight 48.5
@interface JWCourseStore : NSObject
@property (nonatomic)        NSUInteger currentWeek;
@property (nonatomic,strong) NSArray *courseArray;
@property (nonatomic,strong) NSArray *totalCourseArray;
@property (nonatomic)        NSArray<NSIndexPath *> *emptyIndex;
+(instancetype)sharedStore;
-(void)establishCourseStoreWithArray:(NSArray *)array;

@end
