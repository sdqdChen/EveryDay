//
//  UIView+CXExtension.m
//
//  Created by 陈晓 on 16/7/16.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import "UIView+CXExtension.h"

@implementation UIView (CXExtension)
- (CGFloat)cx_width
{
    return self.frame.size.width;
}

- (CGFloat)cx_height
{
    return self.frame.size.height;
}

- (void)setCx_width:(CGFloat)cx_width
{
    CGRect frame = self.frame;
    frame.size.width = cx_width;
    self.frame = frame;
}

- (void)setCx_height:(CGFloat)cx_height
{
    CGRect frame = self.frame;
    frame.size.height = cx_height;
    self.frame = frame;
}

- (CGFloat)cx_x
{
    return self.frame.origin.x;
}

- (void)setCx_x:(CGFloat)cx_x
{
    CGRect frame = self.frame;
    frame.origin.x = cx_x;
    self.frame = frame;
}

- (CGFloat)cx_y
{
    return self.frame.origin.y;
}

- (void)setCx_y:(CGFloat)cx_y
{
    CGRect frame = self.frame;
    frame.origin.y = cx_y;
    self.frame = frame;
}

- (CGFloat)cx_centerX
{
    return self.center.x;
}

- (void)setCx_centerX:(CGFloat)cx_centerX
{
    CGPoint center = self.center;
    center.x = cx_centerX;
    self.center = center;
}

- (CGFloat)cx_centerY
{
    return self.center.y;
}

- (void)setCx_centerY:(CGFloat)cx_centerY
{
    CGPoint center = self.center;
    center.y = cx_centerY;
    self.center = center;
}

- (CGFloat)cx_right
{
    //    return self.cx_x + self.cx_width;
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)cx_bottom
{
    //    return self.cx_y + self.cx_height;
    return CGRectGetMaxY(self.frame);
}

- (void)setCx_right:(CGFloat)cx_right
{
    self.cx_x = cx_right - self.cx_width;
}

- (void)setCx_bottom:(CGFloat)cx_bottom
{
    self.cx_y = cx_bottom - self.cx_height;
}

@end
