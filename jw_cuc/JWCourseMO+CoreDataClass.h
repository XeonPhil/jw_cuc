//
//  JWCourseMO+CoreDataClass.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/9.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN
@interface JWCourseMO : NSManagedObject
@property (nonatomic,readonly)NSUInteger length;
@property (nonatomic,strong,readonly,getter=dateString)NSString *dateString;
@end

NS_ASSUME_NONNULL_END


