//
//  NSArray+Plist.m
//  CUCMOOC
//
//  Created by  Phil Guo on 16/11/14.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "NSArray+Plist.h"

@implementation NSArray (Plist)
-(BOOL)writeToPlistFile:(NSString*)path{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self];
    BOOL didWriteSuccessfull = [data writeToFile:path atomically:YES];
    return didWriteSuccessfull;
}

+(NSArray*)readFromPlistFile:(NSString*)path{
    NSData * data = [NSData dataWithContentsOfFile:path];
    if ([data length]) {
        return  [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }else {
        return nil;
    }
}
@end
