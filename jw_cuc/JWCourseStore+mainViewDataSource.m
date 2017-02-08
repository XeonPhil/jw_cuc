//
//  JWCourseStore+mainViewDataSource.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/5.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//
#import "JWCourseStore.h"
#import "JWCourseStore+mainViewDataSource.h"
#import "JWPeriodCollectionViewCell.h"
#import "JWCourseCollectionViewCell.h"
#import "JWCourse.h"
@implementation JWCourseStore (mainViewDataSource) 

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 8;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.totalCourseArray != nil) {
        if (section == 0) {
            return 12;
        }else {
            NSUInteger day = section;
            return [self numberOfCourseAtWeek:1 atDay:day];
        }
    }
    
    return 0;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger day = indexPath.section;
    NSUInteger index = indexPath.row;
    if (day > 0) {
        JWCourseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kCell"forIndexPath:indexPath];
        JWCourse *course = [self courseForWeek:1 atDay:day atIndex:index];
        cell.backgroundColor = [UIColor randomCellColor];
        cell.height = course.end - course.start + 1;
        cell.nameLabel.text = course.courseName;
        cell.classRoomLabel.text = course.classroom;
        return cell;
    }else {
        JWPeriodCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"kPeriodCell" forIndexPath:indexPath];
        NSString *numberString = [NSString stringWithFormat:@"%lu",(unsigned long)indexPath.row + 1];
        cell.numberLabel.text = numberString;
        return cell;
    }
}
@end
