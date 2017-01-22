//
//  CXWebViewScreenShot.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/22.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXWebViewScreenShot.h"

@implementation CXWebViewScreenShot
+ (UIImage *)screenShotWithWebView:(UIWebView *)webView
{
    UIImage* image = nil;
    UIGraphicsBeginImageContextWithOptions(webView.scrollView.contentSize, webView.opaque, 0.0);
    //保存现在的位置和尺寸
    CGPoint savedContentOffset = webView.scrollView.contentOffset;
    CGRect savedFrame = webView.frame;
    //设置尺寸和内容一样大
    webView.scrollView.contentOffset = CGPointZero;
    webView.frame = CGRectMake(0, 0, webView.scrollView.contentSize.width, webView.scrollView.contentSize.height);
    [webView.layer renderInContext: UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    //恢复原来的位置和尺寸
    webView.scrollView.contentOffset = savedContentOffset;
    webView.frame = savedFrame;
    UIGraphicsEndImageContext();
    return image;
}
@end
