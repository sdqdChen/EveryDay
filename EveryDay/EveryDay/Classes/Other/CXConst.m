#import <UIKit/UIKit.h>

/** 状态栏的高度 */
CGFloat const CXStatusBarH = 20;
/** 导航栏的最大Y值 */
CGFloat const CXNavigationBarMaxY = 64;
/** 统一的间距 */
CGFloat const CXMargin = 10;

//后台进入前台的通知
NSString * const CXAppWillEnterForegroundNotification = @"CXAppWillEnterForegroundNotification";
//登录成功的通知
NSString * const CXLoginSuccessNotification = @"CXLoginSuccessNotification";
//编辑个人信息的通知
NSString * const CXEditPersonalInfoNotification = @"CXEditPersonalInfoNotification";
//退出登录的通知
NSString * const CXLoginOutNotification = @"CXLoginOutNotification";;

//平方字体
NSString * const CXPingFangLight = @"PingFangSC-Light";

//APPLE ID
NSInteger const CXAPPLEID = 1202823847;

//阅读界面字体大小
NSString * const CXFontSizeKey = @"CXFontSizeKey";
//阅读界面背景颜色
NSString * const CXReadBgColorKey = @"CXReadBgColorKey";
//阅读界面字体颜色
NSString * const CXTextColorKey = @"CXTextColorKey";
