//
//  CXAlertController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/14.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXAlertController.h"

@implementation CXAlertController
/*
 * 只有确定和取消
 */
+ (void)alertSureAndCancelWithTitle:(NSString *)title message:(NSString *)message sureHandler:(void (^)(UIAlertAction *action))sureHandler cancelHandler:(void (^)(UIAlertAction *action))cancelHandler viewController:(UIViewController *)vc
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:sureHandler];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:cancelHandler];
    [alert addAction:sure];
    [alert addAction:cancel];
    [vc presentViewController:alert animated:YES completion:nil];
}
/*
 * 修改头像
 */
+ (void)alertForEditAvatorWithCameraHandler:(void (^)(UIAlertAction *action))cameraHandler photoHandler:(void (^)(UIAlertAction *action))photoHandler viewController:(UIViewController *)viewController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:cameraHandler];
    UIAlertAction *album = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:photoHandler];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:takePhoto];
    [alert addAction:album];
    [alert addAction:cancel];
    [viewController presentViewController:alert animated:YES completion:nil];
}
/*
 * 修改用户名
 */
+ (void)alertForEditUserNameWithConfigHandler:(void (^)(UITextField *textField))configHandler saveHandler:(void (^)(UIAlertAction *action))saveHandler viewController:(UIViewController *)viewController
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改用户名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:configHandler];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"保存" style:UIAlertActionStyleDefault handler:saveHandler];
    [alert addAction:cancel];
    [alert addAction:save];
    [viewController presentViewController:alert animated:YES completion:nil];
}
@end
