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
#import "JWHTMLSniffer.h"
#define kHeader @"kHeader"
@interface JWMainViewController()
@property (strong, nonatomic) IBOutlet JWMainCollectionView     *mainCollectionView;
@property (strong, nonatomic) IBOutlet JWNavView                *navView;
@end
@implementation JWMainViewController
-(void)viewDidLoad {
//    UICollectionViewFlowLayout *layout =  (UICollectionViewFlowLayout *)_mainCollectionView.collectionViewLayout;
//    layout.minimumLineSpacing = 0.0;
//    layout.minimumInteritemSpacing = 0.0;
//    UINib *headerNib = [UINib nibWithNibName:@"JWCollectionHeader" bundle:[NSBundle mainBundle]];
//    [_mainCollectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeader];
    
    _mainCollectionView.dataSource = [JWCourseStore sharedStore];
    _mainCollectionView.delegate = _mainCollectionView;
    [[JWHTMLSniffer sharedSniffer] getCourseWithBlock:^{
        NSLog(@"sniffered");
        [_mainCollectionView reloadData];
    }];
    
}
- (IBAction)fetchCourse:(id)sender {
    [_mainCollectionView reloadData];
}
@end
