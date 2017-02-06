//
//  CXHomeViewController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/2/5.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXHomeViewController.h"
#import <UIImageView+WebCache.h>
#import "CXMineViewController.h"
#import "UIBarButtonItem+CXBarButtonItem.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import "CXEnglishMonth.h"
#import "CXNoteLabel.h"
#import "CXLeftView.h"
#import "CXUserDefaults.h"

@interface CXHomeViewController ()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
/** 背景图 */
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
/** 整个view的左约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftContraint;
/** 整个view的右约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightContraint;
/** 句子 */
@property (weak, nonatomic) IBOutlet CXNoteLabel *noteLabel;
/** 月份 */
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
/** 天 */
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
/** 侧边栏 */
@property (nonatomic, strong) CXLeftView *leftView;
@end

static NSInteger const leftWidth = 130;
static NSString * const noteLabelKey = @"noteLabelKey";

@implementation CXHomeViewController
#pragma mark - 懒加载
- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}
- (CXLeftView *)leftView
{
    if (!_leftView) {
        _leftView = [[CXLeftView alloc] init];
        _leftView.frame = CGRectMake(-leftWidth, 0, leftWidth, CXScreenH);
    }
    return _leftView;
}
#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    //添加导航栏按钮
    [self setupNavButton];
    //设置背景图片
    [self setupBgImageView];
    //设置句子
    [self setupNoteLabel];
    //设置日期
    [self setupDateLabel];
    //应用从后台进入前台就会刷新首页
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:CXAppWillEnterForegroundNotification object:nil];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.dayLabel.font = [UIFont fontWithName:CXPingFangLight size:50 * KRATE];
    self.monthLabel.font = [UIFont fontWithName:CXPingFangLight size:34 * KRATE];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CXAppWillEnterForegroundNotification object:nil];
}
#pragma mark - 设置导航栏按钮
- (void)setupNavButton
{
    //我的按钮
    UIBarButtonItem *mineItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"mineButton"] highImage:nil target:self action:@selector(mineButtonClick)];
    self.navigationItem.rightBarButtonItem = mineItem;
    //更多按钮
    UIBarButtonItem *moreItem = [UIBarButtonItem itemWithImage:[UIImage imageNamed:@"more"] highImage:nil target:self action:@selector(moreButtonClick)];
    self.navigationItem.leftBarButtonItem = moreItem;
}
#pragma mark - 监听事件
- (void)refresh
{
    //设置背景图片
    [self setupBgImageView];
    //设置句子
    [self setupNoteLabel];
    //设置日期
    [self setupDateLabel];
}
/*
 * 点击进入我的界面
 */
- (void)mineButtonClick
{
    CXMineViewController *mineVc = [[CXMineViewController alloc] init];
    [self.navigationController pushViewController:mineVc animated:YES];
}
/*
 * 点击出现侧边栏
 */
- (void)moreButtonClick
{
    //显示侧滑栏
    [self.view addSubview:self.leftView];
    //view右移
    [UIView animateWithDuration:0.3 animations:^{
        CGRect navFrame = self.navigationController.navigationBar.frame;
        CGRect leftFrame = self.leftView.frame;
        if (self.leftContraint.constant == 0) { //右移
            self.leftContraint.constant = leftWidth;
            self.rightContraint.constant = -leftWidth;
            [self.view layoutIfNeeded];
            
            leftFrame.origin.x = 0;
            self.leftView.frame = leftFrame;
            
            navFrame.origin.x += leftWidth;
            self.navigationController.navigationBar.frame = navFrame;
        } else { //恢复
            self.leftContraint.constant = 0;
            self.rightContraint.constant = 0;
            [self.view layoutIfNeeded];
            
            leftFrame.origin.x = -leftWidth;
            self.leftView.frame = leftFrame;
            
            navFrame.origin.x -= leftWidth;
            self.navigationController.navigationBar.frame = navFrame;
        }
    }];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.leftContraint.constant != 0) {
        [self moreButtonClick];
    }
}
#pragma mark - 设置背景图片
/*
 * 根据时间判断是否应该更新数据
 */
- (BOOL)isShouldUpdate
{
    NSString *lastUpdateDateStr = [CXUserDefaults readObjectForKey:lastPictureUpdateKey];
    [CXUserDefaults setObject:lastUpdateDateStr forKey:lastPictureUpdateKey];
    //今天
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [cal components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    //把日期保存起来，为了判断是否刷新文章
    NSString *todayDateStr = [NSString stringWithFormat:@"%ld月%ld日", (long)cmps.month, (long)cmps.day];
    [CXUserDefaults setObject:todayDateStr forKey:lastPictureUpdateKey];
    if ([lastUpdateDateStr isEqualToString:todayDateStr]) { //同一天
        return NO;
    } else {
        return YES;
    }
}
- (void)setupBgImageView
{
    BOOL update = [self isShouldUpdate];
    NSString *imageURL = [NSString stringWithFormat:@"https://unsplash.it/%f/%f/?random", CXScreenW, CXScreenH];
    if (update) { //需要更新
        [[SDImageCache sharedImageCache] removeImageForKey:imageURL withCompletion:nil];
        [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
    } else {
        UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageURL];
        if (image) {
            self.bgImageView.image = image;
        } else {
            [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
        }
    }
    [self addGestureToImageView];
}
/*
 * 添加手势
 */
- (void)addGestureToImageView
{
    //添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toLeft)];
    self.bgImageView.userInteractionEnabled = YES;
    [self.bgImageView addGestureRecognizer:tap];
    //向右滑动
    UISwipeGestureRecognizer *right = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toLeft)];
    right.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.bgImageView addGestureRecognizer:right];
    //向左滑动
    UISwipeGestureRecognizer *left = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toRight)];
    left.direction = UISwipeGestureRecognizerDirectionRight;
    [self.bgImageView addGestureRecognizer:left];
}
- (void)toRight
{
    if (self.leftContraint.constant == 0) {
        [self moreButtonClick];
    }
}
- (void)toLeft
{
    if (self.leftContraint.constant != 0) {
        [self moreButtonClick];
    }
}
#pragma mark - 设置句子
- (void)setupNoteLabel
{
    //先从本地加载
    NSString *noteString = [CXUserDefaults readObjectForKey:noteLabelKey];
    self.noteLabel.text = noteString;
    //网络加载
    [self.manager GET:@"http://open.iciba.com/dsapi/" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.noteLabel.text = responseObject[@"note"];
        //句子保存到本地
        [CXUserDefaults setObject:responseObject[@"note"] forKey:noteLabelKey];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        CXLog(@"%@", error);
        [SVProgressHUD showErrorWithStatus:@"似乎已断开与网络的链接..."];
    }];
}
#pragma mark - 设置日期
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
@end
