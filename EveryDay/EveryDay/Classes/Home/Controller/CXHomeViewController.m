//
//  CXHomeViewController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/2.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXHomeViewController.h"
#import <AFNetworking.h>
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import "CXHomeItem.h"
#import <SVProgressHUD.h>
#import "CXBottomView.h"
#import "CXNoteLabel.h"
#import <MJRefresh.h>
#import "UIBarButtonItem+CXBarButtonItem.h"
#import "CXEnglishMonth.h"
#import "CXMineViewController.h"
#import <MaxLeap/MaxLeap.h>

@interface CXHomeViewController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
/** 顶部图片 */
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
/** 月份 */
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
/** 天 */
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
/** 问候语 */
@property (weak, nonatomic) IBOutlet UILabel *helloLabel;
/** 句子内容 */
@property (weak, nonatomic) IBOutlet CXNoteLabel *noteLabel;
@property (nonatomic, weak) NSString *dateStr;
/** 模型对象 */
@property (nonatomic, strong) CXHomeItem *item;
/** 转圈指示器 */
@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) UIView *tmpView;
@property (nonatomic, weak) UIImageView *notInternet;
@property (nonatomic, strong) CXHomeItem *cacheItem;
@end

static NSString *pathKey = @"filePath";

@implementation CXHomeViewController
#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    //添加导航栏按钮
    [self setupNavButton];
    //设置scrollView
    [self setupScrollView];
    //添加底部按钮条
    [self setupBottomView];
    //设置开头加载指示器
    [self setupIndicatorView];
    //获取网络数据
    [self loadData];
    //设置日期
    [self setupDateLabel];
    //设置问候语
    [self setupHelloLabel];
    //应用从后台进入前台就会刷新首页
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:CXAppWillEnterForegroundNotification object:nil];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.indicatorView.center = self.view.center;
    self.notInternet.center = self.view.center;
    self.scrollView.frame = CGRectMake(0, 0, CXScreenW, CXScreenH);
    self.scrollView.contentSize = CGSizeMake(CXScreenW, CXScreenH);
    //设置字体大小
    self.helloLabel.font = [UIFont fontWithName:CXPingFangLight size:22 * KRATE];
    self.dayLabel.font = [UIFont fontWithName:CXPingFangLight size:34 * KRATE];
    self.monthLabel.font = [UIFont fontWithName:CXPingFangLight size:18 * KRATE];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CXAppWillEnterForegroundNotification object:nil];
}
#pragma mark - 设置子控件
/*
 * 设置导航栏-我的按钮
 */
- (void)setupNavButton
{
    UIBarButtonItem *mineItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"mineButton"] highImage:nil target:self action:@selector(mineButtonClick)];
    self.navigationItem.rightBarButtonItem = mineItem;
}
/*
 * 点击进入我的界面
 */
- (void)mineButtonClick
{
    CXMineViewController *mineVc = [[CXMineViewController alloc] init];
    
    [self.navigationController pushViewController:mineVc animated:YES];
}
- (void)setupScrollView
{
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
    self.scrollView.mj_header.automaticallyChangeAlpha = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
}
/*
 * 下拉刷新
 */
- (void)refresh
{
    //获取网络数据
    [self loadDataFromNet];
    //设置日期
    [self setupDateLabel];
    //设置问候语
    [self setupHelloLabel];
}
/*
 * 设置开头加载指示器
 */
- (void)setupIndicatorView
{
    UIView *tmpView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CXScreenW, CXScreenH)];
    tmpView.userInteractionEnabled = YES;
    tmpView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:tmpView];
    [self.view bringSubviewToFront:tmpView];
    self.tmpView = tmpView;
    //转圈指示器
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [indicatorView startAnimating];
    [tmpView addSubview:indicatorView];
    self.indicatorView = indicatorView;
    //点击屏幕重试图片
    UIImageView *notInternet = [[UIImageView alloc] init];
    notInternet.image = [UIImage imageNamed:@"NotConnectedToInternet"];
    [notInternet sizeToFit];
    notInternet.hidden = YES;
    self.notInternet = notInternet;
    [tmpView addSubview:notInternet];
    //点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadData)];
    [tmpView addGestureRecognizer:tap];
}
/*
 * 设置底部的按钮
 */
- (void)setupBottomView
{
    CXBottomView *bottomView = [CXBottomView bottomView];
    CGFloat bottomW = CXScreenW;
    CGFloat bottomH = 36 * KRATE;
    CGFloat bottomY = CXScreenH - bottomH - 20;
    bottomView.frame = CGRectMake(0, bottomY, bottomW, bottomH);
    [self.view addSubview:bottomView];
}
#pragma mark - 设置Label
/*
 * 设置日期
 */
- (void)setupDateLabel
{
    //今天
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [cal components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    //月份
    self.monthLabel.text = [CXEnglishMonth englishMonthWith:cmps.month];
    //天
    self.dayLabel.text = [NSString stringWithFormat:@"%ld", cmps.day];
}
/*
 * 设置问候语
 */
- (void)setupHelloLabel
{
    NSCalendar *calendar = [NSCalendar calendar];
    NSInteger hour = [calendar component:NSCalendarUnitHour fromDate:[NSDate date]];
    if (hour < 12 && hour >= 6) {//早上
        self.helloLabel.text = @"Good morning";
    } else if (hour >= 12 && hour < 18) {//下午
        self.helloLabel.text = @"Good afternoon";
    } else if (hour >= 18 && hour < 22) {//晚上
        self.helloLabel.text = @"Good evening";
    } else if (hour >= 22 || hour < 6) {
        self.helloLabel.text = @"Good night";
    }
    [self.scrollView.mj_header endRefreshing];
}
#pragma mark - 获取网络数据
- (void)loadData
{
    //先从缓存模型对象
    [self loadDataFromCache];
    //网络请求
    [self loadDataFromNet];
}
/*
 * 从本地缓存加载
 */
- (void)loadDataFromCache
{
    NSString *path = [CachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data", [CXUserDefaults readObjectForKey:pathKey]]];
    CXHomeItem *item = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    self.cacheItem = item;
    if (item) {
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:item.picture2]];
        [self loadSuccessWithItem:item];
    }
}
/*
 * 获取网络数据
 */
- (void)loadDataFromNet
{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    [manager GET:@"http://open.iciba.com/dsapi/" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        CXHomeItem *item = [CXHomeItem mj_objectWithKeyValues:responseObject];
        self.item = item;
        if (![item.sid isEqualToString:[CXUserDefaults readObjectForKey:pathKey]] || self.cacheItem == nil) {
            [self.headImageView sd_setImageWithURL:[NSURL URLWithString:item.picture2]];
        }
        [self loadSuccessWithItem:item];
        //保存模型对象到本地
        NSString *filePath = [CachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data", item.sid]];
        [NSKeyedArchiver archiveRootObject:item toFile:filePath];
        [CXUserDefaults setObject:item.sid forKey:pathKey];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        CXLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"似乎已断开与网络的链接..."];
        [self.indicatorView stopAnimating];
        self.notInternet.hidden = NO;
        [self.scrollView.mj_header endRefreshing];
    }];
}
/*
 * 成功获取网络数据
 */
- (void)loadSuccessWithItem:(CXHomeItem *)item
{
    self.noteLabel.text = item.note;
    [self.indicatorView stopAnimating];
    self.tmpView.hidden = YES;
    self.notInternet.hidden = YES;
    [self.scrollView.mj_header endRefreshing];
}
@end
