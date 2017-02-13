//
//  JWCourseStore.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/18.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWCourseStore.h"
#import <ONOXMLDocument.h>
#import "JWCourse.h"
#import <CoreData/CoreData.h>
#import "JWCourseMO+CoreDataProperties.h"
#import "JWCourseDataController.h"
@interface JWCourseStore()
@property (nonatomic,readonly)NSUInteger term;
@end
@interface NSMutableArray(addCourse)
-(void)addCourse:(JWCourse *)course;
@end
@implementation NSMutableArray(addCourse)
-(void)addCourse:(JWCourse *)course {
    JWCourse *theLastCourse = [self lastObject];
    BOOL isSameCourse = [theLastCourse.courseName isEqualToString:course.courseName];
    BOOL isNear       = theLastCourse.end + 1 == course.start;
    BOOL isContinuous = isSameCourse && isNear;
    if (isContinuous) {
        theLastCourse.end = course.end;
    }else {
        [self addObject:course];
    }
}
@end
@implementation JWCourseStore
+(instancetype)sharedStore {
    static JWCourseStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [JWCourseStore new];
    });
    return store;
}
+(instancetype)storeWithTerm:(NSUInteger)term {
    JWCourseStore *store = [[JWCourseStore alloc] initWithTerm:term];
    return store;
}
-(instancetype)initWithTerm:(NSUInteger)term {
    self = [super init];
    if (self) {
        _term = term;
    }
    return self;
}
-(NSArray *)courseArrayForWeek:(NSUInteger)week {
    return _totalCourseArray[week-1];
}
-(NSUInteger)numberOfCourseAtWeek:(NSUInteger)week atDay:(NSUInteger)day {
    NSArray *coursesForWeek = _totalCourseArray[week-1];
    NSUInteger num = [coursesForWeek[day-1] count];
    return num;
}
-(JWCourse *)courseForWeek:(NSUInteger)week atDay:(NSUInteger)day atIndex:(NSUInteger)index {
    return _totalCourseArray[week-1][day -1][index];
}
-(void)establishCourseStoreWithArray:(NSArray *)array {
    NSArray *courseArray = [self parseHTMLWithArray:array];
    _totalCourseArray = courseArray;
    NSLog(@"%lu",(unsigned long)[courseArray count]);
}
-(NSArray *)parseHTMLWithArray:(NSArray *)htmlDataArray {
    NSManagedObjectContext *managedObjectContext = [[JWCourseDataController defaultDateController] managedObjectiContext];
    [htmlDataArray enumerateObjectsUsingBlock:^(NSData *data, NSUInteger weekIndex, BOOL * _Nonnull stop) {
        ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:data error:nil];
            
        NSMutableArray *courseTableHTMLArray = [[[document.rootElement firstChildWithXPath:@"/html/body/table"] children] mutableCopy];
        [courseTableHTMLArray removeObjectAtIndex:0];//去除每周课表的表头项
        for (ONOXMLElement *element in courseTableHTMLArray) {
            NSMutableDictionary *courseDic = [NSMutableDictionary dictionary];
            courseDic[@"building"] = [element.children[9] stringValue];
            courseDic[@"classroom"] = [element.children[10] stringValue];
            courseDic[@"courseName"] = [element.children[1] stringValue];
            courseDic[@"date"] = [element.children[0] stringValue];
            courseDic[@"day"] = [element.children[5] stringValue];
            courseDic[@"duration"] = [element.children[6] stringValue];
            courseDic[@"week"] = [NSNumber numberWithUnsignedInteger:weekIndex+1];
//            [managedObjectContext insertCourseWithDic:courseDic];
        }
    }];
    NSFetchRequest *f = [[NSFetchRequest alloc] initWithEntityName:@"Course"];
    NSArray *a = [managedObjectContext executeFetchRequest:f error:nil];
    NSLog(@"%@",[a description]);
    /**
     <td name="td0">2016-10-13</td>
     
     <td name="td1">数字信号处理（A）</td>
     
     <td name="td2">必修</td>
     
     <td name="td3">正常考试</td>
     
     <td name="td4"></td>
     
     <td name="td5">星期四</td>
     
     <td name="td6">第5-6节</td>
     
     <td name="td7">13:30</td>
     
     <td name="td8">15:10</td>
     
     <td name="td9">四十八号教学楼</td>
     
     <td name="td10">四十八教A205</td>
     
     <td name="td11"></td>
     **/
    return nil;
}


@end
