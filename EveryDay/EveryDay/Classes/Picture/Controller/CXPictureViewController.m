
//
//  CXPictureViewController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/5.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXPictureViewController.h"
#import <AFNetworking.h>
#import <UIImageView+WebCache.h>
#import "CXLoadingAnimation.h"
#import <SVProgressHUD.h>
#import <Photos/Photos.h>

static NSString * const imageUrl = @"http://open.lovebizhi.com/baidu_rom.php";
static NSString * const imageUrlKey = @"imageUrlKey";

@interface CXPictureViewController ()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, assign,getter=isHideStatus) BOOL hideStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//加载动画
@property (nonatomic, strong) CXLoadingAnimation *animationView;
@end

@implementation CXPictureViewController
#pragma mark - 懒加载
- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (CXLoadingAnimation *)animationView
{
    if (!_animationView) {
        _animationView = [[CXLoadingAnimation alloc] init];
        _animationView.frame = CGRectMake(0, 0, CXScreenW, CXScreenH);
    }
    return _animationView;
}
#pragma mark - 初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];
    //状态栏状态
    self.hideStatus = [UIApplication sharedApplication].statusBarHidden;
    [self loadPictureCategory];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //如果图片为空，才有加载动画
    if (!self.imageView.image) {
        [self setupLoadAnimationToView];
    }
}
/*
 * 隐藏状态栏
 */
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
/*
 * 设置加载动画
 */
- (void)setupLoadAnimationToView
{
    [self.view addSubview:self.animationView];
    [self.view bringSubviewToFront:self.backButton];
}
#pragma mark - 获取数据
- (void)loadPictureCategory
{
    //先从本地加载
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[CXUserDefaults readObjectForKey:imageUrlKey]];
    if (image) {
        self.imageView.image = image;
        //移除加载动画
        [self.animationView removeFromSuperview];
    }
    //网络请求
    [self.manager GET:imageUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *everyday = responseObject[@"everyday"];
        NSString *url = everyday[0][@"image"];
        NSString *newUrl = [url stringByReplacingOccurrencesOfString:@"256,256" withString:[NSString stringWithFormat:@"%.f,%.f", CXScreenW, CXScreenH]];
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:newUrl]];
        [CXUserDefaults setObject:newUrl forKey:imageUrlKey];
        [self removeAnimation];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        CXLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"似乎已断开与网络的链接..."];
        //移除加载动画
        [self removeAnimation];
    }];
}
- (void)removeAnimation
{
    if (self.animationView) {
        [self.animationView removeFromSuperview];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.animationView removeFromSuperview];
        });
    }
}
#pragma mark - 监听事件
/*
 * 返回
 */
- (IBAction)back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 保存图片
- (IBAction)save
{
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
     if (error) {
         if (error.code == -3310) {
             [self remindUserAuthWithTitle:@"相册访问受限" message:@"请前往设置-隐私-照片开启相册访问权限"];
         } else {
             [SVProgressHUD showErrorWithStatus:@"保存失败！"];
         }
     } else {
         [SVProgressHUD showSuccessWithStatus:@"保存成功！"];
     }
}
/*
 * 提醒用户授权
 */
- (void)remindUserAuthWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}
@end
