//
//  JWCourse.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/18.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//
#import "JWCourse.h"
@interface JWCourse()

@end
@implementation JWCourse
+(NSUInteger)dayNumForString:(NSString *)dayString{
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
        _classroom  = dic[@"classroom"];
        _date       = dic[@"date"];
        _day        = [JWCourse dayNumForString:dic[@"day"]];
        _building   = dic[@"building"];
        _start      = (NSUInteger)[(NSString *)dic[@"start"] integerValue];
        _end        = (NSUInteger)[(NSString *)dic[@"end"] integerValue];
    }
    return self;
}
//-(NSArray<NSIndexPath *> *)indexs {
//    NSMutableArray *indexArray = [NSMutableArray array];
//}
@end
