//
//  UIBarButtonItem+CXBarButtonItem.h
//  WeiXinJingXuan
//
//  Created by 陈晓 on 2016/11/6.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (CXBarButtonItem)
/*
 * 快速创建有高亮状态的UIBarButtonItem
 */
+ (UIBarButtonItem *)itemWithImage:(UIImage *)image highImage:(UIImage *)highImage target:(id)target action:(SEL)action;
/*
 * 快速创建有选中状态的UIBarButtonItem
 */
+ (UIBarButtonItem *)itemWithImage:(UIImage *)image selImage:(UIImage *)selImage target:(id)target action:(SEL)action;
/*
 * 创建返回按钮
 */
+ (UIBarButtonItem *)backItemWithImage:(UIImage *)image highImage:(UIImage *)highImage target:(id)target action:(SEL)action title:(NSString *)title;
@end
