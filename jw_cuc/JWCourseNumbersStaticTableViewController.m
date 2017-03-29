//
//  JWCourseNumbersStaticTableViewController.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/3/29.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWCourseNumbersStaticTableViewController.h"

@interface JWCourseNumbersStaticTableViewController ()

@end

@implementation JWCourseNumbersStaticTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSUInteger courseNumShown = [[NSUserDefaults standardUserDefaults] integerForKey:@"kCourseNumberShown"];
    UITableViewCell *checkCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:courseNumShown/2 - 4 inSection:0]];
    checkCell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger  newNum = (indexPath.row+4) * 2;
    [[NSUserDefaults standardUserDefaults] setValue:@(newNum) forKey:@"kCourseNumberShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}
//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

@end
