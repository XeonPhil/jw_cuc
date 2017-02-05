//
//  HTMLParser.h
//  jw_cuc
//
//  Created by  Phil Guo on 16/12/25.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ONOXMLDocument.h>
@interface HTMLParser : ONOXMLDocument
-(NSArray *)parseHTML:(NSData *)data;
@end
