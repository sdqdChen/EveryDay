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


@interface CXHeadLoginView ()
/** 登录按钮 */
@property (nonatomic, strong) CXLoginButton *loginButton;
/** 分割线 */
@property (nonatomic, strong) UIView *separatorView;
@end

@implementation CXHeadLoginView
#pragma mark - 懒加载
- (UIView *)separatorView
{
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor darkGrayColor];
    }
    return _separatorView;
}
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //登录按钮
        CXLoginButton *loginButton = [CXLoginButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:loginButton];
        self.loginButton = loginButton;
        //分割线
        [self addSubview:self.separatorView];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
    }];
    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(CXseparatorViewW, 1));
        make.centerX.mas_equalTo(self);
        make.bottom.offset(0);
    }];
}
@end
