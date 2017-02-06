//
//  CXLeftCell.m
//  EveryDay
//
//  Created by 陈晓 on 2017/2/5.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXLeftCell.h"
#import <Masonry.h>

static CGFloat const labelFont = 17;
static CGFloat const separatorW = 75;

@interface CXLeftCell ()
//分割线
@property (nonatomic, strong) UIView *separatorView;
@end
@implementation CXLeftCell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"left";
    CXLeftCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[CXLeftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont fontWithName:CXPingFangLight size:labelFont * KRATE];
        self.backgroundColor = [UIColor blackColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self addSubview:self.separatorView];
    }
    return self;
}
#pragma mark - 懒加载
- (UIView *)separatorView
{
    if (!_separatorView) {
        _separatorView = [[UIView alloc] init];
        _separatorView.backgroundColor = [UIColor whiteColor];
    }
    return _separatorView;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(separatorW * KRATE, 1));
        make.centerX.mas_equalTo(self);
        make.bottom.offset(0);
    }];
}
@end
