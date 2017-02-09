//
//  CXUserDefaults.m
//  WeiXinJingXuan
//
//  Created by 陈晓 on 2016/12/16.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import "CXUserDefaults.h"

@implementation CXUserDefaults
+ (void)setBool:(BOOL)cx_bool forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:cx_bool forKey:key];
    [defaults synchronize];
}
+ (BOOL)readBoolForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:key];
}

+ (void)setObject:(id)object forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:object forKey:key];
    [defaults synchronize];
}
+ (id)readObjectForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}
+ (void)removeCXObjectForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}

+ (void)setImage:(UIImage *)image forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults setObject:UIImageJPEGRepresentation(image, 1) forKey:key];
}
+ (UIImage *)readImageForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:key];
    return [UIImage imageWithData:data];
}
+ (void)setInteger:(NSInteger)integer forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:integer forKey:key];
    [defaults synchronize];
}
+ (NSInteger)readIntegerForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:key];
}
@end
