//
//  CXPoemViewController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/5.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXPoemViewController.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import "CXLoadingAnimation.h"
#import <MaxLeap/MaxLeap.h>
#import "CXWebViewScreenShot.h"
#import "CXUMSocial.h"
#import "CXLoginRegisterViewController.h"

static NSString * poemItemidKey = @"poemItemidKey";
static NSString * poemNumberKey = @"poemNumberKey";

@interface CXPoemViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, assign,getter=isHideStatus) BOOL hideStatus;
/** 加载动画 */
@property (nonatomic, strong) CXLoadingAnimation *animationView;
/** 本地文章数据 */
@property (nonatomic, strong) NSDictionary *randomData;
/** 网页是否加载完成 */
@property (nonatomic, assign, getter=isLoadComplete) BOOL loadComplete;
/** 底部条 */
@property (weak, nonatomic) IBOutlet UIView *bottomView;
/** 收藏按钮 */
@property (weak, nonatomic) IBOutlet UIButton *collectButton;
/** 当前用户 */
@property (nonatomic, strong) MLUser *user;
/** 诗的标题 */
@property (nonatomic, copy) NSString *poemTitle;
/** 诗的作者 */
@property (nonatomic, copy) NSString *author;
/** 整首诗 */
@property (nonatomic, copy) NSString *content;
/** 诗的ID */
@property (nonatomic, copy) NSString *itemid;
@end

@implementation CXPoemViewController
#pragma mark - 懒加载
- (MLUser *)user
{
    if (!_user) {
        _user = [MLUser currentUser];
    }
    return _user;
}
- (CXLoadingAnimation *)animationView
{
    if (!_animationView) {
        _animationView = [[CXLoadingAnimation alloc] init];
        _animationView.frame = CGRectMake(0, 0, CXScreenW, CXScreenH);
    }
    return _animationView;
}
#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载诗的内容
    [self loadPoemData];
    self.webView.delegate = self;
    self.hideStatus = [UIApplication sharedApplication].statusBarHidden;
    [self.view bringSubviewToFront:self.bottomView];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isLoadComplete == NO) {
        [self setupLoadAnimationToView];
    }
}
/*
 * 设置加载动画
 */
- (void)setupLoadAnimationToView
{
    [self.view addSubview:self.animationView];
    [self.view bringSubviewToFront:self.bottomView];
}
#pragma mark - 获取数据
/*
 * 根据时间判断是否应该更新数据
 */
- (BOOL)isShouldUpdate
{
    NSString *lastUpdateDateStr = [CXUserDefaults readObjectForKey:lastPoemUpdateKey];
    [CXUserDefaults setObject:lastUpdateDateStr forKey:lastPoemUpdateKey];
    //今天
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [cal components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    //把日期保存起来，为了判断是否刷新文章
    NSString *todayDateStr = [NSString stringWithFormat:@"%ld月%ld日", cmps.month, cmps.day];
    [CXUserDefaults setObject:todayDateStr forKey:lastPoemUpdateKey];
    if ([lastUpdateDateStr isEqualToString:todayDateStr]) { //同一天
        return NO;
    } else {
        return YES;
    }
}
/*
 * 加载诗的内容
 */
- (void)loadPoemData
{
    BOOL update = [self isShouldUpdate];
    //先从缓存中取数据
    NSString *filePath = [CachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [CXUserDefaults readObjectForKey:poemItemidKey]]];
    self.randomData = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (self.randomData && !update) {
        //如果本地有数据，并且是同一天，就从本地加载数据
        //拼接HTML
        [self setupHtmlWithDictionary:self.randomData];
        //判断该文章是否已经被收藏
        [self isCollectedOrNot];
    } else if (update) {//如果不是同一天，就从网络随机加载
        //网络请求
        [self loadDataWithPageIndex:arc4random_uniform(52) randomNum:arc4random_uniform(20)];
    } else if (!self.randomData && !update) { //如果本地没有数据，但是是同一天，从网络加载当天的数据
        NSString *articleNumber = [CXUserDefaults readObjectForKey:poemNumberKey];
        NSArray *array = [articleNumber componentsSeparatedByString:@":"];
        NSString *pageIndex = array[0];
        NSString *randomNum = array[1];
        [self loadDataWithPageIndex:[pageIndex integerValue] randomNum:[randomNum integerValue]];
    }
}
- (void)loadDataWithPageIndex:(NSInteger)pageIndex randomNum:(NSInteger)randomNum
{
    //网络请求
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *poemUrl = [NSString stringWithFormat:@"http://www.finndy.com/api.php?pagesize=20&pageindex=%ld&datatype=json&sortby=desc&token=1.0_7xiSVVWgqVfmHiyVVgjgf7b05672", pageIndex];
    [manager GET:poemUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *datalistArray = responseObject[@"datalist"];
        //获取随机文章
        NSDictionary *random = datalistArray[randomNum];
        self.randomData = random;
        //把字典保存到本地(根据itemid)
        NSString *filePath = [CachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", random[@"itemid"]]];
        [random writeToFile:filePath atomically:YES];
        [CXUserDefaults setObject:random[@"itemid"] forKey:poemItemidKey];
        //拼接HTML
        [self setupHtmlWithDictionary:random];
        //把哪一页哪一篇文章记录下来
        NSString *articleNumber = [NSString stringWithFormat:@"%ld:%ld", pageIndex, randomNum];
        [CXUserDefaults setObject:articleNumber forKey:poemNumberKey];
        //判断该文章是否已经被收藏
        [self isCollectedOrNot];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        CXLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"似乎已断开与网络的链接..."];
        //移除加载动画
        if (self.animationView) {
            [self.animationView removeFromSuperview];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.animationView removeFromSuperview];
            });
        }
    }];
}
/*
 * 拼接HTML
 */
