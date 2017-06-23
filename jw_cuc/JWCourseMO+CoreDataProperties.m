//
//  JWCourseMO+CoreDataProperties.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/9.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWCourseMO+CoreDataProperties.h"
@interface JWCourseMO()


@end
@implementation JWCourseMO (CoreDataProperties)

+ (NSFetchRequest<JWCourseMO *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Course"];
}
+ (NSFetchRequest<JWCourseMO *> *)fetchRequestWithPredicate:(NSPredicate *)predicate {
    NSFetchRequest *obj = [self fetchRequest];
    obj.predicate = predicate;
    return obj;
}
+ (NSComparator)comparator {
    NSComparator JWCourseMO_Comparator = ^NSComparisonResult(JWCourseMO *course1,JWCourseMO *course2) {
        if (course1.start < course2.start) {
            return NSOrderedAscending;
        }else {
            return NSOrderedDescending;
        }
    };
    return JWCourseMO_Comparator;
}
/**
 courseDic[@"date"] = @"2016-12-12";
 courseDic[@"day"] = @"星期四";
 courseDic[@"name"] = @"数字图形处理A";
 courseDic[@"duration"] = @"第3-4节";
 courseDic[@"building"] = @"一号教学楼";
 courseDic[@"classroom"] = @"一教308-分屏";
 courseDic[@"week"] = @3;
 @property (nullable, nonatomic, copy) NSString *building;
 @property (nullable, nonatomic, copy) NSString *classroom;
 @property (nullable, nonatomic, copy) NSString *courseName;
 @property (nonatomic) int16_t end;
 @property (nonatomic) int16_t start;
 @property (nonatomic) int16_t term;
 @property (nonatomic) int16_t week;
 @property (nonatomic) int16_t year;
 @property (nonatomic) int16_t dayNum;
 **/
@dynamic building;//0
@dynamic classroom;//0
@dynamic courseName;//0

@dynamic dateComponents;

@dynamic year;//0
@dynamic term;//0
@dynamic week;
@dynamic dayNum;

@dynamic start;//0
@dynamic end;//0


//- (void)fillPropertyWithDictionary:(NSMutableDictionary *)dictionary {
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"courseName"] = dictionary[@"courseName"];
//    dic[@"building"] = dictionary[@"building"];
//    dic[@"week"] = dictionary[@"week"];
//    
//    NSString *classroom = dictionary[@"classroom"];
//    classroom = [self shortenClassroomString:classroom];
//    dic[@"classroom"] = classroom;
//    dic[@"classroom"] = dictionary[@"classroom"];
//    
//    NSString *dateString = dictionary[@"date"];
//    self.dateComponents = [self dateComponentsWithString:dateString];
//    dic[@"year"] = [NSNumber numberWithUnsignedInteger:self.dateComponents.year];
//    NSInteger month = self.dateComponents.month;
//    NSInteger term = month > 1 && month < 8 ? 1 : 3;
//    dic[@"term"] = [NSNumber numberWithInteger:term];
//    
//    NSNumber *dayNum = [self dayNumForString:dictionary[@"day"]];
//    [dic removeObjectForKey:@"day"];
//    dic[@"dayNum"] = dayNum;
//    
//    NSString *duration = dictionary[@"duration"];
//    NSNumber *start   = [[duration stringAtIndex:1] numberObject];
//    NSNumber *end = start;
//    if (duration.length > 3) {
//        end = [[duration stringAtIndex:3] numberObject];
//    }
//    dic[@"start"] = start;
//    dic[@"end"] = end;
//    
//    for (NSString *key in dic) {
//        [self setValue:dic[key] forKey:key];
//    }
//    
//}

//- (NSNumber *)dayNumForString:(NSString *)day {
//    static NSDictionary *dic;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        dic = @{
//                @"星期一":@1,
//                @"星期二":@2,
//                @"星期三":@3,
//                @"星期四":@4,
//                @"星期五":@5,
//                @"星期六":@6,
//                @"星期日":@7};
//    });
//    return dic[day];
//}


//-(NSDateComponents *)dateComponentsWithString:(NSString *)dateString {
//    //字符格式 = @"2016-02-12"
//    NSInteger year = [[dateString substringToIndex:4] integerValue];
//    NSInteger month = [[dateString substringWithRange:NSMakeRange(5, 2)] integerValue];
//    NSInteger day = [[dateString substringWithRange:NSMakeRange(8, 2)] integerValue];
//    NSDateComponents *dateComponents = [NSDateComponents new];
//    dateComponents.year = year;
//    dateComponents.month = month;
//    dateComponents.day = day;
//    return dateComponents;
//}
//-(NSString *)shortenClassroomString:(NSString *)classroom {
//    return [classroom stringByReplacingOccurrencesOfString:@"四十八" withString:@"48"];
//}
@end
