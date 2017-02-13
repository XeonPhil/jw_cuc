//
//  JWTerm.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/10.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWTerm.h"

@implementation JWTerm
+ (instancetype)termWithYear:(NSUInteger)year termSeason:(JWTermSeason)termSeason {
    JWTerm *termObj = [JWTerm indexPathForRow:termSeason inSection:year];
    return termObj;
}
- (NSUInteger)year {
    return self.section;
}
- (JWTermSeason)season {
    return self.row;
}
@end
