//
//  CXLoginRegisterViewController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/13.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXLoginRegisterViewController.h"
#import "CXPhoneNumberView.h"
#import "CXUserDefaults.h"

@interface CXLoginRegisterViewController ()
/** 中间的view */
@property (weak, nonatomic) IBOutlet UIView *middleView;
/** 需要切换的view */
@property (weak, nonatomic) IBOutlet UIView *switchView;
@property (nonatomic, strong) CXPhoneNumberView *numberView;
@end

@implementation CXLoginRegisterViewController
#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    CXPhoneNumberView *numberView = [CXPhoneNumberView loadPhoneNumFromXib];
    [self.switchView addSubview:numberView];
    [self addNotification];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CXPhoneNumberView *numberView = self.switchView.subviews[0];
    self.numberView = numberView;
    numberView.frame = self.switchView.bounds;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if ([CXUserDefaults readBoolForKey:LoginSuccess]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CXLoginSuccessNotification object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"invalidateTimer" object:nil];
    }
}
/*
 * 点击屏幕，键盘退出
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.35 animations:^{
        [self.view endEditing:YES];
    }];
}
#pragma mark - 通知
- (void)addNotification
{
    //监听键盘弹出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchViewMoveUp:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchViewMoveDown:) name:UIKeyboardWillHideNotification object:nil];
}
/*
 * 移除通知
 */
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - 监听事件
/*
 * view上移
 */
- (void)switchViewMoveUp:(NSNotification *)obj
{
    CGRect keyboardFrame = [obj.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (keyboardFrame.origin.y < self.view.cx_height) { //键盘要上移
        [UIView animateWithDuration:0.25 animations:^{
            self.middleView.transform = CGAffineTransformMakeTranslation(0, -30);
        }];
    }
}
/*
 * view下移
 */
- (void)switchViewMoveDown:(NSNotification *)obj
{
    [UIView animateWithDuration:0.25 animations:^{
        self.middleView.transform = CGAffineTransformIdentity;
    }];
}
/*
 * 退出
 */
- (IBAction)close {
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
