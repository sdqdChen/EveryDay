//
//  CXVerificationCodeView.h
//  WeiXinJingXuan
//
//  Created by 陈晓 on 2016/12/13.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CXNumberTextField.h"


@interface CXVerificationCodeView : UIView
+ (instancetype)loadVerificationCodeView;
//第一个文本框
@property (nonatomic, strong) CXNumberTextField *firstTextField;
//手机号
@property (nonatomic, copy) NSString *phoneNumber;
//是否登录成功
//@property (nonatomic, assign, getter=isLoginSuccess) BOOL loginSuccess;
@end
