//
//  CXHeadLoginView.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/13.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXHeadLoginView.h"
#import "CXLoginButton.h"
#import <Masonry.h>
#import <MaxLeap/MaxLeap.h>
#import "CXUserDefaults.h"
#import "CXMineCell.h"


@interface CXHeadLoginView ()
/** 登录按钮 */
@property (nonatomic, strong) CXLoginButton *loginButton;
/** 分割线 */
@property (nonatomic, strong) UIView *separatorView;
/** 用户名(手机号) */
@property (nonatomic, strong) UILabel *userNameLabel;
@end

@implementation CXHeadLoginView
#pragma mark - 懒加载
- (CXLoginButton *)loginButton
{
    if (!_loginButton) {
        _loginButton = [CXLoginButton buttonWithType:UIButtonTypeCustom];
    }
    return _loginButton;
}
- (UIView *)separatorView
{
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor darkGrayColor];
    }
    return _separatorView;
}
- (UILabel *)userNameLabel
{
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] init];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        [_userNameLabel sizeToFit];
        _userNameLabel.hidden = YES;
        _userNameLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editUserName)];
        [_userNameLabel addGestureRecognizer:tap];
    }
    return _userNameLabel;
}
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //登录按钮
        [self addSubview:self.loginButton];
        //分割线
        [self addSubview:self.separatorView];
        //用户名
        [self addSubview:self.userNameLabel];
        if ([CXUserDefaults readBoolForKey:LoginSuccess]) {
            self.userNameLabel.text = [MLUser currentUser].username;
            self.userNameLabel.hidden = NO;
        }
        //添加通知
        [self addNotification];
    }
    return self;
}
#pragma mark - 监听通知
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
#pragma mark - 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    //登录按钮
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(loginButtonW * KRATE, loginButtonW * KRATE));
    }];
    //分割线
    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(separatorW, 1));
        make.centerX.mas_equalTo(self);
        make.bottom.offset(0);
    }];
    //用户名
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.loginButton.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self);
    }];
}
#pragma mark - 监听事件
/*
 * 登录成功
 */
- (void)loginSuccess
{
    self.userNameLabel.text = [MLUser currentUser].username;
    [self.userNameLabel sizeToFit];
    self.userNameLabel.hidden = NO;
}
/*
 * 退出登录
 */
- (void)loginOut
{
    self.userNameLabel.hidden = YES;
}
/*
 * 编辑用户名
 */
- (void)editUserName
{
    CXLog(@"修改用户名");
}
@end
