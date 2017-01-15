//
//  UIImage+CXImage.h
//  WeiXinJingXuan
//
//  Created by 陈晓 on 2016/11/4.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CXImage)
/*
 * 返回不被渲染的图片
 */
+ (UIImage *)imageOriginalWithName:(NSString *)name;
/*
 * 返回裁剪的圆形图片
 */
+ (UIImage *)imageCircledWithimage:(UIImage *)image;
/*
 * 返回一张带有圆环的圆形图片 
 */
+ (UIImage *)imageWithClipImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color;
/*
 * 压缩图片到一定的尺寸
 */
+ (UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size;
@end
