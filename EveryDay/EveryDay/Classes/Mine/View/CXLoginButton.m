//
//  CXLoginButton.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/13.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXLoginButton.h"
#import "CXLoginRegisterViewController.h"
#import "CXNavigationController.h"
#import "CXUserDefaults.h"

@implementation CXLoginButton
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //根据是否登录设置不同图片
        if ([CXUserDefaults readBoolForKey:LoginSuccess]) {
            [self setBackgroundImage:[UIImage imageNamed:@"avator"] forState:UIControlStateNormal];
        } else {
            [self setBackgroundImage:[UIImage imageNamed:@"loginButton"] forState:UIControlStateNormal];
        }
        [self sizeToFit];
        [self addTarget:self action:@selector(loginButtonClick) forControlEvents:UIControlEventTouchUpInside];
        //添加通知
        [self addNotification];
    }
    return self;
}
/*
 * 取消按钮高亮
 */
- (void)setHighlighted:(BOOL)highlighted
{
    
}
#pragma mark - 通知
- (void)addNotification
{
    //监听登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:CXLoginSuccessNotification object:nil];
    //退出登录的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut) name:CXLoginOutNotification object:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CXLoginSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CXLoginOutNotification object:nil];
}
#pragma mark - 监听事件
/*
 * 点击登录
 */
- (void)loginButtonClick
{
    if ([CXUserDefaults readBoolForKey:LoginSuccess]) { //已登录
        CXLog(@"修改头像");
    } else { //未登录
        CXLoginRegisterViewController *loginVc = [[CXLoginRegisterViewController alloc] init];
        CXNavigationController *nav = (CXNavigationController *)self.window.rootViewController;
        [nav presentViewController:loginVc animated:YES completion:nil];
    }
}
/*
 * 如果登录成功-设置默认头像
 */
- (void)loginSuccess
{
    [self setBackgroundImage:[UIImage imageNamed:@"avator"] forState:UIControlStateNormal];
}
/*
 * 退出登录
 */
- (void)loginOut
{
    [self setBackgroundImage:[UIImage imageNamed:@"loginButton"] forState:UIControlStateNormal];
}
@end
