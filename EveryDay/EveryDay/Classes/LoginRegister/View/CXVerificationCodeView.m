//
//  CXVerificationCodeView.m
//  WeiXinJingXuan
//
//  Created by 陈晓 on 2016/12/13.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import "CXVerificationCodeView.h"
#import <WSProgressHUD.h>
#import <MaxLeap/MaxLeap.h>
#import "CXUserDefaults.h"
#import <SVProgressHUD.h>

#define countDownSeconds 60
#define textFieldCount 6

@interface CXVerificationCodeView () <CXNumberTextFieldDelegate>
//包含四个文本框的占位图
@property (weak, nonatomic) IBOutlet UIView *inputView;
//重新获取按钮
@property (weak, nonatomic) IBOutlet UIButton *obtainAgainButton;
//六个文本框
@property (nonatomic, weak) CXNumberTextField *textField;
//定时器
@property (nonatomic, weak) NSTimer *timer;
@end


@implementation CXVerificationCodeView
- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    }
    return _timer;
}
#pragma mark - 初始化
+ (instancetype)loadVerificationCodeView
{
    return [[NSBundle mainBundle] loadNibNamed:@"CXVerificationCodeView" owner:nil options:nil].firstObject;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    for (NSInteger i = 0; i<textFieldCount; i++) { //添加6个文本框
        CXNumberTextField *textField = [[CXNumberTextField alloc] init];
        textField.cx_delegate = self;
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.tag = i + 1;
        if (textField.tag == 1) {
            self.firstTextField = textField;
        }
        self.textField = textField;
        [self.inputView addSubview:textField];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(invalidateTimer) name:@"invalidateTimer" object:nil];
    [self.timer fire];//立即开启
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"invalidateTimer" object:nil];
}
#pragma mark - 定时器
static int seconds = countDownSeconds;
- (void)timeChange
{
    if (seconds == -1) {
        seconds += countDownSeconds + 1;
    }
    //按钮文字
    [self.obtainAgainButton setTitle:[NSString stringWithFormat:@"重新获取(%d)", seconds] forState:UIControlStateNormal];
    if (seconds == 0) {
        //销毁定时器
        [self.timer invalidate];
        self.timer = nil;
        self.obtainAgainButton.enabled = YES;
        [self.obtainAgainButton setTitle:@"重新获取" forState:UIControlStateNormal];
        [self.obtainAgainButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    seconds--;
}
/*
 * 销毁定时器
 */
- (void)invalidateTimer
{
    [self.timer invalidate];
    self.timer = nil;
    seconds = countDownSeconds;
}
#pragma mark - 重新获取验证码
- (IBAction)obtainAgainButtonClick:(UIButton *)sender
{
//    self.obtainAgainButton.enabled = NO;
//    [self.obtainAgainButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
//    [self.timer fire];
    [MLUser requestLoginSmsCodeWithPhoneNumber:self.phoneNumber block:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            self.obtainAgainButton.enabled = NO;
            [self.obtainAgainButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
            [self.timer fire];
        } else {
            if (error.code == 1) {
                [WSProgressHUD showImage:nil status:@"请输入正确的手机号!"];
            } else {
                [WSProgressHUD showImage:nil status:@"发送失败，请稍后再试!"];
            }
        }
    }];
}

#pragma mark - 监听文本框
/*
 * 监听删除键
 */
- (void)CXNumberTextFieldDelete:(CXNumberTextField *)textField
{
    NSInteger currentIndex = textField.tag;
    NSInteger preIndex = currentIndex - 1;
    //上一个文本框
    CXNumberTextField *preText = [self.inputView viewWithTag:preIndex];
    if (preIndex > 0) {
        [preText becomeFirstResponder];
        if (currentIndex == textFieldCount && textField.text.length != 0) {
            textField.text = @"";
        } else {
            preText.text = @"";
        }
    }
    if (currentIndex == 1) {
        [self.firstTextField becomeFirstResponder];
    }
}
/*
 * 文本框的值发生变化
 */
- (void)textFieldDidChange:(CXNumberTextField *)textField
{
    if (textField.text.length >= 1) { //每个文本框只允许输入一个数字
        textField.text = [textField.text substringToIndex:1];
        //自动跳转下一个
        NSInteger currentIndex = textField.tag;
        if (currentIndex != textFieldCount) {
            NSInteger nextIndex = currentIndex + 1;
            CXNumberTextField *next = [self.inputView viewWithTag:nextIndex];
            [next becomeFirstResponder];
        } else { //如果6个文本框都输入完，判断验证码
            //1.获取6个文本框的数字
            NSMutableString *verificationCode = [NSMutableString string];
            for (CXNumberTextField *tf in self.inputView.subviews) {
                [verificationCode appendString:tf.text];
            }
//            [self verifySuccess];
            //验证码验证
            [MLUser loginWithPhoneNumber:self.phoneNumber smsCode:verificationCode block:^(MLUser * _Nullable user, NSError * _Nullable error) {
                if (user) { //成功
                    [self verifySuccess];
                } else { //失败
                    [textField becomeFirstResponder];//1.键盘不退出
                    [self verifyFailed];
                }
            }];
        }
    }
}
#pragma mark - 判断验证码
- (void)verifySuccess
{
    //1.退出当前界面
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
    //3.销毁定时器
    [self invalidateTimer];
}
- (void)verifyFailed
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (CXNumberTextField *tf in self.inputView.subviews) {
            tf.text = @"";//2.清空文本框
        }
        [self.firstTextField becomeFirstResponder];//3.光标移到第一个
        //4.提醒用户验证失败
        [WSProgressHUD showImage:nil status:@"验证码输入错误!"];
    });
}

#pragma mark - 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    NSInteger count = self.inputView.subviews.count;
    CGFloat margin = 5;
    CGFloat textFieldW = (self.inputView.cx_width - (count - 1) * margin) / count;
    CGFloat textFieldY = self.inputView.cx_height - textFieldW;
    NSInteger i = 0;
    for (UIView *textField in self.inputView.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            CGFloat textFieldX = i * (textFieldW + margin);
            textField.frame = CGRectMake(textFieldX, textFieldY, textFieldW, textFieldW);
            i++;
        }
    }
}
@end
