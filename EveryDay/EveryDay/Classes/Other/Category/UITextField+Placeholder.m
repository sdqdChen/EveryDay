//
//  UITextField+Placeholder.m
//  WeiXinJingXuan
//
//  Created by 陈晓 on 2016/11/12.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import "UITextField+Placeholder.h"
#import <objc/message.h>

@implementation UITextField (Placeholder)
+ (void)load
{
    Method setPlaceholderMethod = class_getInstanceMethod(self, @selector(setPlaceholder:));
    Method setCx_PlaceholderMethod = class_getInstanceMethod(self, @selector(setCx_Placeholder:));
    
    method_exchangeImplementations(setPlaceholderMethod, setCx_PlaceholderMethod);
}
- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    
    objc_setAssociatedObject(self, @"placeholderColor", placeholderColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //设置占位文字颜色
    UILabel *placeholderLabel = [self valueForKey:@"placeholderLabel"];
    placeholderLabel.textColor = placeholderColor;
}
- (UIColor *)placeholderColor
{
    return objc_getAssociatedObject(self, @"placeholderColor");
}
//设置占位文字颜色
- (void)setCx_Placeholder:(NSString *)placeholder
{
    [self setCx_Placeholder:placeholder];
    
    self.placeholderColor = self.placeholderColor;
}
@end
