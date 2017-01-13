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

@implementation CXLoginButton
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundImage:[UIImage imageNamed:@"loginButton"] forState:UIControlStateNormal];
        [self sizeToFit];
        [self addTarget:self action:@selector(loginButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
/*
 * 点击登录
 */
- (void)loginButtonClick
{
    CXLoginRegisterViewController *loginVc = [[CXLoginRegisterViewController alloc] init];
    CXNavigationController *nav = (CXNavigationController *)self.window.rootViewController;
    [nav presentViewController:loginVc animated:YES completion:nil];
}
/*
 * 取消按钮高亮
 */
- (void)setHighlighted:(BOOL)highlighted
{
    
}
@end
