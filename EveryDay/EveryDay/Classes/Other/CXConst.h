#import <UIKit/UIKit.h>

/** 状态栏的高度 */
UIKIT_EXTERN CGFloat const CXStatusBarH;
/** 导航栏的最大Y值 */
UIKIT_EXTERN CGFloat const CXNavigationBarMaxY;
/** 统一的间距 */
UIKIT_EXTERN CGFloat const CXMargin;

//后台进入前台的通知
UIKIT_EXTERN NSString * const CXAppWillEnterForegroundNotification;
//登录成功的通知
UIKIT_EXTERN NSString * const CXLoginSuccessNotification;
//编辑个人信息的通知
UIKIT_EXTERN NSString * const CXEditPersonalInfoNotification;
//退出登录的通知
UIKIT_EXTERN NSString * const CXLoginOutNotification;

//平方字体
UIKIT_EXTERN NSString * const CXPingFangLight;

//APPLE ID
UIKIT_EXTERN NSInteger const CXAPPLEID;

//阅读界面字体大小
UIKIT_EXTERN NSString * const CXFontSizeKey;
//阅读界面背景颜色
UIKIT_EXTERN NSString * const CXReadBgColorKey;
//阅读界面字体颜色
UIKIT_EXTERN NSString * const CXTextColorKey;
