//
//  CXNoteLabel.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/4.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXNoteLabel.h"

@implementation CXNoteLabel
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.font = [UIFont fontWithName:@"PingFang SC" size:18];
}
- (instancetype)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}
/*
 * 设置文字居左居上对齐
 */
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    textRect.origin.y = bounds.origin.y;
    return textRect;
}
- (void)drawTextInRect:(CGRect)rect
{
    CGRect actualRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}
@end
