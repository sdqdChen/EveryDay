//
//  UIImage+CXImage.m
//  WeiXinJingXuan
//
//  Created by 陈晓 on 2016/11/4.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import "UIImage+CXImage.h"

@implementation UIImage (CXImage)
+ (UIImage *)imageOriginalWithName:(NSString *)name
{
    UIImage *imageOriginal = [UIImage imageNamed:name];
    return [imageOriginal imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}
+ (UIImage *)imageCircledWithimage:(UIImage *)image
{
//    //1.开启图形上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    //2.描述裁剪区域
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    //3.进行裁剪
    [path addClip];
    //4.画图片
    [image drawAtPoint:CGPointZero];
    //5.取出图片
    image = UIGraphicsGetImageFromCurrentImageContext();
    //6.关闭上下文
    UIGraphicsEndImageContext();
    return image;
}
+ (UIImage *)imageWithClipImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color
{
    // 设置外面大圆的size，它应该与传入图片的大小一致
    CGSize ovalSize = CGSizeMake(image.size.width + 2 * borderWidth, image.size.height + 2 * borderWidth);
    
    // 开启一个跟原始图片一样大的图形上下文
    UIGraphicsBeginImageContextWithOptions(ovalSize, NO, 0);
    
    // 处理大圆
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, ovalSize.width, ovalSize.height)];  // 描述大圆的路径
    [color set];  // 设置大圆的颜色
    [path fill];  // 填充整个大圆
    
    // 处理圆形图片
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(borderWidth, borderWidth, image.size.width, image.size.height)];  // 描述小圆的路径
    [clipPath addClip];  // 将超出小圆的部分图片给裁剪掉
    
    // 将圆形图片绘制到图形上下文
    [image drawAtPoint:CGPointMake(borderWidth, borderWidth)];
    
    // 从图形上下文中获取带有圆环的图片
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭图形上下文
    UIGraphicsEndImageContext();
    
    // 返回一张带有圆环的圆形图片
    return clipImage;
}
+ (UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size
{
    //创建一个bitmap的context
    //并把他设置成当前的context
    UIGraphicsBeginImageContext(size);
    //绘制图片的大小
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //从当前context中创建一个改变大小后的图片
    UIImage *endImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return endImage;
}
@end
