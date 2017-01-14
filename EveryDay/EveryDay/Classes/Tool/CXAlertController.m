//
//  CXAlertController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/14.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXAlertController.h"

@implementation CXAlertController
+ (void)alertSureAndCancelWithTitle:(NSString *)title sureHandler:(void (^)(UIAlertAction *action))sureHandler cancelHandler:(void (^)(UIAlertAction *action))cancelHandler viewController:(UIViewController *)vc
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:sureHandler];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:cancelHandler];
    [alert addAction:sure];
    [alert addAction:cancel];
    [vc presentViewController:alert animated:YES completion:nil];
}
@end
