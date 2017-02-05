//
//  HTMLParser.m
//  jw_cuc
//
//  Created by  Phil Guo on 16/12/25.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "HTMLParser.h"

@implementation HTMLParser
-(NSArray *)parseHTML:(NSData *)data {
    
    ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:data error:nil];
    
    NSArray *courseTableArray = [[document.rootElement firstChildWithXPath:@"/html/body/table"] children];
    NSMutableArray *courseArray = [NSMutableArray arrayWithArray:courseTableArray];
    [courseArray removeObjectAtIndex:0];
    NSMutableArray *courses = [NSMutableArray array];
    for (ONOXMLElement *element in courseArray) {
        NSMutableDictionary *course = [NSMutableDictionary dictionary];
        course[@"date"] = [element.children[0] stringValue];
        course[@"name"] = [element.children[1] stringValue];
        course[@"day"] = [element.children[5] stringValue];
        course[@"start"] = [[element.children[6] stringValue] substringWithRange:NSMakeRange(1, 1)];
        course[@"end"] = [[element.children[6] stringValue] substringWithRange:NSMakeRange(3,1)];
        course[@"building"] = [element.children[9] stringValue];
        course[@"classroom"] = [element.children[10] stringValue];
        //        NSLog(@"%@",course);
        [courses addObject:course];
    }
    return courses;

}
@end
