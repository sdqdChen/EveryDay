
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

static NSString * const pictureUrl = @"http://open.lovebizhi.com/baidu_rom.php";
static NSString * const imageUrlKey = @"imageUrlKey";

@interface CXPictureViewController ()
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (nonatomic, assign,getter=isHideStatus) BOOL hideStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
//加载动画
@property (nonatomic, weak) CXLoadingAnimation *animationView;
@end

@implementation CXPictureViewController
#pragma mark - 初始化设置
- (void)viewDidLoad {
    [super viewDidLoad];
    //状态栏状态
    self.hideStatus = [UIApplication sharedApplication].statusBarHidden;
    [self loadPictureData];
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
 * 设置状态栏为白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
/*
 * 设置加载动画
 */
- (void)setupLoadAnimationToView
{
    CXLoadingAnimation *animationView = [[CXLoadingAnimation alloc] init];
    animationView.frame = CGRectMake(0, 0, CXScreenW, CXScreenH);
    [self.view addSubview:animationView];
    self.animationView = animationView;
}
#pragma mark - 获取数据
- (void)loadPictureData
{
    //先从本地加载
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[CXUserDefaults readObjectForKey:imageUrlKey]];
    if (image) {
        self.imageView.image = image;
        //移除加载动画
        [self.animationView removeFromSuperview];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //网络请求
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        [manager GET:pictureUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary *data = responseObject[@"everyday"][0];
            NSString *imageOriginUrl = data[@"image"];
            NSString *sizeStr = [NSString stringWithFormat:@"%.f,%.f", CXScreenW, CXScreenH];
            //根据设备分辨率加载图片
            NSString *newImageUrl = [imageOriginUrl stringByReplacingOccurrencesOfString:@"256,256" withString:sizeStr];
            [self.imageView sd_setImageWithURL:[NSURL URLWithString:newImageUrl]];
            [CXUserDefaults setObject:newImageUrl forKey:imageUrlKey];
            //移除加载动画
            [self.animationView removeFromSuperview];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            CXLog(@"%@", error);
            [SVProgressHUD showErrorWithStatus:@"似乎已断开与网络的链接..."];
            //移除加载动画
            [self.animationView removeFromSuperview];
        }];
    });
}
#pragma mark - 监听事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.25 animations:^{
        self.hideStatus = !self.hideStatus;
        [self setNeedsStatusBarAppearanceUpdate];//调用该方法后系统会调用prefersStatusBarHidden方法
        self.backButton.hidden = !self.backButton.hidden;
        self.saveButton.hidden = !self.saveButton.hidden;
    }];
}
/*
 * 设置状态栏
 */
- (BOOL)prefersStatusBarHidden
{
    return self.hideStatus;
}
/*
 * 返回
 */
- (IBAction)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save {
    
}
@end
