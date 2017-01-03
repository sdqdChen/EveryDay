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
#import "CXUserDefaults.h"
#import "CXBottomView.h"

@interface CXHomeViewController ()
/** 顶部图片 */
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
/** 时间 */
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
/** 问候语 */
@property (weak, nonatomic) IBOutlet UILabel *helloLabel;
/** 句子内容 */
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (nonatomic, weak) NSString *dateStr;
/** 模型对象 */
@property (nonatomic, strong) CXHomeItem *item;
/** 转圈指示器 */
@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;
@property (nonatomic, weak) UIView *tmpView;
@property (nonatomic, weak) UIImageView *notInternet;
@end

static NSString *pathKey = @"filePath";

@implementation CXHomeViewController
#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
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
    //设置句子
    [self setupNoteLabel];
    //    CXLog(@"%@", NSHomeDirectory());
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.indicatorView.center = self.view.center;
    self.notInternet.center = self.view.center;
}
/*
 * 设置状态栏为白色
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
#pragma mark - 添加控件
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
    CGFloat bottomH = 44;
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
    NSDateFormatter *fom = [[NSDateFormatter alloc] init];
    fom.dateFormat = @"MM.dd";
    NSDate *date = [NSDate date];
    NSString *dateStr = [fom stringFromDate:date];
    self.dateStr = dateStr;
    self.dateLabel.text = dateStr;
    self.dateLabel.font = [UIFont fontWithName:@"Hiragino Sans" size:40];
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
    self.helloLabel.font = [UIFont fontWithName:@"Futura" size:18];
}
/*
 * 设置句子
 */
- (void)setupNoteLabel
{
    self.noteLabel.font = [UIFont fontWithName:@"PingFang SC" size:18];
}
#pragma mark - 获取网络数据
- (void)loadData
{
    //先从缓存模型对象
    NSString *path = [CachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.data", [CXUserDefaults readObjectForKey:pathKey]]];
    CXHomeItem *item = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (item) {
        [self loadSuccessWithItem:item];
    }
    //网络请求
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    [manager GET:@"http://open.iciba.com/dsapi/" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        CXHomeItem *item = [CXHomeItem mj_objectWithKeyValues:responseObject];
        self.item = item;
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
    }];
}
- (void)loadSuccessWithItem:(CXHomeItem *)item
{
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:item.picture2]];
    self.noteLabel.text = item.note;
    [self.indicatorView stopAnimating];
    self.tmpView.hidden = YES;
    self.notInternet.hidden = YES;
}
@end
