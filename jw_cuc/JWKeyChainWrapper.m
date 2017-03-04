//
//  JWKeyChainWrapper.m
//  jw_cuc
//
//  Created by  Phil Guo on 17/3/4.
//  Copyright © 2017年  Phil Guo. All rights reserved.
//

#import "JWKeyChainWrapper.h"
#import <CommonCrypto/CommonCrypto.h>
static NSString *kKeyChainIDKey = @"com.jwcuc.kKeyChainIDKey";
static NSString *kKeyChainPassKey = @"com.jwcuc.kKeyChainPassKey";
@implementation JWKeyChainWrapper
+ (void)keyChainSaveID:(NSString *)ID {
    [self keyChainSaveData:ID forKey:kKeyChainIDKey];
}
+ (void)keyChainSavePassword:(NSString *)pass {
    [self keyChainSaveData:pass forKey:kKeyChainPassKey];
}
+ (NSString *)keyChainGetID {
    return [self keyChainGetDataforKey:kKeyChainIDKey];
}
+ (NSString *)keyChainGetPass {
    return [self keyChainGetDataforKey:kKeyChainPassKey];
}
+ (BOOL)hasSavedStudentID {
    return [self keyChainHasDataForKey:kKeyChainIDKey] && [self keyChainHasDataForKey:kKeyChainPassKey];
}
+ (void)keyChainDeleteIDAndkey {
    [self keyChainDeleteKey:kKeyChainPassKey];
    [self keyChainDeleteKey:kKeyChainIDKey];
}
#pragma mark - private
+ (void)keyChainSaveData:(id)data forKey:(NSString *)key {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
    OSStatus result = SecItemAdd((__bridge CFDictionaryRef)keychainQuery, NULL);
    if (!result) {
    }
}

+ (id)keyChainGetDataforKey:(NSString *)key {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:key];
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
    }
    if (keyData) CFRelease(keyData);
    return ret;
}
+ (BOOL)keyChainHasDataForKey:(NSString *)key {
    return [self keyChainGetDataforKey:key] ? YES : NO;
}
+ (void)keyChainDeleteKey:(NSString *)service
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)keychainQuery);
}

//helper
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)key
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)kSecClassGenericPassword, (__bridge id)kSecClass,
            key, (__bridge id)kSecAttrService,
            key, (__bridge id)kSecAttrAccount,
            (__bridge id)kSecAttrAccessibleAfterFirstUnlock, (__bridge id)kSecAttrAccessible,
            nil];
}@end
