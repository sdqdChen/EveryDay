//
//  CXMineCell.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/13.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXMineCell.h"
#import <Masonry.h>

@interface CXMineCell ()
//分割线
@property (nonatomic, strong) UIView *separatorView;
@end

@implementation CXMineCell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"cell";
    CXMineCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[CXMineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}
#pragma mark - 懒加载
- (UIView *)separatorView
{
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor darkGrayColor];
    }
    return _separatorView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont fontWithName:CXPingFangLight size:23];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.separatorView];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(CXseparatorViewW, 1));
        make.centerX.mas_equalTo(self);
        make.bottom.offset(0);
    }];
}
@end
