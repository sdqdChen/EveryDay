//
//  CXUserDefaults.h
//  WeiXinJingXuan
//
//  Created by 陈晓 on 2016/12/16.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXUserDefaults : NSObject
//BOOL
+ (void)setBool:(BOOL)cx_bool forKey:(NSString *)key;
+ (BOOL)readBoolForKey:(NSString *)key;
//object
+ (void)setObject:(id)object forKey:(NSString *)key;
+ (id)readObjectForKey:(NSString *)key;
+ (void)removeCXObjectForKey:(NSString *)key;
//image
+ (void)setImage:(UIImage *)image forKey:(NSString *)key;
+ (UIImage *)readImageForKey:(NSString *)key;
//integer
+ (void)setInteger:(NSInteger)integer forKey:(NSString *)key;
+ (NSInteger)readIntegerForKey:(NSString *)key;
@end
