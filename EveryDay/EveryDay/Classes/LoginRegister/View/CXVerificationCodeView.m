//
//  CXVerificationCodeView.m
//  WeiXinJingXuan
//
//  Created by 陈晓 on 2016/12/13.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import "CXVerificationCodeView.h"
#import <SVProgressHUD.h>

#define countDownSeconds 5

@interface CXVerificationCodeView () <CXNumberTextFieldDelegate>
//包含四个文本框的占位图
@property (weak, nonatomic) IBOutlet UIView *inputView;
//重新获取按钮
@property (weak, nonatomic) IBOutlet UIButton *obtainAgainButton;
//四个文本框
@property (nonatomic, weak) CXNumberTextField *textField;
//定时器
@property (nonatomic, weak) NSTimer *timer;
@end


@implementation CXVerificationCodeView
#pragma mark - 初始化
+ (instancetype)loadVerificationCodeView
{
    return [[NSBundle mainBundle] loadNibNamed:@"CXVerificationCodeView" owner:nil options:nil].firstObject;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    for (NSInteger i = 0; i<4; i++) { //添加4个文本框
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
    [self setupTimer];
}
#pragma mark - 定时器
/*
 * 开启定时器
 */
- (void)setupTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    [self.timer fire];//立即开启
}
- (void)timeChange
{
    static int seconds = countDownSeconds;
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
 * 重新获取验证码
 */
- (IBAction)obtainAgainButtonClick:(UIButton *)sender
{
    self.obtainAgainButton.enabled = NO;
    [self.obtainAgainButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    [self setupTimer];
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
        if (currentIndex == 4 && textField.text.length != 0) {
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
        if (currentIndex != 4) {
            NSInteger nextIndex = currentIndex + 1;
            CXNumberTextField *next = [self.inputView viewWithTag:nextIndex];
            [next becomeFirstResponder];
        } else { //如果4个文本框都输入完，判断验证码
            //1.获取4个文本框的数字
            NSMutableString *verificationCode = [NSMutableString string];
            for (CXNumberTextField *tf in self.inputView.subviews) {
                [verificationCode appendString:tf.text];
            }
            //验证码验证
            
        }
    }
}
#pragma mark - 布局子控件
- (void)layoutSubviews
{
    [super layoutSubviews];
    NSInteger count = self.inputView.subviews.count;
    CGFloat textFieldW = (self.inputView.cx_width - (count + 1) * CXMargin) / count;
    CGFloat textFieldY = self.inputView.cx_height - textFieldW;
    NSInteger i = 0;
    for (UIView *textField in self.inputView.subviews) {
        if ([textField isKindOfClass:[UITextField class]]) {
            CGFloat textFieldX = i * (textFieldW + CXMargin) + CXMargin;
            textField.frame = CGRectMake(textFieldX, textFieldY, textFieldW, textFieldW);
            i++;
        }
    }
}
@end
