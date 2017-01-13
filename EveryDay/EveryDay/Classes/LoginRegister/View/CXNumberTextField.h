//
//  CXNumberTextField.h
//  WeiXinJingXuan
//
//  Created by 陈晓 on 2016/12/12.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CXNumberTextField;

@protocol CXNumberTextFieldDelegate <NSObject>

- (void)CXNumberTextFieldDelete:(CXNumberTextField *)textField;

@end

@interface CXNumberTextField : UITextField

@property (nonatomic, assign) id <CXNumberTextFieldDelegate> cx_delegate;

@property (nonatomic, assign) CGFloat textX;

@end
