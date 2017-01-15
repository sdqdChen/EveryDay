//
//  CXAlertController.h
//  EveryDay
//
//  Created by 陈晓 on 2017/1/14.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXAlertController : UIViewController
/*
 * 只有确定和取消
 */
+ (void)alertSureAndCancelWithTitle:(NSString *)title message:(NSString *)message sureHandler:(void (^)(UIAlertAction *action))sureHandler cancelHandler:(void (^)(UIAlertAction *action))cancelHandler viewController:(UIViewController *)vc;
/*
 * 修改头像
 */
+ (void)alertForEditAvatorWithCameraHandler:(void (^)(UIAlertAction *action))cameraHandler photoHandler:(void (^)(UIAlertAction *action))photoHandler viewController:(UIViewController *)vc;
/*
 * 修改用户名
 */
+ (void)alertForEditUserNameWithConfigHandler:(void (^)(UITextField *textField))configHandler saveHandler:(void (^)(UIAlertAction *action))saveHandler viewController:(UIViewController *)viewController;
@end
