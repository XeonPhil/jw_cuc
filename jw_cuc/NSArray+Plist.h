//
//  NSArray+Plist.h
//  CUCMOOC
//
//  Created by  Phil Guo on 16/11/14.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Plist)
-(BOOL)writeToPlistFile:(NSString*)path;
+(NSArray*)readFromPlistFile:(NSString*)path;
@end
