//
//  JWCourseMO+CoreDataClass.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/9.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN
@interface JWCourseMO : NSManagedObject
@property (nonatomic,readonly)NSUInteger length;
@property (nonatomic,strong,readonly,getter=dateString)NSString *dateString;
@property (nonatomic,copy,readonly)NSComparator compareBlock;
@end

NS_ASSUME_NONNULL_END

#import "JWCourseMO+CoreDataProperties.h"
