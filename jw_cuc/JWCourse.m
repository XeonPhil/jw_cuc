//
//  JWCourse.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/18.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//
#import "JWCourse.h"
@interface JWCourse()
@property (nonatomic,strong,readonly)NSDateComponents *date;
@end
@interface NSDateComponents(string)

@end
@implementation JWCourse
//@synthesize dateString = _dateString;
-(NSUInteger)dayNumForString:(NSString *)dayString {
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{
                @"星期一":@1,
                @"星期二":@2,
                @"星期三":@3,
                @"星期四":@4,
                @"星期五":@5,
                @"星期六":@6,
                @"星期日":@7};
    });
    return [dic[dayString] unsignedLongValue];
}
+(instancetype)courseWithDictionary:(NSDictionary *)dic {
    return [[JWCourse alloc] initWithDic:dic];
}
-(instancetype)initWithDic:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        _courseName = dic[@"name"];
        _classroom  = [self shortenClassroomString:dic[@"classroom"]];
        _date       = [self dateComponentsWithString:dic[@"date"]];
        _day        = [self dayNumForString:dic[@"day"]];
        _building   = dic[@"building"];
        _start      = [dic[@"start"] integerValue];
        _end        = [dic[@"end"] integerValue];
    }
    return self;
}
-(NSString *)dateString {
    return [NSString stringWithFormat:@"%ld-%ld",(long)_date.month,(unsigned long)_date.date];
}
-(NSUInteger)courseDuration {
    return _end - _start + 1;
}
-(NSDateComponents *)dateComponentsWithString:(NSString *)dateString {
    //字符格式 = @"2016-02-12"
    NSInteger year = [[dateString substringToIndex:4] integerValue];
    NSInteger month = [[dateString substringWithRange:NSMakeRange(6, 1)] integerValue];
    NSInteger day = [[dateString substringWithRange:NSMakeRange(8, 2)] integerValue];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.year = year;
    dateComponents.month = month;
    dateComponents.day = day;
    return dateComponents;
}
-(NSString *)shortenClassroomString:(NSString *)classroom {
    return [classroom stringByReplacingOccurrencesOfString:@"四十八" withString:@"48"];
}
//-(NSUInteger)integerWithString:(NSString *)string {
//    return (NSUInteger)[string integerValue];
//}
@end
