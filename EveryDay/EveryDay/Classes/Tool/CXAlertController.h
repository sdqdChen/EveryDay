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
 * 只有确定和退出
 */
+ (void)alertSureAndCancelWithTitle:(NSString *)title sureHandler:(void (^)(UIAlertAction *action))sureHandler cancelHandler:(void (^)(UIAlertAction *action))cancelHandler viewController:(UIViewController *)vc;
@end
