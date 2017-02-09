//
//  CXSetupWebView.h
//  EveryDay
//
//  Created by 陈晓 on 2017/2/8.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXSetupWebView : NSObject
/*
 * 设置网页背景颜色
 */
+ (void)setupBgColorWith:(NSString *)color webView:(UIWebView *)webView;
/*
 * 设置网页文字颜色
 */
+ (void)setupTextColorWith:(NSString *)color webView:(UIWebView *)webView;
/*
 * 设置网页文字大小
 */
+ (void)setupTextFontWith:(NSInteger)size webView:(UIWebView *)webView;
@end
