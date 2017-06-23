//
//  JWSettingViewController.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/2/23.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JWSettingChangedProtocol <NSObject>
- (void)dayNumberChange;
- (void)courseNumberChange;
@end

@interface JWSettingViewController : UITableViewController
@property (nonatomic,weak,readwrite)id<JWSettingChangedProtocol> delegate;
@property (nonatomic,strong,readwrite)void (^courseNumChangeHandler)();
@end
