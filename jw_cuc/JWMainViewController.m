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
@property (strong, nonatomic)JWMainCollectionView *mainCollectionView;
@property (strong, nonatomic) IBOutlet UIScrollView *rootView;
@property (strong, nonatomic) IBOutlet JWNavView                *navView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic,readonly) JWCourseDataController *dataController;
@property (nonatomic,readonly) JWCalendar *calendar;
@property (nonatomic,strong,readwrite)NSArray<JWMainCollectionView *> *mainViews;
@property (nonatomic,assign,readwrite)NSUInteger currentWeekShown;
@end
@implementation JWMainViewController
- (JWMainCollectionView *)loadMainView{
    JWMainCollectionView *view = [JWMainCollectionView defaultCollectionView];
    [_rootView addSubview:view];
#warning layout
    //[self.view addConstraints:[view layout]];
    //[self.view layoutSubviews];
    view.jw_frameWidth = self.view.jw_frameWidth;
    view.jw_frameHeight = self.rootView.jw_frameHeight;
    view.dataSource = _dataController;
    view.delegate = _dataController;
    
    UINib *courseCellNib = [UINib nibWithNibName:@"JWCourseCollectionViewCell" bundle:[NSBundle mainBundle]];
    UINib *periodcellNib = [UINib nibWithNibName:@"JWPeriodCollectionViewCell" bundle:[NSBundle mainBundle]];
    
    [view registerNib:courseCellNib forCellWithReuseIdentifier:@"kCell"];
    [view registerNib:periodcellNib forCellWithReuseIdentifier:@"kPeriodCell"];
    
    
    
    return view;
}
- (void)viewDidLoad {
    [_indicator stopAnimating];
    
    _rootView.contentSize = CGSizeMake(16*_rootView.jw_frameWidth,_rootView.jw_frameHeight);
    _rootView.delegate = self;
    _dataController = [JWCourseDataController defaultDateController];
    _calendar = [JWCalendar defaultCalendar];
    for (NSUInteger week = 1; week <= 16; week++) {
        JWMainCollectionView *view = [self loadMainView];
        view.jw_frameX = ( week - 1 ) * _rootView.jw_frameWidth;
        view.week = week;
        
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
    _navView.weekCollectionView.dataSource = [JWCalendar defaultCalendar];
    _navView.weekCollectionView.delegate = [JWCalendar defaultCalendar];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //若未输入学号密码
    if (![JWKeyChainWrapper hasSavedStudentID]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        [self presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"kJWLoginViewController"] animated:NO completion:nil];
        return;
    }
    //根据时段下载课表
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
    _currentWeekShown = _calendar.currentWeek;
    [self addObserver:_calendar forKeyPath:@"currentWeekShown" options:NSKeyValueObservingOptionNew context:nil];
//    self.mainCollectionView.frame = CGRectMake((_calendar.currentWeek-1)*(kScreen_Width+20), 0, _rootView.jw_frameWidth, _rootView.jw_frameHeight);
    self.mainCollectionView = self.rootView.subviews[_calendar.currentWeek-1];
    [self.mainCollectionView makeViewShown];
    [self.rootView setContentOffset:CGPointMake(self.mainCollectionView.jw_frameX, 0)];
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
#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int week = self.rootView.contentOffset.x / self.rootView.jw_frameWidth + 1;
    _navView.weekLabel.text = [NSString stringWithFormat:@"第%@周",[NSString chineseStringWithNumber:week]];
    self.currentWeekShown = week;
    [self.navView.weekCollectionView reloadData];
}
@end
