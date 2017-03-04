//
//  JWCourseDataController.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/8.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//


#import "JWCourseDataController.h"
#import "JWCourseCollectionViewCell.h"
#import "JWPeriodCollectionViewCell.h"
#import "JWKeyChainWrapper.h"
#import <ONOXMLDocument.h>
const static CGFloat kCommonCellWidth = 50.0;
const static CGFloat kLargeCellWidth = 70.0;
const static CGFloat kSmallCellWidth = 25.0;
static NSString *kKeyChainIDKey = @"com.jwcuc.kKeyChainIDKey";
static NSString *kKeyChainPassKey = @"com.jwcuc.kKeyChainPassKey";
@interface JWCourseDataController()
@property (nonatomic,readwrite)NSUInteger week;
@property (nonatomic,strong,readwrite)JWTerm *term;
@property (nonatomic,strong,readwrite)NSDictionary<NSNumber *,NSArray<JWCourseMO *> *> *courseDic;
@end
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
- (BOOL)insertCoursesAtTerm:(JWTerm *)term withHTMLDataArray:(NSArray *)htmlDataArray {
    [self deleteOldCoursesAtTerm:term];
    ONOXMLDocument *firstDoc = [ONOXMLDocument HTMLDocumentWithData:htmlDataArray[0] error:nil];
    if ([[[firstDoc rootElement] stringValue] containsString:@"未公布"]) {
        return NO;
    }
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
    BOOL success = [self.managedObjectiContext save:nil];
    if (success) {
        NSLog(@"course saved");
        return YES;
    }
    return NO;
}
- (void)insertCourseWithDic:(NSDictionary *)dic {
    JWCourseMO *course = [NSEntityDescription insertNewObjectForEntityForName:kCourseMOEntityName inManagedObjectContext:self.managedObjectiContext];
    for (NSString *key in dic) {
        [course setValue:dic[key] forKey:key];
    }
    if (course.week == 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JWFetchCourseNotification"
                                                            object:nil
                                                          userInfo:@{
                                                                     @"date":course.dateComponents,
                                                                     @"day":@(course.dayNum)
                                                                     }];
    }
}
- (BOOL)hasDownloadCourseInTerm:(JWTerm *)term {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@ and term == %@",@(term.year),@(term.season)];
    NSFetchRequest *request = [JWCourseMO fetchRequestWithPredicate:predicate];
    return [[_managedObjectiContext executeFetchRequest:request error:nil] count] ? YES : NO;
}
#pragma mark - private method
- (void)insertCourseWithDOMElement:(ONOXMLElement *)element andSupplementDictionary:(NSDictionary *)dic {
    
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
    
    
    NSString *duration = [element.children[6] stringValue];
    NSNumber *start   = [[duration stringAtIndex:1] numberObject];
    NSNumber *end = start;
    if (duration.length > 3) {
        end = [[duration stringAtIndex:3] numberObject];
    }
    propertyDictionary[@"start"] = start;
    propertyDictionary[@"end"] = end;
    NSArray *continuousCourses = [self hasContinuousCourse:propertyDictionary];
    if (continuousCourses.count != 0) {
        [self mergeCourse:propertyDictionary withContinuousCourse:continuousCourses];
    }else {
        [self insertCourseWithDic:propertyDictionary];
    }
    
}
- (NSArray *)hasContinuousCourse:(NSDictionary *)propertyDictionary {
    NSArray *predictArray = @[
                              propertyDictionary[@"year"],
                              propertyDictionary[@"week"],
                              propertyDictionary[@"dayNum"],
                              propertyDictionary[@"courseName"]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@ and week == %@ and dayNum == %@ and courseName like %@ " argumentArray:predictArray];
    NSFetchRequest *request = [JWCourseMO fetchRequestWithPredicate:predicate];
    NSError *err;
    NSArray *continuousCourseArray = [self.managedObjectiContext executeFetchRequest:request error:&err];
    NSAssert(err.code == 0, @"fetch request error");
    if (continuousCourseArray.count != 0) {
        return continuousCourseArray;
    }else {
        return nil;
    }
}
- (void)mergeCourse:(NSDictionary *)propertyDictionary withContinuousCourse:(NSArray *)continuousCourses {
    NSMutableDictionary *properties = [propertyDictionary mutableCopy];
    for (JWCourseMO *course in continuousCourses) {
        if ([properties[@"end"] intValue] == course.start - 1) {
            properties[@"end"] = @(course.end);
            [self.managedObjectiContext deleteObject:course];
        }else if ([properties[@"start"] intValue] == course.end + 1) {
            properties[@"start"] = @(course.start);
            [self.managedObjectiContext deleteObject:course];
        }
    }
    [self insertCourseWithDic:properties];
    
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
#pragma mark - data source
- (void)resetTerm:(JWTerm *)term andWeek:(NSUInteger)week {
    if (term) {
        self.term = term;
    }
    if (week) {
        self.week = week;
    }
    
    NSArray *predicateArray = @[
                                @(self.term.year),
                                @(self.term.season),
                                @(self.week)
                                ];
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"year == %@ and term == %@ and week == %@" argumentArray:predicateArray];
    NSFetchRequest *request = [JWCourseMO fetchRequestWithPredicate:predicate];
    NSError *err;
    NSArray *courses = [self.managedObjectiContext executeFetchRequest:request error:&err];
    NSAssert(err.code == 0, @"fetch failed");
    if (courses.count) {
        for (NSUInteger day = 1; day <=  5; day++) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"dayNum == %lu",(unsigned long)day];
            NSComparator comparator = ^NSComparisonResult(JWCourseMO *course1,JWCourseMO *course2) {
                if (course1.start < course2.start) {
                    return NSOrderedAscending;
                }else {
                    return NSOrderedDescending;
                }
            };
            dictionary[@(day)] = [[courses filteredArrayUsingPredicate:p] sortedArrayUsingComparator:comparator];
        }
        NSAssert(dictionary.count == 5, @"fetch course data lost");
        _courseDic = dictionary;
    }else {
        return;
    }
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    BOOL isWeekendCourseShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"kShowWeekendCourse"];
    return isWeekendCourseShown ? 8 : 6;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger num = [[NSUserDefaults standardUserDefaults] integerForKey:@"kCourseNumberShown"];
    if (section == 0) {
        if (num >= 4 && num <= 12) {
            return num;
        }else {
            return 12;
        }
    }
    NSArray *courses = self.courseDic[@(section)];
    NSPredicate *p = [NSPredicate predicateWithFormat:@"end <= %@",@(num)];
    NSUInteger count = [[courses filteredArrayUsingPredicate:p] count];
    return count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger day = indexPath.section;
    NSUInteger index = indexPath.row;
    if (day > 0) {
        JWCourseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kCell"forIndexPath:indexPath];
        JWCourseMO *course = self.courseDic[@(day)][index];
        //        JWCourse *course = [self courseForWeek:1 atDay:day atIndex:index];
        cell.backgroundColor = [UIColor randomColorWithString:course.courseName];
        cell.height = course.length;
        cell.nameLabel.text = course.courseName;
        cell.classRoomLabel.text = course.classroom;
        return cell;
    }else {
        JWPeriodCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kPeriodCell" forIndexPath:indexPath];
        NSString *numberString = [NSString stringWithFormat:@"%lu",(unsigned long)indexPath.row + 1];
        cell.numberLabel.text = numberString;
        static NSDictionary *timeDic;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            timeDic = @{
                        @0: @"8:00",
                        @1: @"9:00",
                        @2: @"10:10",
                        @3: @"11:10",
                        @4: @"13:30",
                        @5: @"14:20",
                        @6: @"15:20",
                        @7: @"16:10",
                        @8: @"18:00",
                        @9: @"19:00",
                        @10:@"20:00",
                        @11:@"21:00"
                        };
        });
        cell.timeLabel.text = timeDic[@(indexPath.row)];
        return cell;
    }
    return nil;
}
//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return 7;
//}
//-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    JWWeekCollectionViewCell  *cell = [_navView.weekCollectionView dequeueReusableCellWithReuseIdentifier:kWeekCellIdentifier forIndexPath:indexPath];
//    cell.weekLabel.text = [self weekStringForIndex:indexPath.row];
//    cell.dateLabel.text = @"12-21";
//    return cell;
//    
//}
#pragma mark - layout
-(CGFloat)cellPositionYAtIndexpath:(NSIndexPath *)indexpath {
    NSUInteger day = indexpath.section;
    NSUInteger index = indexpath.row;
    JWCourseMO *course = self.courseDic[@(day)][index];
    CGFloat y = (course.start - 1) * kSingleRowHeight;
    return y;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger day = indexPath.section;
    NSUInteger index = indexPath.row;
    CGFloat width = collectionView.numberOfSections == 8 ? kCommonCellWidth : kLargeCellWidth;
    CGFloat singleRowHeight = collectionView.frame.size.height / [collectionView numberOfItemsInSection:0];
    if (day == 0) {
        return CGSizeMake(kSmallCellWidth, singleRowHeight);
    }else {
        JWCourseMO *course = self.courseDic[@(day)][index];
        CGFloat height = course.length * singleRowHeight;
        return CGSizeMake(width, height);
    }
}
@end
