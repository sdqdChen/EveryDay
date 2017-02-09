//
//  CXPhoneNumberView.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/13.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXPhoneNumberView.h"
#import "CXUserDefaults.h"
#import "UITextField+Placeholder.h"
#import "CXVerificationCodeView.h"
#import <MaxLeap/MaxLeap.h>
#import <WSProgressHUD.h>
#import <SVProgressHUD.h>

@interface CXPhoneNumberView ()
/** 输入手机号的文本框 */
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
/** 获取验证码按钮 */
@property (weak, nonatomic) IBOutlet UIButton *verificationCodeButton;
/** 清除按钮 */
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
/** 分割线 */
@property (weak, nonatomic) IBOutlet UIView *seperatorView;
/** 输入验证码view */
@property (nonatomic, weak) CXVerificationCodeView *codeView;
@end


@implementation CXPhoneNumberView
#pragma mark - 初始化
+ (instancetype)loadPhoneNumFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:@"CXPhoneNumberView" owner:nil options:nil].firstObject;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupNumberTextField];
    [self setupVerificationButton];
    [self.clearButton addTarget:self action:@selector(clearText) forControlEvents:UIControlEventTouchUpInside];
}
/*
 * 设置获取验证码按钮
 */
- (void)setupVerificationButton
{
    [self.verificationCodeButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self.verificationCodeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.verificationCodeButton addTarget:self action:@selector(getVerificationCode:) forControlEvents:UIControlEventTouchUpInside];
}
/*
 * 设置电话文本框
 */
- (void)setupNumberTextField
{
    //读取存储的手机号
    NSString *number = [CXUserDefaults readObjectForKey:NumberKey];
    self.numberTextField.text = number;
    if (number) {
        self.verificationCodeButton.enabled = YES;
    }
    self.numberTextField.placeholderColor = [UIColor lightGrayColor];
    self.numberTextField.tintColor = [UIColor blackColor];
    [self.numberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.numberTextField addTarget:self action:@selector(textFieldDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [self.numberTextField addTarget:self action:@selector(textFieldDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
}
#pragma mark - 监听文本框
/*
 * 文本框结束编辑
 */
- (void)textFieldDidEnd:(UITextField *)textField
{
    self.clearButton.hidden = YES;
}
/*
 * 文本框开始编辑
 */
- (void)textFieldDidBegin:(UITextField *)textField
{
    self.clearButton.hidden = NO;
}
/*
 * 文本框的值发生变化
 */
- (void)textFieldDidChange:(UITextField *)textField
{
    self.clearButton.hidden = NO;
    if (textField.text.length >= 11) { //如果输入了11位数字
        textField.text = [textField.text substringToIndex:11];
        self.verificationCodeButton.enabled = YES;
        if (self.verificationCodeButton.hidden) {
            [self.codeView.firstTextField becomeFirstResponder];
            self.clearButton.hidden = YES;
            self.codeView.phoneNumber = textField.text;
        }
        //存储手机号
        [CXUserDefaults setObject:textField.text forKey:NumberKey];
    } else {
        self.verificationCodeButton.enabled = NO;
    }
}
/*
 * 清除文本
 */
- (void)clearText
{
    self.numberTextField.text = @"";
    self.verificationCodeButton.enabled = NO;
    //清除存储的手机号
    [CXUserDefaults removeCXObjectForKey:NumberKey];
}
#pragma mark - 监听获取验证码点击
/*
 * 获取验证码
 */
- (void)getVerificationCode:(UIButton *)button
{
    if ([self.numberTextField.text isEqualToString:@"11223344556"]) {
        [self testLogin]; //仅仅是审核时的测试账号
    } else {
        [MLUser requestLoginSmsCodeWithPhoneNumber:self.numberTextField.text block:^(BOOL succeeded, NSError * _Nullable error) {
            if (succeeded) {
                //1. 添加验证码view
                [UIView animateWithDuration:0.3 animations:^{
                    self.verificationCodeButton.hidden = YES;
                    self.seperatorView.hidden = YES;
                }];
                CXVerificationCodeView *codeView = [CXVerificationCodeView loadVerificationCodeView];
                self.codeView = codeView;
                codeView.phoneNumber = self.numberTextField.text;
                [self addSubview:codeView];
                //2. 第一响应者
                [codeView.firstTextField becomeFirstResponder];
                //3. 隐藏clearButton
                self.clearButton.hidden = YES;
            } else {
                if (error.code == 1) {
                    [WSProgressHUD showImage:nil status:@"请输入正确的手机号!"];
                } else if (error.code == 503) {
                    [WSProgressHUD showImage:nil status:@"发送频繁，请稍后再试!"];
                } else {
                    [WSProgressHUD showImage:nil status:@"发送失败，请稍后再试!"];
                }
            }
        }];
    }
}
- (void)testLogin
{
    [MLUser logInWithUsernameInBackground:@"测试账号" password:@"123456" block:^(MLUser * _Nullable user, NSError * _Nullable error) {
        if (user) { //登录成功
            [UIView animateWithDuration:0.3 animations:^{
                [self endEditing:YES];
                [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
            }];
            //2.保存登录成功状态
            [CXUserDefaults setBool:YES forKey:LoginSuccess];
            [SVProgressHUD showSuccessWithStatus:@"登录成功"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        } else {
            CXLog(@"%@", error);
        }
    }];
}
#pragma mark - 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat codeViewH = self.cx_height * 0.6;
    CGFloat codeViewY = self.cx_height - codeViewH;
    self.codeView.frame = CGRectMake(0, self.cx_height, self.cx_width, codeViewH);
    [UIView animateWithDuration:0.3 animations:^{
        self.codeView.frame = CGRectMake(0, codeViewY, self.cx_width, codeViewH);
    }];
}
@end
