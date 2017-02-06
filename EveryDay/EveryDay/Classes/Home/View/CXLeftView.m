//
//  CXLeftView.m
//  EveryDay
//
//  Created by 陈晓 on 2017/2/5.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXLeftView.h"
#import "CXLeftCell.h"
#import "CXArticleViewController.h"
#import "CXPoemViewController.h"
#import "CXMusicViewController.h"

@interface CXLeftView () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *cellItems;
@end

@implementation CXLeftView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.dataSource = self;
        self.delegate = self;
        self.contentInset = UIEdgeInsetsMake(CXNavigationBarMaxY, 0, 0, 0);
        self.backgroundColor = [UIColor blackColor];
        self.rowHeight = 70;
    }
    return self;
}
#pragma mark - 懒加载
- (NSArray *)cellItems
{
    if (!_cellItems) {
        _cellItems = @[@"今日文章", @"今日诗歌", @"今日音乐"];
    }
    return _cellItems;
}

#pragma mark - tableView数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CXLeftCell *cell = [CXLeftCell cellWithTableView:tableView];
    cell.textLabel.text = self.cellItems[indexPath.row];
    return cell;
}
#pragma mark - tablewView代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self presentNextVc:[[CXArticleViewController alloc] init]];
            break;
        case 1:
            [self presentNextVc:[[CXPoemViewController alloc] init]];
            break;
        case 2:
            [self presentNextVc:[[CXMusicViewController alloc] init]];
            break;
        default:
            break;
    }
}
/*
 * 进入下一个控制器
 */
- (void)presentNextVc:(UIViewController *)viewController
{
    viewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    UIViewController *home = [UIApplication sharedApplication].keyWindow.rootViewController;
    [home presentViewController:viewController animated:YES completion:nil];
}
@end
