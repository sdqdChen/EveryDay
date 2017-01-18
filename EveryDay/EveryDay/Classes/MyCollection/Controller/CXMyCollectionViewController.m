//
//  CXMyCollectionViewController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/17.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXMyCollectionViewController.h"
#import <Masonry.h>
#import <MaxLeap/MaxLeap.h>
#import "CXCollectionItem.h"
#import <MJExtension.h>
#import "CXCollectionCell.h"
#import "CXCollectWebViewController.h"

@interface CXMyCollectionViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/** 收藏的数组 */
@property (nonatomic, strong) NSArray *collections;
@end

static NSString * const ID = @"cell";

@implementation CXMyCollectionViewController
#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    //设置tableView
    [self setupTableView];
    //获取数据
    [self loadDataFromNet];
    
}
- (void)setupTableView
{
    self.tableView.rowHeight = 50 * KRATE;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"CXCollectionCell" bundle:nil] forCellReuseIdentifier:ID];
}
#pragma mark - 获取网络数据
- (void)loadDataFromNet
{
    MLUser *user = [MLUser currentUser];
    NSArray *array = user[@"collection"];
    self.collections = [CXCollectionItem mj_objectArrayWithKeyValuesArray:array];
}
#pragma mark - tableView数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.collections.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CXCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    CXCollectionItem *item = self.collections[indexPath.row];
    cell.item = item;
    return cell;
}
#pragma mark - tableView代理方法
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CXCollectWebViewController *webView = [[CXCollectWebViewController alloc] init];
    CXCollectionItem *item = self.collections[indexPath.row];
    webView.item = item;
    [self.navigationController pushViewController:webView animated:YES];
}
@end
