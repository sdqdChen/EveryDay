//
//  CXLoadingAnimation.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/4.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXLoadingAnimation.h"

@implementation CXLoadingAnimation
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self creatAnimation];
    }
    return self;
}
- (void)creatAnimation
{
    //背景
    CAReplicatorLayer *replicatorLayer = [CAReplicatorLayer layer];
    replicatorLayer.bounds = CGRectMake(0, 0, 80, 100);
    replicatorLayer.position = CGPointMake(CXScreenW * 0.5, CXScreenH * 0.5);
    [self.layer addSublayer:replicatorLayer];
    //添加一个点
    CALayer *dotLayer = [CALayer layer];
    dotLayer.bounds = CGRectMake(0, 0, 12, 12);
    dotLayer.position = CGPointMake(15, replicatorLayer.frame.size.height/2);
    dotLayer.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8].CGColor;
    dotLayer.cornerRadius = 7.5;
    [replicatorLayer addSublayer:dotLayer];
    //设置3个点
    replicatorLayer.instanceCount = 3;
    replicatorLayer.instanceTransform = CATransform3DMakeTranslation(replicatorLayer.frame.size.width/3, 0, 0);
    //添加动画
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.duration = 1;
    animation.fromValue = @1;
    animation.toValue = @0;
    animation.repeatCount = MAXFLOAT;
    [dotLayer addAnimation:animation forKey:nil];
    replicatorLayer.instanceDelay = 1.0/3;
    dotLayer.transform = CATransform3DMakeScale(0, 0, 0);
}
@end
