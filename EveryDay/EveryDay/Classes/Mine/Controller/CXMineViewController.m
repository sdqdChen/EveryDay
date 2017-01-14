//
//  CXMineViewController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/12.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXMineViewController.h"
#import "CXHeadLoginView.h"
#import <Masonry.h>
#import "CXMineCell.h"
#import <MaxLeap/MaxLeap.h>
#import "CXAlertController.h"

typedef NS_ENUM(NSInteger, CellRow) {
    kMyCollection = 0,
    kClearCache,
    kRecommand
};

@interface CXMineViewController ()
@property (nonatomic, strong) CXHeadLoginView *headerView;
@property (nonatomic, strong) NSArray *cellItems;
@property (nonatomic, strong) UILabel *logoutLabel;
@end

@implementation CXMineViewController
#pragma mark - 懒加载
- (NSArray *)cellItems
{
    if (!_cellItems) {
        _cellItems = @[@"我的收藏", @"清除缓存", @"意见反馈"];
    }
    return _cellItems;
}
- (CXHeadLoginView *)headerView
{
    if (!_headerView) {
        _headerView = [[CXHeadLoginView alloc] init];
        _headerView.frame = CGRectMake(0, 0, CXScreenW, CXScreenW);
    }
    return _headerView;
}
- (UILabel *)logoutLabel
{
    if (!_logoutLabel) {
        _logoutLabel = [[UILabel alloc] init];
        _logoutLabel.text = @"退出登录";
        _logoutLabel.userInteractionEnabled = YES;
        if ([CXUserDefaults readBoolForKey:LoginSuccess]) {
            _logoutLabel.hidden = NO;
        } else {
            _logoutLabel.hidden = YES;
        }
        _logoutLabel.font = [UIFont fontWithName:CXPingFangLight size:17];
        _logoutLabel.textColor = [UIColor lightGrayColor];
        [_logoutLabel sizeToFit];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoutClick)];
        [_logoutLabel addGestureRecognizer:tap];
    }
    return _logoutLabel;
}
#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    //设置headerView
    self.tableView.tableHeaderView = self.headerView;
    //设置footerView
    [self.tableView addSubview:self.logoutLabel];
    //监听登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:CXLoginSuccessNotification object:nil];
    MLUser *currentUser = [MLUser currentUser];
    if (currentUser) {
        if ([MLAnonymousUtils isLinkedWithUser:currentUser]) {
            CXLog(@"匿名登录");
        } else {
            CXLog(@"登录");
        }
    } else {
        CXLog(@"未登录");
    }
}
- (void)setupTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.rowHeight = 70;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.logoutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.tableView);
        make.bottom.mas_equalTo(self.tableView).offset(CXScreenH - 10);
    }];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CXLoginSuccessNotification object:nil];
}
#pragma mark - tableView数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CXMineCell *cell = [CXMineCell cellWithTableView:tableView];
    cell.textLabel.text = self.cellItems[indexPath.row];
    return cell;
}
#pragma mark - tableView代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case kMyCollection:
            CXLog(@"我的收藏");
            break;
        case kClearCache:
            CXLog(@"清除缓存");
            break;
        case kRecommand:
            CXLog(@"意见反馈");
            break;
        default:
            break;
    }
}
#pragma mark - 监听事件
/*
 * 登录成功
 */
- (void)loginSuccess
{
    self.logoutLabel.hidden = NO;
}
/*
 * 退出登录
 */
- (void)logoutClick
{
    [CXAlertController alertSureAndCancelWithTitle:@"退出登录?" sureHandler:^(UIAlertAction *action) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CXLoginOutNotification object:nil];
        [CXUserDefaults setBool:NO forKey:LoginSuccess];
        [MLUser logOut];
        self.logoutLabel.hidden = YES;
    } cancelHandler:nil viewController:self];
}
@end
