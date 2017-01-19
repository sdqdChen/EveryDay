//
//  CXCollectWebViewController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/18.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXCollectWebViewController.h"
#import "CXCollectionItem.h"
#import "CXLoadingAnimation.h"

@interface CXCollectWebViewController () <UIWebViewDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
/** 状态栏隐藏状态 */
@property (nonatomic, assign,getter=isHideStatus) BOOL hideStatus;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
/** 加载动画 */
@property (nonatomic, strong) CXLoadingAnimation *animationView;
/** 网页是否加载完成 */
@property (nonatomic, assign, getter=isLoadComplete) BOOL loadComplete;

@end

@implementation CXCollectWebViewController

- (CXLoadingAnimation *)animationView
{
    if (!_animationView) {
        _animationView = [[CXLoadingAnimation alloc] init];
        _animationView.frame = CGRectMake(0, 0, CXScreenW, CXScreenH);
    }
    return _animationView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    self.navigationController.delegate = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    //状态栏状态
    self.hideStatus = [UIApplication sharedApplication].statusBarHidden;
    if ([self.item.type isEqualToString:@"文章"]) {
        [self setupArticleHtml];
    } else {
        [self setupPoemHtml];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isLoadComplete == NO) {
        [self setupLoadAnimationToView];
    }
}
- (void)setupLoadAnimationToView
{
    [self.view addSubview:self.animationView];
    [self.view bringSubviewToFront:self.bottomView];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}
- (void)setupPoemHtml
{
    //内容标签
    NSString *mes = self.item.content;
    //标题标签
    NSString *titleHtml = [NSString stringWithFormat:@"<div id=mainTitle>%@</div>", self.item.title];
    //作者标签
    NSString *authorHtml = [NSString stringWithFormat:@"<div id=author>%@</div>", self.item.author];
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
}
- (void)setupArticleHtml
{
    //文章内容
    NSString *mes1 = [NSString stringWithFormat:@"<div id=content>%@</div>", self.item.content];
    //创建题目标签
    NSString *titleHtml = [NSString stringWithFormat:@"<div id=mainTitle>%@</div>", self.item.title];
    //加载cssURL路径
    NSURL *cssUrl = [[NSBundle mainBundle] URLForResource:@"article.css" withExtension:nil];
    //引入css，创建link标签
    NSString *cssLink = [NSString stringWithFormat:@"<link href=%@ rel=stylesheet>", cssUrl];
    //加载js路径
    NSURL *jsUrl = [[NSBundle mainBundle] URLForResource:@"article.js" withExtension:nil];
    //引入js
    NSString *jsHtml = [NSString stringWithFormat:@"<script src=%@></script>", jsUrl];
    //结尾：（完）标签
    NSString *end = [NSString stringWithFormat:@"<div id=end>（完）</div>"];
    NSString *html = [NSString stringWithFormat:@"<html><head>%@</head><body><div id=all>%@%@%@%@</div></body></html>", cssLink, titleHtml, mes1,end, jsHtml];
    [self.webView loadHTMLString:html baseURL:nil];
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
#pragma mark - 处理webView的滑动
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
#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // 判断要显示的控制器是否是自己
    BOOL isShowHomePage = [viewController isKindOfClass:[self class]];
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:isShowHomePage animated:YES];
}
- (IBAction)back {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
