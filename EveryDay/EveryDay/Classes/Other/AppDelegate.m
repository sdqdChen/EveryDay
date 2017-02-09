//
//  AppDelegate.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/2.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "AppDelegate.h"
#import "CXUserDefaults.h"
#import <MaxLeap/MaxLeap.h>
#import <UMSocialCore/UMSocialCore.h>
#import "CXHomeViewController.h"
#import "CXNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //初始化
    [self initialization];
    //MaxLeap
    [self setupMaxLeap];
    //友盟分享设置
    [self setupUMSocial];
    return YES;
}
- (void)initialization
{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    CXNavigationController *nav = [[CXNavigationController alloc] initWithRootViewController:[[CXHomeViewController alloc] init]];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}
- (void)setupMaxLeap
{
    [MaxLeap setApplicationId:@"5878b9f3a1600200075869b3" clientKey:@"MElGVXlxU2t1c01RVi1lMUpYV0NDZw" site:MLSiteCN];
    MLObject *obj = [MLObject objectWithoutDataWithClassName:@"Test" objectId:@"561c83c0226"];
    [obj fetchIfNeededInBackgroundWithBlock:^(MLObject * _Nullable object, NSError * _Nullable error) {
        if (error.code == kMLErrorInvalidObjectId) {
            CXLog(@"已经能够正确连接上您的云端应用");
        } else if (error && error.code < kMLErrorInternalServer) {
            CXLog(@"未知错误： %@", error);
        } else if (error && error.code == kMLErrorInternalServer) {
            CXLog(@"服务器出错： %@", error);
        } else if (error && error.code == kMLErrorConnectionFailed) {
            CXLog(@"网络错误： %@", error);
        } else {
            CXLog(@"\n\n应用访问凭证可能不正确，请检查。错误信息：\n%@\n\n", error);
        }
    }];
}
- (void)setupUMSocial
{
    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"583be0791c5dd0638c0016ea"];
    
    //设置微信的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wxe786a7197f4e8b6f" appSecret:@"fccf2a9d06857ad4da5cedebb4de5712" redirectURL:@"http://mobile.umeng.com/social"];
    [[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    //设置分享到QQ互联的appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1105776989"  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    //设置新浪的appKey和appSecret
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"4224357295"  appSecret:@"79537020aff2d7055848644c4eb54c88" redirectURL:@"http://sns.whalecloud.com/sina2/callback"];
}
// 设置系统回调
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

/*
 * 应用从后台到前台
 */
- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[NSNotificationCenter defaultCenter] postNotificationName:CXAppWillEnterForegroundNotification object:nil];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
