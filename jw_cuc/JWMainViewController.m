//
//  JWMainViewController.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/15.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWMainViewController.h"

#import "JWNavView.h"
#import "JWMainCollectionView.h"
#import "JWCourseStore.h"
#import "JWCourseStore+mainViewDataSource.h"
#import "JWWeekCollectionViewCell.h"
#import "JWHTMLSniffer.h"

#import <CoreData/CoreData.h>
#import "JWCourseMO+CoreDataProperties.h"
#import "JWCourseDataController.h"


#define kHeader @"kHeader"
#define kWeekCellIdentifier @"collection-cell-week"
@interface JWMainViewController()
@property (strong, nonatomic) IBOutlet JWMainCollectionView     *mainCollectionView;
@property (strong, nonatomic) IBOutlet JWNavView                *navView;
@property (nonatomic,strong,readonly)  JWCourseDataController *dataController;
@end
@implementation JWMainViewController
@synthesize currentWeek = _currentWeek;
-(void)setCurrentWeek:(NSUInteger)currentWeek {
    _currentWeek = currentWeek;
    NSString *weekNum = [NSString chineseStringWithNumber:currentWeek];
    NSString *title = [NSString stringWithFormat:@"第%@周",weekNum];
    _navView.weekLabel.text = title;
}
-(void)viewDidLoad {
    self.currentWeek = 1;
    _navView.weekLabel.text = @"第一周";
    _dataController = [JWCourseDataController defaultDateController];
    _mainCollectionView.dataSource = _dataController;
    _mainCollectionView.delegate = _dataController;
    JWTerm *term = [JWTerm termWithYear:2017 termSeason:JWTermSeasonSpring];
    
    [[JWHTMLSniffer sharedSniffer] getCourseWithStudentID:@"201410513013" password:@"2014105130gc" term:term andBlock:^{
        NSLog(@"sniffered");
        [_dataController resetTerm:term andWeek:1];
        [_mainCollectionView reloadData];
    }];
    
}
- (IBAction)fetchCourse:(id)sender {
    NSUInteger week = _dataController.week;
    [_dataController resetTerm:nil andWeek:week];
    [_mainCollectionView reloadData];
//    [self fetchObj];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JWWeekCollectionViewCell  *cell = [_navView.weekCollectionView dequeueReusableCellWithReuseIdentifier:kWeekCellIdentifier forIndexPath:indexPath];
    cell.weekLabel.text = [self weekStringForIndex:indexPath.row];
    cell.dateLabel.text = @"12-21";
    return cell;
    
}
-(NSString *)weekStringForIndex:(NSUInteger)index {
    static NSString *week = @"周";
    NSString *weekNumString = [NSString chineseWeekStringWithNumber:index+1];
    return [week stringByAppendingString:weekNumString];
}

@end
