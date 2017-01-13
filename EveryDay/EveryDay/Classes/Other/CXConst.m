#import <UIKit/UIKit.h>

/** 状态栏的高度 */
CGFloat const CXStatusBarH = 20;
/** 导航栏的最大Y值 */
CGFloat const CXNavigationBarMaxY = 64;
/** 分割线的宽度 */
CGFloat const CXseparatorViewW = 90;
/** 统一的间距 */
CGFloat const CXMargin = 10;

//后台进入前台的通知
NSString * const CXAppWillEnterForegroundNotification = @"CXAppWillEnterForegroundNotification";
//登录成功的通知
NSString * const CXLoginSuccessNotification = @"CXLoginSuccessNotification";
//编辑个人信息的通知
NSString * const CXEditPersonalInfoNotification = @"CXEditPersonalInfoNotification";
//退出登录的通知
NSString * const CXLoginOutNotification = @"CXLoginOutNotification";
//头像下载完成的通知
NSString * const CXIconDownloadNotification = @"CXIconDownloadNotification";

//平方字体
NSString * const CXPingFangLight = @"PingFangSC-Light";
