//
//  JWCourseDataController.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/8.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "JWCourseMO+CoreDataClass.h"
#import "JWCourseMO+CoreDataProperties.h"
#import "JWCourseDataController.h"

#import <ONOXMLDocument.h>
@implementation JWCourseDataController
+ (instancetype)defaultDateController {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.dataController;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Course" withExtension:@"momd"];
        NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        NSAssert(mom != nil, @"Error initializing Managed Object Model");
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        moc.persistentStoreCoordinator = psc;
        self.managedObjectiContext = moc;
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        NSURL *storeURL = [documentsURL URLByAppendingPathComponent:@"Course.sqlite"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error;
            NSPersistentStoreCoordinator *psc = _managedObjectiContext.persistentStoreCoordinator;
            NSPersistentStore *store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
            NSAssert(store != nil, @"Error initializing PSC: %@\n%@", [error localizedDescription], [error userInfo]);
        });
       
    }
    return self;
}
- (void)insertCoursesAtTerm:(JWTerm *)term withHTMLDataArray:(NSArray *)htmlDataArray {
    [self deleteOldCoursesAtTerm:term];
    
    [htmlDataArray enumerateObjectsUsingBlock:^(NSData *data, NSUInteger weekIndex, BOOL * _Nonnull stop) {
        NSDictionary *supplementDictionary = @{
                                               @"year":@(term.year),
                                               @"term":@(term.season),
                                               @"week":@(weekIndex+1)
                                               };
        ONOXMLDocument *document = [ONOXMLDocument HTMLDocumentWithData:data error:nil];
        NSAssert(document!= nil, @"html document nil");
        NSMutableArray *courseTableHTMLArray = [[[document.rootElement firstChildWithXPath:@"/html/body/table"] children] mutableCopy];
        [courseTableHTMLArray removeObjectAtIndex:0];//去除每周课表的表头项
        NSAssert(courseTableHTMLArray != nil, @"courseTableHTMLArray nil");
        for (ONOXMLElement *element in courseTableHTMLArray) {
            [self insertCourseWithDOMElement:element andSupplementDictionary:supplementDictionary];
        }
    }];
    [self.managedObjectiContext save:nil];
}
- (void)insertCourseWithDic:(NSDictionary *)dic {
    JWCourseMO *course = [NSEntityDescription insertNewObjectForEntityForName:kCourseMOEntityName inManagedObjectContext:self.managedObjectiContext];
    for (NSString *key in dic) {
        [course setValue:dic[key] forKey:key];
    }
    
    
}
#pragma mark - private method
- (void)insertCourseWithDOMElement:(ONOXMLElement *)element andSupplementDictionary:(NSDictionary *)dic {
    JWCourseMO *course = [NSEntityDescription insertNewObjectForEntityForName:kCourseMOEntityName inManagedObjectContext:self.managedObjectiContext];
    NSMutableDictionary *propertyDictionary = [dic mutableCopy];
    propertyDictionary[@"building"] = [element.children[9] stringValue];
    propertyDictionary[@"courseName"] = [element.children[1] stringValue];
    
    NSString *dateString = [element.children[0] stringValue];
    propertyDictionary[@"dateComponents"] = [self dateComponentsWithString:dateString];
    
    NSString *classroom = [element.children[10] stringValue];;
    classroom = [self shortenClassroomString:classroom];
    propertyDictionary[@"classroom"] = classroom;
    
    
    NSString *dayString = [element.children[5] stringValue];
    propertyDictionary[@"dayNum"] = [self dayNumForString:dayString];
    
    NSArray *predictArray = @[propertyDictionary[@"building"],
                              propertyDictionary[@"classroom"],
                              propertyDictionary[@"courseName"],
                              propertyDictionary[@"dateComponents"],
                              propertyDictionary[@"dayNum"]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"" argumentArray:predictArray];
    
    NSString *duration = [element.children[6] stringValue];
    NSNumber *start   = [[duration stringAtIndex:1] numberObject];
    NSNumber *end = start;
    if (duration.length > 3) {
        end = [[duration stringAtIndex:3] numberObject];
    }
    propertyDictionary[@"start"] = start;
    propertyDictionary[@"end"] = end;
    
    for (NSString *key in propertyDictionary) {
        [course setValue:propertyDictionary[key] forKey:key];
    }
    
}

- (void)deleteOldCoursesAtTerm:(JWTerm *)term {
    //    _request.predicate = [NSPredicate predicateWithFormat:@"placeholder"];
    NSArray *oldCoursesMOArray = [self.managedObjectiContext executeFetchRequest:[JWCourseMO fetchRequest] error:nil];
    for (JWCourseMO *courseMO in oldCoursesMOArray) {
        [self.managedObjectiContext deleteObject:courseMO];
    }
}

/**
 <td name="td0">2016-10-13</td>
 
 <td name="td1">数字信号处理（A）</td>
 
 <td name="td2">必修</td>
 
 <td name="td3">正常考试</td>
 
 <td name="td4"></td>
 
 <td name="td5">星期四</td>
 
 <td name="td6">第5-6节</td>
 
 <td name="td7">13:30</td>
 
 <td name="td8">15:10</td>
 
 <td name="td9">四十八号教学楼</td>
 
 <td name="td10">四十八教A205</td>
 
 <td name="td11"></td>
 **/
- (NSNumber *)dayNumForString:(NSString *)day {
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
    return dic[day];
}

-(NSDateComponents *)dateComponentsWithString:(NSString *)dateString {
    //字符格式 = @"2016-02-12"
    NSInteger year = [[dateString substringToIndex:4] integerValue];
    NSInteger month = [[dateString substringWithRange:NSMakeRange(5, 2)] integerValue];
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

@end
