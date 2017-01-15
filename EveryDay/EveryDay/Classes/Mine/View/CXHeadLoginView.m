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
#import "CXNavigationController.h"
#import "CXAlertController.h"
#import "UITextField+Placeholder.h"

@interface CXHeadLoginView () <UITextFieldDelegate>
/** 登录按钮 */
@property (nonatomic, strong) CXLoginButton *loginButton;
/** 分割线 */
@property (nonatomic, strong) UIView *separatorView;
/** 用户名(手机号) */
@property (nonatomic, strong) UILabel *userNameLabel;
/** 导航控制器 */
@property (nonatomic, strong) CXNavigationController *nav;
/** 修改用户名文本框 */
@property (nonatomic, strong) UITextField *userNameTextField;
/** 当前用户 */
@property (nonatomic, strong) MLUser *currentUser;
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
        if ([CXUserDefaults readBoolForKey:LoginSuccess]) { //登录状态
            _userNameLabel.text = self.currentUser.username;
        }
        [_userNameLabel sizeToFit];
        _userNameLabel.hidden = YES;
        _userNameLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editUserName)];
        [_userNameLabel addGestureRecognizer:tap];
    }
    return _userNameLabel;
}
- (CXNavigationController *)nav
{
    if (!_nav) {
        _nav = (CXNavigationController *)self.window.rootViewController;
    }
    return _nav;
}
- (MLUser *)currentUser
{
    if (!_currentUser) {
        _currentUser = [MLUser currentUser];
    }
    return _currentUser;
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
#pragma mark - 修改用户名
- (void)editUserName
{
    [CXAlertController alertForEditUserNameWithConfigHandler:^(UITextField *textField) {
        [self setupTextField:textField];
    } saveHandler:^(UIAlertAction *action) {
        [self saveUserName];
    } viewController:self.nav];
}
/*
 * 设置修改用户名的文本框
 */
- (void)setupTextField:(UITextField *)textField
{
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.placeholder = @"15字以内(汉字/数字/字母)";
    textField.placeholderColor = [UIColor lightGrayColor];
    self.userNameTextField = textField;
    [textField addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
}
/*
 * 保存用户名
 */
- (void)saveUserName
{
    //替换用户名
    self.userNameLabel.text = self.userNameTextField.text;
    [self.userNameLabel sizeToFit];
    //保存到服务器
    [self saveUserNameToServer];
}
#pragma mark - 服务器保存用户名
- (void)saveUserNameToServer
{
    self.currentUser[@"username"] = self.userNameTextField.text;
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            CXLog(@"%@", error);
        } else {
            CXLog(@"成功");
        }
    }];
}
#pragma mark - UITextField代理方法
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self isInputRuleNotBlank:string] || [string isEqualToString:@""]) {//当输入符合规则和退格键时允许改变输入框
        return YES;
    } else {
        CXLog(@"超出字数限制");
        return NO;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    return YES;
}
#pragma mark - UITextField限制输入
static NSInteger kMaxLength = 15;
- (void)textFieldEditChanged:(UITextField *)textField
{
    NSString *toBeString = textField.text;
    NSString *lang = [[textField textInputMode] primaryLanguage]; // 获取当前键盘输入模式
    if([lang isEqualToString:@"zh-Hans"]) { //简体中文输入,第三方输入法（搜狗）所有模式下都会显示“zh-Hans”
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if(!position)
        {
            if (toBeString.length > kMaxLength)
            {
                NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:kMaxLength];
                if (rangeIndex.length == 1)
                {
                    textField.text = [toBeString substringToIndex:kMaxLength];
                }
                else
                {
                    NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, kMaxLength)];
                    textField.text = [toBeString substringWithRange:rangeRange];
                }
            }
        }
    } else {
        if (toBeString.length > kMaxLength)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:kMaxLength];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:kMaxLength];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, kMaxLength)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
    }
}
/*
 * 字母、数字、中文判断（包括空格）
 */
- (BOOL)isInputRuleNotBlank:(NSString *)str {
    NSString *pattern = @"^[a-zA-Z\u4E00-\u9FA5\\d]*$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    // 这里是后期补充的内容:九宫格判断
    if (!isMatch) {
        NSString *other = @"➋➌➍➎➏➐➑➒";
        unsigned long len=str.length;
        for(int i=0;i<len;i++)
        {
            unichar a=[str characterAtIndex:i];
            if(!((isalpha(a))
                 ||(isalnum(a))
                 ||((a=='_') || (a == '-'))
                 ||((a >= 0x4e00 && a <= 0x9fa6))
                 ||([other rangeOfString:str].location != NSNotFound)
                 ))
                return NO;
        }
        return YES;
    }
    return isMatch;
}

@end
