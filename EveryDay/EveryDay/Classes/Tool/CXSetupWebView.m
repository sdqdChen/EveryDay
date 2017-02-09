//
//  CXSetupWebView.m
//  EveryDay
//
//  Created by 陈晓 on 2017/2/8.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXSetupWebView.h"

@implementation CXSetupWebView

/*
 * 设置网页背景颜色
 */
+ (void)setupBgColorWith:(NSString *)color webView:(UIWebView *)webView
{
    NSString *string = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.backgroundColor=\"%@\"", color];
    [webView stringByEvaluatingJavaScriptFromString:string];
}
/*
 * 设置网页文字颜色
 */
+ (void)setupTextColorWith:(NSString *)color webView:(UIWebView *)webView
{
    NSString *string = [NSString stringWithFormat:@"document.getElementById('content').style.color=\"%@\";document.getElementById('mainTitle').style.color=\"%@\";document.getElementById('end').style.color=\"%@\";document.getElementById('author').style.color=\"%@\";", color, color, color, color];
    [webView stringByEvaluatingJavaScriptFromString:string];
}
/*
 * 设置网页文字大小
 */
+ (void)setupTextFontWith:(NSInteger)size webView:(UIWebView *)webView
{
    NSString *string = [NSString stringWithFormat:@"document.getElementById('content').style.webkitTextSizeAdjust= '%ld%%';document.getElementById('mainTitle').style.webkitTextSizeAdjust= '%ld%%';", size, size];
    [webView stringByEvaluatingJavaScriptFromString:string];
}
@end
