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

static NSString *kHeader = @"kHeader";

@interface JWMainViewController()
@property (strong, nonatomic) IBOutlet JWMainCollectionView     *mainCollectionView;
@property (strong, nonatomic) IBOutlet UIScrollView *rootView;

@property (strong, nonatomic) IBOutlet JWNavView                *navView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,readonly)  JWCourseDataController *dataController;
@property (nonatomic,readonly) JWCalendar *calendar;
@end
@implementation JWMainViewController

-(void)viewDidLoad {
    _rootView.contentSize = CGSizeMake(16*kScreen_Width, kScreen_Height-_navView.frame.size.height);
    
    _dataController = [JWCourseDataController defaultDateController];
    _calendar = [JWCalendar defaultCalendar];
    [_indicator stopAnimating];
    
    _mainCollectionView.dataSource = _dataController;
    _mainCollectionView.delegate = _dataController;
    _mainCollectionView.myLayout.cellPositionY = ^(NSIndexPath *indexpath) {
        JWMainViewController *__weak weakself = self;
        NSUInteger day = indexpath.section;
        NSUInteger index = indexpath.row;
        JWCourseMO *course = weakself.dataController.courseDic[@(day)][index];
        CGFloat singleRowHeight = weakself.mainCollectionView.frame.size.height / [weakself.mainCollectionView numberOfItemsInSection:0];
        CGFloat y = (course.start - 1) * singleRowHeight;
        return y;
    };

    _navView.weekCollectionView.dataSource = [JWCalendar defaultCalendar];
    _navView.weekCollectionView.delegate = [JWCalendar defaultCalendar];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [_navView.weekCollectionView reloadData];
    [_mainCollectionView reloadData];
    if (![JWKeyChainWrapper hasSavedStudentID]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        [self presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"kJWLoginViewController"] animated:NO completion:nil];
        return;
    }
    if (!_indicator.isAnimating) {
        
        switch ([_calendar currentStage]) {
            case JWStageSpringTerm:
            case JWStageAutumnTerm:{
                if (![_dataController hasDownloadCourseInTerm: _calendar.currentTerm]) {
                    [self fetchCourseUsingBlock:^{
                        _navView.weekLabel.text = [NSString stringWithFormat:@"第%@周",[NSString chineseStringWithNumber:_calendar.currentWeek]];
                    } failure:^(JWLoginFailure code) {
                        
                    }];
                }else {
                    _navView.weekLabel.text = [NSString stringWithFormat:@"第%@周",[NSString chineseStringWithNumber:_calendar.currentWeek]];
                }
                break;
            }
            case JWStageAutumnExam:
            case JWStageSpringExam:
            case JWStageSummerVacation:
            case JWStageWinterVacation:{
                [self fetchCourseUsingBlock:^{
                    _navView.weekLabel.text = [NSString stringWithFormat:@"第一周(距离开学%lu天)",(unsigned long)_calendar.daysRemain];
                } failure:^(JWLoginFailure code) {
                    _navView.weekLabel.text = @"教务未更新";
                }];
            }
            case JWStageSummerTerm:
                break;
        }
    }
    self.mainCollectionView.frame = CGRectMake((_calendar.currentWeek-1)*(kScreen_Width+20), 0, _rootView.frameWidth, _rootView.frameHeight);
    [self.rootView setContentOffset:CGPointMake((_calendar.currentWeek-1)*(kScreen_Width+20), 0)];
}
- (void)fetchCourseUsingBlock:(CommonEmptyBlock)block failure:(void (^)(JWLoginFailure code))failure{
    [_indicator startAnimating];
    _navView.weekLabel.text = @"获取课程中...";
    [[JWHTMLSniffer sharedSniffer] getCourseAtTerm:_calendar.currentTerm andBlock:^{
        [_dataController resetTerm:_calendar.currentTerm andWeek:_calendar.currentWeek];
        [_indicator stopAnimating];
        block();
        [_mainCollectionView reloadData];
    } failure:^(JWLoginFailure code) {
        [_indicator stopAnimating];
        failure(code);
    }];
}
- (IBAction)unwindToMainViewController:(UIStoryboardSegue*)unwindSegue {
    [self fetchCourseUsingBlock:^{
         _navView.weekLabel.text = [NSString stringWithFormat:@"第%@周",[NSString chineseStringWithNumber:_calendar.currentWeek]];
    } failure:nil];
}
- (IBAction)settingPressed:(id)sender {
}
-(CGFloat)cellPositionYAtIndexpath:(NSIndexPath *)indexpath {
    NSUInteger day = indexpath.section;
    NSUInteger index = indexpath.row;
    JWCourseMO *course = _dataController.courseDic[@(day)][index];
    CGFloat singleRowHeight = _mainCollectionView.frame.size.height / [_mainCollectionView numberOfItemsInSection:0];
    CGFloat y = (course.start - 1) * singleRowHeight;
    return y;
}

@end
