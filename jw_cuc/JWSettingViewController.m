//
//  JWSettingViewController.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/23.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWSettingViewController.h"
#import "JWMainViewController.h"
@interface JWSettingViewController ()

@property (strong, nonatomic) IBOutlet UISwitch *switcher;
@property (strong, nonatomic) IBOutlet UILabel *courseNumLabel;


@property (nonatomic) UITableView *settingTableView;
@end

@implementation JWSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_switcher addTarget:self action:@selector(switcherChanged) forControlEvents:UIControlEventValueChanged];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    NSUInteger courseNumShown = [[NSUserDefaults standardUserDefaults] integerForKey:@"kCourseNumberShown"];
    _courseNumLabel.text = [NSString stringWithNumber:@(courseNumShown)];
    BOOL isWeekendCourseShown = [[NSUserDefaults standardUserDefaults] boolForKey:@"kShowWeekendCourse"];
    _switcher.on = isWeekendCourseShown;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row == 0 && indexPath.section == 1) {
//    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)switcherChanged {
    [[NSUserDefaults standardUserDefaults] setBool:_switcher.on forKey:@"kShowWeekendCourse"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)unwindToSettingViewController:(UIStoryboardSegue *)segue {
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
