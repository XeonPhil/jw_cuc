//
//  JWKeyChainWrapper.h
//  jw_cuc
//
//  Created by  Phil Guo on 17/3/4.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import <Foundation/Foundation.h>
//static const UInt8 kKeychainItemIdentifier[]    = "com.apple.dts.KeychainUI\0";
@interface JWKeyChainWrapper : NSObject
+ (void)keyChainSaveID:(NSString *)ID;
+ (void)keyChainSavePassword:(NSString *)pass;
+ (NSString *)keyChainGetID;
+ (NSString *)keyChainGetPass;
+ (void)keyChainDeleteIDAndkey;
+ (BOOL)hasSavedStudentID;
@end