- (void)setupHtmlWithDictionary:(NSDictionary *)random
{
    //内容标签
    NSString *mes = random[@"message"];
    //标题标签
    NSString *titleHtml = [NSString stringWithFormat:@"<div id=mainTitle>%@</div>", random[@"subject"]];
    //作者标签
    NSString *authorHtml = [NSString stringWithFormat:@"<div id=author>%@</div>", random[@"extfield1"]];
    
    //加载cssURL路径
    NSURL *cssUrl = [[NSBundle mainBundle] URLForResource:@"poem.css" withExtension:nil];
    //引入css，创建link标签
    NSString *cssLink = [NSString stringWithFormat:@"<link href=%@ rel=stylesheet>", cssUrl];
    //加载js路径
    NSURL *jsUrl = [[NSBundle mainBundle] URLForResource:@"poem.js" withExtension:nil];
    //引入js
    NSString *jsHtml = [NSString stringWithFormat:@"<script src=%@></script>", jsUrl];
    
    //结尾：（完）标签
    NSString *end = [NSString stringWithFormat:@"<div id=end>（完）</div>"];
    
    //拼接<总内容>标签
    NSString *html = [NSString stringWithFormat:@"<html><head>%@</head><body><div id=all>%@%@%@%@%@</div></body></html>", cssLink, titleHtml, authorHtml, mes, end, jsHtml];
    [self.webView loadHTMLString:html baseURL:nil];
    //为了保存诗的相关信息
    self.itemid = random[@"itemid"];
    self.poemTitle = random[@"subject"];
    self.author = random[@"extfield1"];
    self.content = mes;
}
#pragma mark - webView代理方法
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self testRequest:request header:@"cx:"];
    [self testRequest:request header:@"down:"];
    [self testRequest:request header:@"up:"];
    return YES;
}
- (void)testRequest:(NSURLRequest *)request header:(NSString *)header
{
    //request->字符串
    NSString *requestStr = [[request URL] absoluteString];
    NSString *urlHeader = header;
    NSRange range = [requestStr rangeOfString:urlHeader];
    if (range.location != NSNotFound) {
        NSString *method = [requestStr substringFromIndex:range.length];
        SEL selector = NSSelectorFromString(method);
        [self performSelector:selector];
    }
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.loadComplete = YES;
    //移除加载动画
    [self.animationView removeFromSuperview];
}
#pragma mark - 处理webView的点击与滑动
/*
 * 向下滑动->隐藏状态栏
 */
- (void)scrollDown
{
    [UIView animateWithDuration:0.25 animations:^{
        self.hideStatus = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        self.bottomView.cx_y = CXScreenH;
    }];
}
/*
 * 向上滑动->显示状态栏
 */
- (void)scrollUp
{
    [UIView animateWithDuration:0.25 animations:^{
        self.hideStatus = NO;
        [self setNeedsStatusBarAppearanceUpdate];
        self.bottomView.cx_y = CXScreenH - self.bottomView.cx_height;
    }];
}
/*
 * 点击webView->显示/隐藏状态栏；隐藏底部
 */
- (void)clickWebView
{
    [UIView animateWithDuration:0.25 animations:^{
        self.hideStatus = !self.hideStatus;
        [self setNeedsStatusBarAppearanceUpdate];//调用该方法后系统会调用prefersStatusBarHidden方法
        if (self.hideStatus) {
            self.bottomView.cx_y = CXScreenH;
        } else {
            self.bottomView.cx_y = CXScreenH - self.bottomView.cx_height;
        }
    }];
}
/*
 * 设置状态栏
 */
- (BOOL)prefersStatusBarHidden
{
    return self.hideStatus;
}
#pragma mark - 返回
- (IBAction)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 收藏
- (IBAction)collect:(UIButton *)button {
    //未登录就去登录界面
    if ([CXUserDefaults readBoolForKey:LoginSuccess]) { //已登录
        if (!button.selected) {
            [self addCollectionWithButton:button];
        } else {
            [self cancelCollectionWithButton:button];
        }
    } else { //未登录
        CXLoginRegisterViewController *loginVc = [[CXLoginRegisterViewController alloc] init];
        [self presentViewController:loginVc animated:YES completion:nil];
    }
}
/*
 * 添加收藏
 */
- (void)addCollectionWithButton:(UIButton *)button
{
    NSDictionary *articleDic = @{@"author" : self.author,
                                 @"title" : self.poemTitle,
                                 @"content" : self.content,
                                 @"type" : @"诗歌",
                                 @"itemid" : self.itemid};
    NSMutableArray *array = self.user[@"collection"];
    [array addObject:articleDic];
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"收藏失败，请稍后再试"];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"收藏成功"];
            button.selected = YES;
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}
/*
 * 取消收藏
 */
- (void)cancelCollectionWithButton:(UIButton *)button
{
    NSMutableArray *array = self.user[@"collection"];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        if ([dic[@"itemid"] isEqualToString:self.itemid]) {
            [array removeObject:dic];
        }
    }];
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"取消失败，请稍后再试"];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"已取消收藏"];
            button.selected = NO;
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}
/*
 * 该文章是否被收藏
 */
- (void)isCollectedOrNot
{
    NSMutableArray *array = self.user[@"collection"];
    for (NSDictionary *dic in array) {
        if ([dic[@"itemid"] isEqualToString:self.itemid]) {
            //如果有一样的id，说明已经添加过
            self.collectButton.selected = YES;
        }
    }
}
#pragma mark - 分享
- (IBAction)share{
    UIImage *image = [CXWebViewScreenShot screenShotWithWebView:self.webView];
    [[CXUMSocial defaultSocialManager] shareImageWithImage:image completion:nil];
}

@end
