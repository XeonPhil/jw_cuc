//
//  JWCourse.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/18.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JWCourse : NSObject
@property (nonatomic,readonly)NSUInteger day;
@property (nonatomic,readonly)NSUInteger start;
@property (nonatomic)         NSUInteger end;
@property (nonatomic,strong,readonly)NSString *courseName;
@property (nonatomic,strong,readonly)NSString *classroom;
@property (nonatomic,strong,readonly)NSString *date;
@property (nonatomic,strong,readonly)NSString *building;
@property (nonatomic,strong,readonly)NSArray<NSIndexPath *> *indexs;
+(instancetype)courseWithDictionary:(NSDictionary *)dic;
@end
