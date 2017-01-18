//
//  CXNavigationController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/5.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXNavigationController.h"
#import "UIBarButtonItem+CXBarButtonItem.h"
#import "CXMyCollectionViewController.h"
#import "CXHomeViewController.h"

@interface CXNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation CXNavigationController
+(void)load
{
    UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedIn:self, nil];
    //设置导航栏为透明
    [navBar setBackgroundImage:[UIImage new] forBarMetrics:0];
    //解决有一天黑线问题
    navBar.shadowImage = [UIImage new];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:@selector(handleNavigationTransition:)];
    [self.view addGestureRecognizer:pan];
    pan.delegate = self;
    self.interactivePopGestureRecognizer.enabled = YES;
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        //统一设置返回按钮
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithImage:[UIImage imageNamed:@"returnBtn"] highImage:nil target:self action:@selector(back) title:@""];
    }
    if ([viewController isKindOfClass:[CXMyCollectionViewController class]]) {
        viewController.navigationItem.leftBarButtonItem = [UIBarButtonItem backItemWithImage:[UIImage imageNamed:@"returnBtnWhite"] highImage:nil target:self action:@selector(back) title:@""];
    }
    [super pushViewController:viewController animated:animated];
}
- (void)back
{
    [self popViewControllerAnimated:YES];
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self.viewControllers.count > 1;
}
/*
 * 设置状态栏颜色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    if ([self.topViewController isKindOfClass:[CXMyCollectionViewController class]] || [self.topViewController isKindOfClass:[CXHomeViewController class]]) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}
@end
