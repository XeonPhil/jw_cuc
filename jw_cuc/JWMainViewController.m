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
@property (nonatomic,readonly) JWCourseDataController *dataController;
@property (nonatomic,readonly) JWCalendar *calendar;
@property (nonatomic,strong,readwrite)NSArray<JWMainCollectionView *> *mainViews;
@end
@implementation JWMainViewController
- (JWMainCollectionView *)loadMainView:(JWMainCollectionView *)view WithData:(NSDictionary *)courses {
    if (!view) {
        view = [JWMainCollectionView defaultCollectionView];
    }
    UINib *main = [UINib nibWithNibName:@"main" bundle:[NSBundle mainBundle]];
    [view registerNib:main forCellWithReuseIdentifier:@"kCell"];
    [view registerNib:main forCellWithReuseIdentifier:@"kPeriodCell"];
    view.myLayout.cellPositionY = ^(NSIndexPath *indexpath) {
        NSUInteger day = indexpath.section;
        NSUInteger index = indexpath.row;
        JWCourseMO *course = courses[@(day)][index];
        CGFloat singleRowHeight = view.frame.size.height / [view numberOfItemsInSection:0];
        CGFloat y = (course.start - 1) * singleRowHeight;
        return y;
    };
    view.dataSource = _dataController;
    view.delegate = _dataController;
    [_rootView addSubview:view];
    return view;
}
- (JWMainCollectionView *)loadMainView{
    JWMainCollectionView *view = [JWMainCollectionView defaultCollectionView];
    view.dataSource = _dataController;
    view.delegate = _dataController;
    [_rootView addSubview:view];
    return view;
}
-(void)viewDidLoad {
    [_indicator stopAnimating];
    _rootView.contentSize = CGSizeMake(16*_rootView.jw_frameWidth,_rootView.jw_frameHeight);
    
    _dataController = [JWCourseDataController defaultDateController];
    _calendar = [JWCalendar defaultCalendar];
    for (NSUInteger week = 1; week <= 16; week++) {
        JWMainCollectionView *view = [self loadMainView];
        view.frame = _mainCollectionView.frame;
        view.jw_frameX = ( week - 1 ) * _rootView.jw_frameWidth;
        view.week = week;
        
//        NSDictionary *courses = _dataController.allCourse[week];
//        if (courses) {
        typeof(self) __weak weakself = self;
        view.myLayout.cellPositionY = ^(NSIndexPath *indexpath) {
            NSUInteger day = indexpath.section;
            NSUInteger index = indexpath.row;
            JWCourseMO *course = [weakself.dataController courseAtWeek:view.week andWeekDay:day andIndex:index];
            CGFloat singleRowHeight = view.jw_frameHeight / [view numberOfItemsInSection:0];
            CGFloat y = (course.start - 1) * singleRowHeight;
            return y;
        };
    }
////    _mainCollectionView = [self mainViewWithData:_dataController.courseDic];
//    _mainCollectionView.dataSource = _dataController;
//    _mainCollectionView.delegate = _dataController;
//    typeof(self) __weak weakself = self;
//    _mainCollectionView.myLayout.cellPositionY = ^(NSIndexPath *indexpath) {
//        NSUInteger day = indexpath.section;
//        NSUInteger index = indexpath.row;
//        JWCourseMO *course = weakself.dataController.courseDic[@(day)][index];
//        CGFloat singleRowHeight = weakself.mainCollectionView.frame.size.height / [weakself.mainCollectionView numberOfItemsInSection:0];
//        CGFloat y = (course.start - 1) * singleRowHeight;
//        return y;
//    };

    _navView.weekCollectionView.dataSource = [JWCalendar defaultCalendar];
    _navView.weekCollectionView.delegate = [JWCalendar defaultCalendar];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
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
//    self.mainCollectionView.frame = CGRectMake((_calendar.currentWeek-1)*(kScreen_Width+20), 0, _rootView.jw_frameWidth, _rootView.jw_frameHeight);
    self.mainCollectionView = self.rootView.subviews[_calendar.currentWeek-1];
    [self.mainCollectionView makeViewShown];
    [self.rootView setContentOffset:CGPointMake(self.mainCollectionView.jw_frameX, 0)];
    
//    if (!_mainCollectionView.leftView && _mainCollectionView.frame.origin.x != 0) {
//        JWMainCollectionView *leftView = [JWMainCollectionView new];
//        leftView.dataSource = _dataController;
//        leftView.frame = _mainCollectionView.frame;
//        leftView.jw_frameX = _mainCollectionView.jw_frameX - _rootView.jw_frameWidth;
//        [_rootView addSubview:leftView];
//    }
//    if (!_mainCollectionView.rightView && _mainCollectionView.frame.origin.x != _rootView.contentSize.width - _rootView.jw_frameWidth) {
//        JWMainCollectionView *rightView = [JWMainCollectionView new];
//        rightView.dataSource = _dataController;
//        rightView.frame = _mainCollectionView.frame;
//        rightView.jw_frameX = _mainCollectionView.jw_frameX + _rootView.jw_frameWidth;
//        [_rootView addSubview:rightView];
//    }
}
- (void)fetchCourseUsingBlock:(CommonEmptyBlock)block failure:(void (^)(JWLoginFailure code))failure{
    [_indicator startAnimating];
    _navView.weekLabel.text = @"获取课程中...";
    typeof(self) __weak weakself = self;
    [[JWHTMLSniffer sharedSniffer] getCourseAtTerm:_calendar.currentTerm andBlock:^{
//        [weakself.dataController resetTerm:_calendar.currentTerm andWeek:_calendar.currentWeek];
        [weakself.indicator stopAnimating];
        block();
        [weakself.mainCollectionView reloadData];
    } failure:^(JWLoginFailure code) {
        [weakself.indicator stopAnimating];
        failure(code);
    }];
}
- (IBAction)unwindToMainViewController:(UIStoryboardSegue*)unwindSegue {
    typeof(self) __weak weakself = self;
    [self fetchCourseUsingBlock:^{
         weakself.navView.weekLabel.text = [NSString stringWithFormat:@"第%@周",[NSString chineseStringWithNumber:_calendar.currentWeek]];
    } failure:nil];
}
@end
