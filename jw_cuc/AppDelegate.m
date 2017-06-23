//
//  AppDelegate.m
//  jw_cuc
//
//  Created by  Phil Guo on 16/12/24.
//  Copyright © 2016年  Phil Guo. All rights reserved.
//

#import "AppDelegate.h"
#import "JWCalendar.h"
#import "JWLoginViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate
#ifdef DEBUG
void onUncaughtException(NSException *exception)
{
    NSLog(@"uncaught exception: %@", exception.description);
}
#endif

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#ifdef DEBUG
    NSSetUncaughtExceptionHandler(&onUncaughtException);
#endif
    //[JWKeyChainWrapper keyChainDeleteIDAndkey];
    self.dataController = [JWCourseDataController new];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultSetting = @{
                                     @"kShowWeekendCourse":@NO,
                                     @"kCourseNumberShown":@(12)
                                     };
    for (NSString *key in defaultSetting) {
        if (![defaults valueForKey:key]) {
            [defaults setObject:defaultSetting[key] forKey:key];
        }
    }
    [defaults synchronize];
    
#warning "By initializing a separate controller object with a completion block, you have moved the Core Data stack out of the application delegate, but you still allow a callback to the application delegate so that the user interface can know when to begin requesting data."
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
