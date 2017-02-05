//
//  JWCourseStore+mainViewDataSource.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/5.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//
#import "JWCourseStore.h"
#import "JWCourseStore+mainViewDataSource.h"

@implementation JWCourseStore (mainViewDataSource) 

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 8;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.totalCourseArray != nil) {
        if (section == 0) {
            return 12;
        }else {
            NSInteger num = arc4random() % 4 + 1;
            return num;
            NSLog(@"%ld",(long)num);
            //            NSUInteger day = section;
            //            NSArray *arrayForWeek = [self courseArrayForWeek:_currentWeek];
            //            return  [arrayForWeek[day - 1] count];;
        }
    }
    
    return 0;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger day = indexPath.section;
    NSUInteger row = indexPath.row;
    if (day > 0) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kCell"forIndexPath:indexPath];
        cell.backgroundColor = [UIColor randomCellColor];
        //        cell.layer.shadowRadius = 1.0;
        //        cell.layer.shadowOpacity = 0.75;
        //        CGColorRef shadowColor = [[UIColor colorWithHexString:@"FEFEBE"] CGColor];
        //        cell.layer.shadowColor = shadowColor;
        return cell;
    }else {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kPeriodCell" forIndexPath:indexPath];
        return cell;
    }
}
@end
