//
//  JWMainViewController.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/1/15.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWMainViewController.h"
#import "JWCollectionHeader.h"
#import "JWNavView.h"
#import "JWMainCollectionView.h"
#import "JWCourseStore.h"
#import "JWCourseStore+mainViewDataSource.h"
#import "JWWeekCollectionViewCell.h"
#import "JWHTMLSniffer.h"
#define kHeader @"kHeader"
#define kWeekCellIdentifier @"collection-cell-week"
@interface JWMainViewController()
@property (strong, nonatomic) IBOutlet JWMainCollectionView     *mainCollectionView;
@property (strong, nonatomic) IBOutlet JWNavView                *navView;
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
    _mainCollectionView.dataSource = [JWCourseStore sharedStore];
    _mainCollectionView.delegate = _mainCollectionView;
    [[JWHTMLSniffer sharedSniffer] getCourseWithBlock:^{
        NSLog(@"sniffered");
        [_mainCollectionView reloadData];
    }];
    
}
- (IBAction)fetchCourse:(id)sender {
    [_mainCollectionView reloadData];
    self.currentWeek +=1;
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
