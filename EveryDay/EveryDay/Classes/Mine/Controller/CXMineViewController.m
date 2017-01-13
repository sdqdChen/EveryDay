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

typedef NS_ENUM(NSInteger, CellRow) {
    kMyCollection = 0,
    kClearCache,
    kRecommand
};

@interface CXMineViewController ()
@property (nonatomic, strong) CXHeadLoginView *headerView;
@property (nonatomic, strong) NSArray *cellItems;
@end

@implementation CXMineViewController
- (NSArray *)cellItems
{
    if (!_cellItems) {
        _cellItems = @[@"我的收藏", @"清除缓存", @"意见反馈"];
    }
    return _cellItems;
}
#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTableView];
    //设置headerView
    [self setupHeaderView];
}
- (void)setupTableView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.rowHeight = 70;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (void)setupHeaderView
{
    CXHeadLoginView *headerView = [[CXHeadLoginView alloc] init];
    headerView.frame = CGRectMake(0, 0, CXScreenW, CXScreenW);
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
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
@end
