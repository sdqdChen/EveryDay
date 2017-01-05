//
//  CXArticleViewController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/3.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXArticleViewController.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import "CXLoadingAnimation.h"

static NSString * articleItemidKey = @"articleItemidKey";

@interface CXArticleViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, assign,getter=isHideStatus) BOOL hideStatus;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;
//加载动画
@property (nonatomic, weak) CXLoadingAnimation *animationView;
//本地文章数据
@property (nonatomic, strong) NSDictionary *randomData;
/** 网页是否加载完成 */
@property (nonatomic, assign, getter=isLoadComplete) BOOL loadComplete;
@end

@implementation CXArticleViewController
#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    //加载文章内容
    [self loadArticleData];
    self.webView.delegate = self;
    //状态栏状态
    self.hideStatus = [UIApplication sharedApplication].statusBarHidden;
    //    CXLog(@"%@", NSHomeDirectory());
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
    CXLoadingAnimation *animationView = [[CXLoadingAnimation alloc] init];
    animationView.frame = CGRectMake(0, 0, CXScreenW, CXScreenH);
    [self.view addSubview:animationView];
    self.animationView = animationView;
}
#pragma mark - 获取数据
/*
 * 根据时间判断是否应该更新数据
 */
- (BOOL)isShouldUpdate
{
    NSString *lastUpdateDateStr = [CXUserDefaults readObjectForKey:lastArticleUpdateKey];
    [CXUserDefaults setObject:lastUpdateDateStr forKey:lastArticleUpdateKey];
    //今天
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [cal components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    //把日期保存起来，为了判断是否刷新文章
    NSString *todayDateStr = [NSString stringWithFormat:@"%ld月%ld日", cmps.month, cmps.day];
    [CXUserDefaults setObject:todayDateStr forKey:lastArticleUpdateKey];
    if ([lastUpdateDateStr isEqualToString:todayDateStr]) { //同一天
        return NO;
    } else {
        return YES;
    }
}
/*
 * 加载文章内容
 */
- (void)loadArticleData
{
    BOOL update = [self isShouldUpdate];
    //先从缓存中取数据
    NSString *filePath = [CachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", [CXUserDefaults readObjectForKey:articleItemidKey]]];
    self.randomData = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (self.randomData && !update) {
        //如果本地有数据，并且是同一天，就从本地加载数据
        //拼接HTML
        [self setupHtmlWithDictionary:self.randomData];
    } else if (!self.randomData || update) { //如果本地没有数据或者不是同一天，就从网络加载
        //网络请求
        NSInteger pageIndex = arc4random_uniform(27);//0-26
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        NSString *urlStr = [NSString stringWithFormat:@"http://www.finndy.com/api.php?pagesize=20&pageindex=%ld&datatype=json&sortby=desc&token=1.0_7iiSVVWVgqpyHHHiSVVU766085fd", pageIndex];
        [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            //        [responseObject writeToFile:@"/Users/chenxiao/Desktop/article.plist" atomically:YES];
            //文章的数组
            NSArray *datalistArray = responseObject[@"datalist"];
            NSUInteger count = datalistArray.count;
            NSInteger randomNum = arc4random() % count;
            NSDictionary *random = datalistArray[randomNum];//后面改成随机的
            //把字典保存到本地(根据itemid)
            self.randomData = random;
            NSString *filePath = [CachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", random[@"itemid"]]];
            [random writeToFile:filePath atomically:YES];
            [CXUserDefaults setObject:random[@"itemid"] forKey:articleItemidKey];
            //拼接HTML
            [self setupHtmlWithDictionary:random];
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
}
/*
 * 拼接HTML
 */
- (void)setupHtmlWithDictionary:(NSDictionary *)random
{
    //文章内容
    NSString *mes1 = [NSString stringWithFormat:@"<div id=content>%@</div>", random[@"message"]];
    //文章标题
    NSString *subject = random[@"subject"];
    //把标题中的日期去掉
    NSArray *arr = [self getAStringOfChineseCharacters:subject];
    NSMutableString *newTitle = [NSMutableString string];
    for (NSString *str in arr) {
        [newTitle appendString:str];
    }
    //创建题目标签
    NSString *titleHtml = [NSString stringWithFormat:@"<div id=mainTitle>%@</div>", newTitle];
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
    //拼接<总内容>标签
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
#pragma mark - 处理webView的点击与滑动
/*
 * 向下滑动->隐藏状态栏
 */
- (void)scrollDown
{
    [UIView animateWithDuration:0.25 animations:^{
        self.hideStatus = YES;
        [self setNeedsStatusBarAppearanceUpdate];
        self.bottomToolBar.cx_y = CXScreenH;
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
        self.bottomToolBar.cx_y = CXScreenH - self.bottomToolBar.cx_height;
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
            self.bottomToolBar.cx_y = CXScreenH;
        } else {
            self.bottomToolBar.cx_y = CXScreenH - self.bottomToolBar.cx_height;
        }
    }];
}
#pragma mark - 监听事件
/*
 * 收藏
 */
- (IBAction)collect:(UIBarButtonItem *)sender {
    
}

/*
 * 分享
 */
- (IBAction)share{
    
}
/*
 * 返回
 */
- (IBAction)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
 * 设置状态栏
 */
- (BOOL)prefersStatusBarHidden
{
    return self.hideStatus;
}
/*
 * 取出字符串中的汉字
 */
- (NSArray *)getAStringOfChineseCharacters:(NSString *)string
{
    if (string == nil || [string isEqual:@""])
    {
        return nil;
    }
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    for (int i=0; i<string.length; i++)
    {
        NSRange range = NSMakeRange(i, 1);
        NSString *subStr = [string substringWithRange:range];
        const char *c = [subStr UTF8String];
        if (strlen(c)==3)
        {
            [arr addObject:subStr];
        }
    }
    return arr;
}
@end
