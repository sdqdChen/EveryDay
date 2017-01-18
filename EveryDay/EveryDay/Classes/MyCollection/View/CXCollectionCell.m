//
//  CXCollectionCell.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/17.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXCollectionCell.h"
#import "CXCollectionItem.h"

@interface CXCollectionCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@end

@implementation CXCollectionCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setItem:(CXCollectionItem *)item
{
    _item = item;
    self.titleLabel.text = item.title;
    self.authorLabel.text = item.author;
    self.typeLabel.text = item.type;
}
@end
