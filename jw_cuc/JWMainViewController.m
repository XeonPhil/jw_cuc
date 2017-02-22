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


#import "JWWeekCollectionViewCell.h"
#import "JWHTMLSniffer.h"

#import <CoreData/CoreData.h>
#import "JWCourseMO+CoreDataProperties.h"
#import "JWCourseDataController.h"
#import "JWCalendar.h"

#define kHeader @"kHeader"

@interface JWMainViewController()
@property (strong, nonatomic) IBOutlet JWMainCollectionView     *mainCollectionView;
@property (strong, nonatomic) IBOutlet JWNavView                *navView;
@property (nonatomic,strong,readonly)  JWCourseDataController *dataController;
@end
@implementation JWMainViewController

-(void)viewDidLoad {
    _dataController = [JWCourseDataController defaultDateController];
    _mainCollectionView.dataSource = _dataController;
    _mainCollectionView.delegate = _dataController;
    _navView.weekCollectionView.dataSource = [JWCalendar defaultCalendar];
    

    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];\
    NSString *titleString;
    NSUInteger currentWeekNum = [[JWCalendar defaultCalendar] currentWeek];
    if (currentWeekNum) {
        titleString = [NSString stringWithFormat:@"第%@周",[NSString chineseStringWithNumber:currentWeekNum]];
    }else {
        NSUInteger days = [[JWCalendar defaultCalendar] daysRemain];
        if (!days) {
            titleString = @"未添加课程";
        }else {
            titleString = [NSString stringWithFormat:@"第一周(距离开学%lu天)",(unsigned long)days];
        }
    }
    _navView.weekLabel.text = titleString;
    [_mainCollectionView reloadData];
    [_navView.weekCollectionView reloadData];
}
- (IBAction)fetchCourse:(id)sender {
    NSUInteger week = _dataController.week;
    [_dataController resetTerm:nil andWeek:week];
    [_mainCollectionView reloadData];
//    [self fetchObj];
}
- (IBAction)settingPressed:(id)sender {
    static NSUInteger week = 0;
    [[JWCourseDataController defaultDateController] resetTerm:[[JWCalendar defaultCalendar] currentTerm] andWeek:++week];
    [_mainCollectionView reloadData];
}


@end
