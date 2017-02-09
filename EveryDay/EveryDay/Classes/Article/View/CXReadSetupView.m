//
//  CXReadSetupView.m
//  EveryDay
//
//  Created by 陈晓 on 2017/2/8.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXReadSetupView.h"
#import "CXColorButton.h"
#import "CXSetupWebView.h"

typedef NS_ENUM(NSInteger, BGColor) {
    kWhiteColor = 1,
    kGrayColor,
    kYellowColor,
    kGreenColor,
    kBlackColor
};

static NSString * const whiteColor = @"rgb(255,255,255)";
static NSString * const grayColor = @"rgb(224,224,224)";
static NSString * const yellowColor = @"rgb(245,238,214)";
static NSString * const greenColor = @"rgb(197,230,208)";
static NSString * const darkBlackColor = @"rgb(46,46,46)";
static NSString * const blackColor = @"rgb(0,0,0)";
static NSString * const lightGrayColor = @"rgb(109,109,109)";

@interface CXReadSetupView ()
@property (weak, nonatomic) IBOutlet UIView *colorView;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) UIImageView *borderImage;
@property (nonatomic, strong) CXColorButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *smallerButton;
@property (weak, nonatomic) IBOutlet UIButton *biggerButton;
@end

@implementation CXReadSetupView
#pragma mark - 懒加载
- (NSArray *)colors
{
    if (!_colors) {
        _colors = @[@"white", @"gray", @"yellow", @"green", @"black"];
    }
    return _colors;
}
- (CXColorButton *)firstButton
{
    if (!_firstButton) {
        _firstButton = self.colorView.subviews[0];
    }
    return _firstButton;
}
- (UIImageView *)borderImage
{
    if (!_borderImage) {
        _borderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"border"]];
        _borderImage.bounds = CGRectMake(0, 0, 48, 48);
    }
    return _borderImage;
}
#pragma mark - 初始化
+ (instancetype)loadFromXib
{
    return [[NSBundle mainBundle] loadNibNamed:@"CXReadSetupView" owner:nil options:nil].firstObject;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    //添加5个按钮
    for (NSInteger i = 0; i<5; i++) {
        CXColorButton *button = [CXColorButton buttonWithType:UIButtonTypeCustom];
        NSString *color = self.colors[i];
        [button setImage:[UIImage imageNamed:color] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(colorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button sizeToFit];
        button.tag = i + 1;
        [self.colorView addSubview:button];
    }
    //添加边框图片
    [self.colorView addSubview:self.borderImage];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    for (CXColorButton *button in self.colorView.subviews) {
        CGFloat margin = (self.colorView.cx_width - button.cx_width * 5) / 4;
        CGFloat buttonX = (button.cx_width + margin) * (button.tag - 1);
        button.frame = CGRectMake(buttonX, 0, button.cx_width, button.cx_height);
    }
    //设置borderImage的位置
    NSString *bgColor = [CXUserDefaults readObjectForKey:CXReadBgColorKey];
    if (!bgColor) {
        self.borderImage.center = self.firstButton.center;
    } else {
        if ([bgColor isEqualToString:grayColor]) {
            self.borderImage.center = [self.colorView viewWithTag:kGrayColor].center;
        } else if ([bgColor isEqualToString:yellowColor]) {
            self.borderImage.center = [self.colorView viewWithTag:kYellowColor].center;
        } else if ([bgColor isEqualToString:greenColor]) {
            self.borderImage.center = [self.colorView viewWithTag:kGreenColor].center;
        } else if ([bgColor isEqualToString:darkBlackColor]) {
            self.borderImage.center = [self.colorView viewWithTag:kBlackColor].center;
        } else if ([bgColor isEqualToString:whiteColor]) {
            self.borderImage.center = [self.colorView viewWithTag:kWhiteColor].center;
        }
    }
}
#pragma mark - 设置背景颜色
- (void)colorButtonClick:(UIButton *)button
{
    self.borderImage.center = button.center;
    //设置背景颜色
    switch (button.tag) {
        case kWhiteColor:
            [self setupBgColorWithColor:whiteColor];
            break;
        case kGrayColor:
            [self setupBgColorWithColor:grayColor];
            break;
        case kYellowColor:
            [self setupBgColorWithColor:yellowColor];
            break;
        case kGreenColor:
            [self setupBgColorWithColor:greenColor];
            break;
        case kBlackColor:
            [self setupBgColorWithColor:darkBlackColor];
            break;
            
        default:
            break;
    }
    //设置文字颜色
    if (button.tag == kBlackColor) {
        [self setupTextColorWithColor:lightGrayColor];
    } else {
        [self setupTextColorWithColor:blackColor];
    }
}
/*
 * 设置网页背景颜色
 */
- (void)setupBgColorWithColor:(NSString *)color
{
    [CXSetupWebView setupBgColorWith:color webView:self.webView];
    //把颜色存储到本地
    [CXUserDefaults setObject:color forKey:CXReadBgColorKey];
}
/*
 * 设置网页文字颜色
 */
- (void)setupTextColorWithColor:(NSString *)color
{
    [CXSetupWebView setupTextColorWith:color webView:self.webView];
    //把颜色存储到本地
    [CXUserDefaults setObject:color forKey:CXTextColorKey];
}
#pragma mark - 设置字体大小
static NSInteger fontSize = 100;
static NSInteger value = 20;
- (IBAction)fontSmaller{
    self.biggerButton.enabled = YES;
    fontSize -= value;
    [self setupFontSize:fontSize];
    if (fontSize == 80) {
        self.smallerButton.enabled = NO;
    }
}
- (IBAction)fontBigger{
    self.smallerButton.enabled = YES;
    fontSize += value;
    [self setupFontSize:fontSize];
    if (fontSize == 140) {
        self.biggerButton.enabled = NO;
    }
}
- (void)setupFontSize:(NSInteger)size
{
    [CXSetupWebView setupTextFontWith:size webView:self.webView];
    //把字体大小保存到本地
    [CXUserDefaults setInteger:size forKey:CXFontSizeKey];
}
@end
