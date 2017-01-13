//
//  CXNumberTextField.m
//  WeiXinJingXuan
//
//  Created by 陈晓 on 2016/12/12.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import "CXNumberTextField.h"

@implementation CXNumberTextField
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.borderStyle = UITextBorderStyleRoundedRect;
    self.keyboardType = UIKeyboardTypeNumberPad;
    self.tintColor = [UIColor blackColor];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.borderStyle = UITextBorderStyleRoundedRect;
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.tintColor = [UIColor blackColor];
    }
    return self;
}

- (void)deleteBackward
{
    [super deleteBackward];
    
    if ([self.cx_delegate respondsToSelector:@selector(CXNumberTextFieldDelete:)]) {
        [self.cx_delegate CXNumberTextFieldDelete:self];
    }
}
//修改编辑区域(可以改变光标起始位置，以及光标最右到什么地方，placeholder的位置也会改变)
//但是数字固定死了
- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect insert = CGRectMake(21, bounds.origin.y, bounds.size.width, bounds.size.height);
    return insert;
}
//修改文本展示区域
-(CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect insert = CGRectMake(18, bounds.origin.y, bounds.size.width, bounds.size.height);
    return insert;
}
@end
