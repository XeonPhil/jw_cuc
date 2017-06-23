//
//  JWMainViewController.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/15.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWMainViewController.h"
#import "JWSettingViewController.h"
#import "JWNavView.h"
#import "JWMainCollectionView.h"


#import "JWWeekCollectionViewCell.h"
#import "JWHTMLSniffer.h"

#import <CoreData/CoreData.h>
#import "JWCourseMO+CoreDataProperties.h"
#import "JWCourseDataController.h"
#import "JWCalendar.h"

static NSString *kHeader = @"kHeader";

@interface JWMainViewController() <JWSettingChangedProtocol>
@property (strong, nonatomic)JWMainCollectionView *mainCollectionView;
@property (strong, nonatomic) IBOutlet UIScrollView *rootView;
@property (strong, nonatomic) IBOutlet JWNavView                *navView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIButton *retryButton;
@property (nonatomic,readonly) JWCourseDataController *dataController;
@property (nonatomic,readonly) JWCalendar *calendar;
@property (nonatomic,strong,readwrite)NSArray<JWMainCollectionView *> *mainViews;
@property (nonatomic,assign,readwrite)NSUInteger currentWeekShown;
@property (nonatomic,strong,readwrite) UILabel *topLabel;
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
    _topLabel = self.navView.weekLabel;
    _rootView.jw_frameWidth = kScreen_Width + 25.0;
    _rootView.jw_frameHeight = kScreen_Height - _navView.jw_frameHeight;
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
        view.myLayout.cellPositionXOffsetNum = ^(NSIndexPath *indexpath) {
            NSUInteger day = indexpath.section;
            NSUInteger blankDayNum = 0;
            for (NSUInteger i = 1; i < day; i++) {
                NSArray *courses = [weakself.dataController coursesAtWeek:view.week andWeekDay:i];
                if (courses.count == 0) {
                    blankDayNum++;
                }
            }
            return blankDayNum;
        };
    }
    _navView.weekCollectionView.dataSource = [JWCalendar defaultCalendar];
    _navView.weekCollectionView.delegate = [JWCalendar defaultCalendar];
    self.retryButton.hidden = YES;
    
    _currentWeekShown = _calendar.currentWeek;
    [self addObserver:_calendar forKeyPath:@"currentWeekShown" options:NSKeyValueObservingOptionNew context:nil];
}
- (IBAction)retry:(id)sender {
    self.retryButton.hidden = YES;
    [self downloadCourseIfNeeded];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //若未输入学号密码
    [self popLoginifNeeded];
    [self downloadCourseIfNeeded];

    [self refreshTopString];
    
    if (_calendar.currentWeek) {
        self.mainCollectionView = self.rootView.subviews[_calendar.currentWeek-1];
        [self.mainCollectionView makeViewShown];
        [self.rootView setContentOffset:CGPointMake(self.mainCollectionView.jw_frameX, 0)];
    }
//    for (JWMainCollectionView *view in self.rootView.subviews) {
//        [view reloadData];
//    }
//    [self.navView.weekCollectionView reloadData];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}
- (void)bounceRootView {
    CGPoint origin = self.rootView.contentOffset;
    self.rootView.scrollEnabled = NO;
    self.rootView.pagingEnabled = NO;
    CGPoint bouncePoint = CGPointMake(origin.x - 25.0, origin.y);
    [self.rootView setContentOffset:bouncePoint animated:YES];
//    [self.rootView scrollRectToVisible:CGRectMake(420, 0, 20, 20) animated:YES];
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC);
    dispatch_after(time, dispatch_get_main_queue(), ^{
        [self.rootView setContentOffset:origin animated:YES];
        self.rootView.pagingEnabled = YES;
        self.rootView.scrollEnabled = YES;
//        [self.rootView scrollRectToVisible:CGRectMake(0, 0, 20, 20) animated:YES];
    });
}
- (void)popLoginifNeeded {
    if (![JWKeyChainWrapper hasSavedStudentID]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        [self presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"kJWLoginViewController"] animated:NO completion:nil];
        return;
    }
}
- (void)downloadCourseIfNeeded {
    if (![JWHTMLSniffer hasConnected]) {
        self.retryButton.hidden = NO;
        return;
    }
    [self refreshTopString];
    //根据时段下载课表
    if (!_indicator.isAnimating) {
        void (^wrongEnterHandler)(NSString* title) = ^void(NSString* title){
            UIAlertController* alt = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* gotoChange = [UIAlertAction actionWithTitle:@"goto" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [JWKeyChainWrapper keyChainDeleteIDAndkey];
                [self popLoginifNeeded];
            }];
            [alt addAction:gotoChange];
            [self presentViewController:alt animated:YES completion:nil];
        };
        void (^failureHandler)(JWLoginFailure) = ^(JWLoginFailure code) {
            switch (code) {
                case JWLoginFailureWrongPassword: wrongEnterHandler(@"pass");break;
                case JWLoginFailureUnexistUser:wrongEnterHandler(@"user");break;
                case JWLoginFailureUnupdated:
                    [self refreshTopString:@"教务未更新"];
                    self.retryButton.hidden = YES;
                    break;
                case JWLoginFailureUnknown:
                case JWLoginFailureBadNetWork:
                    [self refreshTopString:@"网络不佳"];
                    self.retryButton.hidden = YES;
                    break;
                default:break;
            }
        };
        switch ([_calendar currentStage]) {
            case JWStageSpringTerm:
            case JWStageAutumnTerm:{
                if (![_dataController hasDownloadCourseInTerm: _calendar.currentTerm]) {
                    [self fetchCourseUsingBlock:^{
                        [self refreshTopString];
                        for (JWMainCollectionView *view in self.rootView.subviews) {
                            [view reloadData];
                        }
                        [self bounceRootView];
                        [self.navView.weekCollectionView reloadData];
                    } failure:failureHandler];
                }
                break;
            }
            case JWStageAutumnExam:
            case JWStageSpringExam:
            case JWStageSummerVacation:
            case JWStageWinterVacation:{
                if (![_dataController hasDownloadCourseInTerm: _calendar.currentTerm]) {
                    [self fetchCourseUsingBlock:^{
                        [self refreshTopString];
                        for (JWMainCollectionView *view in self.rootView.subviews) {
                            [view reloadData];
                        }
                        [self bounceRootView];
                    } failure:failureHandler];
                }
            }
            case JWStageSummerTerm:
                break;
        }
    }
}
- (void)fetchCourseUsingBlock:(CommonEmptyBlock)block failure:(void (^)(JWLoginFailure code))failure{
    [_indicator startAnimating];
    [self refreshTopString:@"获取课程中..."];
    typeof(self) __weak weakself = self;
    [[JWHTMLSniffer newSniffer] getCourseAtTerm:_calendar.currentTerm andBlock:^{
        [weakself.indicator stopAnimating];
        block();
    } failure:^(JWLoginFailure code) {
        [weakself.indicator stopAnimating];
        failure(code);
    }];
}
- (IBAction)unwindToMainViewController:(UIStoryboardSegue*)unwindSegue {
    typeof(self) __weak weakself = self;
    [self.dataController deleteAllOldCourses];
    for (JWMainCollectionView *view in self.rootView.subviews) {
        [view reloadData];
    }
    [self downloadCourseIfNeeded];
}
#pragma mark - scrollview delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.navView.weekCollectionView reloadData];
    
    if ([JWHTMLSniffer hasConnected]) {
        int week = self.rootView.contentOffset.x / self.rootView.jw_frameWidth + 1;
        self.currentWeekShown = week;
        [self refreshTopString];
    }
}
- (void)refreshTopString {
    if (![JWHTMLSniffer hasConnected]) {
        [self refreshTopString:@"无网络连接"];
        self.retryButton.hidden = NO;
    }else {
        [self refreshTopString:nil];
    }
}
- (void)refreshTopString:(NSString*)string {
    if (!string) {
        string = @"第%@周";
    }else {
        _navView.weekLabel.text = string;
        return;
    }
    NSMutableString* str = [NSMutableString stringWithString:string];
    if (!self.calendar.isSchoolDay) {
        NSString* end = [NSString stringWithFormat:@"(距离开学%lu天)",(unsigned long)_calendar.daysRemain];
        [str appendString:end];
    }
    _navView.weekLabel.text = [NSString stringWithFormat:str,[NSString chineseStringWithNumber:self.currentWeekShown]];
}
#pragma mark - setting delegate
- (void)courseNumberChange {
    for (UICollectionView *view in self.rootView.subviews) {
        [view reloadData];
    }
}
- (void)dayNumberChange {
    [self.navView.weekCollectionView reloadData];
}
@end
