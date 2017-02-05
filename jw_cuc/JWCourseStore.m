//
//  JWCourseStore.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/18.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWCourseStore.h"
#import <ONOXMLDocument.h>
#import "HTMLParser.h"
#import "JWCourse.h"
#import <CoreData/CoreData.h>

@interface JWCourseStore()

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
//@synthesize courseArray = _courseArray;
@synthesize currentWeek = _currentWeek;
- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentWeek = 1;
    }
    return self;
}
//-(void)setCurrentWeek:(NSUInteger)currentWeek {
//    _currentWeek = currentWeek;
//    _totalCourseArray = _totalCourseArray[currentWeek - 1];
//}
//-(NSArray *)courseArrayForWeek:(NSUInteger)week {
//    NSMutableArray *courses = [[NSMutableArray alloc] initWithObjectType:[NSMutableArray class] count:7];
//    for (JWCourse *course in _totalCourseArray[week - 1]) {
//        [courses[course.day - 1] addObject:course];
//    }
//    return courses;
//}
//-(NSUInteger)numberOfCourseAtWeek:(NSUInteger)week atDay:(NSUInteger)day {
//    NSArray *coursesForWeek = _totalCourseArray[week];
//    NSUInteger number = 0;
//    for (JWCourse *course in coursesForWeek) {
//        if (course.day == day) {
//            number++;
//        }
//    }
//    return number;
//}

+(instancetype)sharedStore {
    static JWCourseStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        store = [JWCourseStore new];
    });
    return store;
}
-(void)establishCourseStoreWithArray:(NSArray *)array {
    NSArray *courseArray = [self parseHTMLWithArray:array];
    _totalCourseArray = courseArray;
    NSLog(@"%lu",(unsigned long)[courseArray count]);
}
-(NSArray *)parseHTMLWithArray:(NSArray *)htmlDataArray {
    NSMutableArray *coursesArray = [NSMutableArray arrayWithObjectType:[NSMutableArray class] count:htmlDataArray.count];
    [htmlDataArray enumerateObjectsUsingBlock:^(NSData *data, NSUInteger weekIndex, BOOL * _Nonnull stop) {
        ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:data error:nil];
            
        NSMutableArray *courseTableHTMLArray = [[[document.rootElement firstChildWithXPath:@"/html/body/table"] children] mutableCopy];
        [courseTableHTMLArray removeObjectAtIndex:0];//去除每周课表的表头项
        coursesArray[weekIndex] = [NSMutableArray arrayWithObjectType:[NSMutableArray class] count:7];
        for (ONOXMLElement *element in courseTableHTMLArray) {
            NSMutableDictionary *courseDic = [NSMutableDictionary dictionary];
            courseDic[@"date"] = [element.children[0] stringValue];
            courseDic[@"name"] = [element.children[1] stringValue];
            courseDic[@"day"] = [element.children[5] stringValue];
            
            NSString *courseLatency = [element.children[6] stringValue];
            courseDic[@"start"] = [[element.children[6] stringValue] substringWithRange:NSMakeRange(1, 1)];
            if (courseLatency.length > 3) {
                courseDic[@"end"] = [[element.children[6] stringValue] substringWithRange:NSMakeRange(3,1)];
            }else {
                courseDic[@"end"] = courseDic[@"start"];
            }
            
            courseDic[@"building"] = [element.children[9] stringValue];
            courseDic[@"classroom"] = [element.children[10] stringValue];
            
            JWCourse *course = [JWCourse courseWithDictionary:courseDic];
            NSUInteger day = course.day;
            NSUInteger dayIndex = day - 1;
            NSMutableArray *courseForDay = coursesArray[weekIndex][dayIndex];
            [courseForDay addCourse:course];
        }
//        [coursesArray addObject:coursesForOneWeek];
    }];
    return coursesArray;
}

@end
