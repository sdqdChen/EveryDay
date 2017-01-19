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
/** 当前用户 */
@property (nonatomic, strong) MLUser *user;
@end

static NSString * const ID = @"cell";

@implementation CXMyCollectionViewController
- (MLUser *)user
{
    if (!_user) {
        _user = [MLUser currentUser];
    }
    return _user;
}
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
    self.tableView.rowHeight = 65 * KRATE;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"CXCollectionCell" bundle:nil] forCellReuseIdentifier:ID];
}
#pragma mark - 获取网络数据
- (void)loadDataFromNet
{
    NSArray *array = self.user[@"collection"];
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
#pragma mark - 删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self cancelCollectionWithIndexPath:indexPath];
    }
}
- (void)cancelCollectionWithIndexPath:(NSIndexPath *)indexPath
{
    CXCollectionItem *item = self.collections[indexPath.row];
    NSMutableArray *array = self.user[@"collection"];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        if ([dic[@"itemid"] isEqualToString:item.itemid]) {
            [array removeObject:dic];
        }
    }];
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            CXLog(@"%@", error);
        } else {
            [self loadDataFromNet];
            [self.tableView reloadData];
        }
    }];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"取消收藏";
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
