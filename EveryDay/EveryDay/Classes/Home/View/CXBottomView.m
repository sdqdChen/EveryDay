//
//  CXBottomView.m
//  动画
//
//  Created by 陈晓 on 2017/1/2.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXBottomView.h"
#import "CXBottomButton.h"
#import "CXArticleViewController.h"
#import "CXHomeViewController.h"
#import "CXPoemViewController.h"

typedef NS_OPTIONS(NSUInteger, CXButonType) {
    CXArtileButton = 1,
    CXPoemButton,
    CXMusicButton,
    CXPictureButton
};

@interface CXBottomView ()
@property (weak, nonatomic) IBOutlet CXBottomButton *bottomButton;
@property (nonatomic, strong) NSMutableArray *items;
@end
//底部按钮宽高
static CGFloat buttonW = 44;
static CGFloat buttonH = 44;
//底部按钮弹出动画时间
static CGFloat buttonAnimation = 0.7;

@implementation CXBottomView
- (NSMutableArray *)items
{
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}
+ (instancetype)bottomView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"CXBottomView" owner:nil options:nil] lastObject];
}
/*
 * 添加4个按钮
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self addBtnWithImgName:@"articleButton" andTag:1];
        [self addBtnWithImgName:@"poemButton" andTag:2];
        [self addBtnWithImgName:@"musicButton" andTag:3];
        [self addBtnWithImgName:@"pictureButton" andTag:4];
    }
    return self;
}
- (void)addBtnWithImgName:(NSString *)imgName andTag:(NSInteger)tag
{
    CXBottomButton *btn = [CXBottomButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(clickBottomButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [self.items addObject:btn];
    btn.tag = tag;
    [self addSubview:btn];
}
/*
 * 布局
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    CGRect btnBounds = CGRectMake(0, 0, buttonW, buttonH);
    for (CXBottomButton *btn in self.items) {
        btn.bounds = btnBounds;
        btn.center = self.bottomButton.center;
    }
    [self bringSubviewToFront:self.bottomButton];
}
/*
 * 点击第一个按钮
 */
- (IBAction)bottomButtonClick:(UIButton *)sender {
    //表示按钮的transform属性是否发生改变
    BOOL show = CGAffineTransformIsIdentity(self.bottomButton.transform);
    [UIView animateWithDuration:buttonAnimation animations:^{
        if (show) {
            sender.selected = YES;
            //代表transform未发生改变
            self.bottomButton.transform = CGAffineTransformMakeRotation(M_PI * 2);
        }else{
            self.bottomButton.transform = CGAffineTransformIdentity;
            sender.selected = NO;
        }
    }];
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat margin = (screenW - buttonW * 5) / 4 + buttonW - 10;
    for (CXBottomButton *btn in self.items) {
        if (show) {
            CGFloat btnX = self.bottomButton.center.x + (btn.tag) * margin;
            CGFloat btnY = self.bottomButton.center.y;
            [UIView animateWithDuration:buttonAnimation animations:^{
                btn.center = CGPointMake(btnX, btnY);
                btn.transform = CGAffineTransformRotate(btn.transform, M_PI);
                btn.transform = CGAffineTransformRotate(btn.transform, M_PI);
            }];
        } else {
            [UIView animateWithDuration:buttonAnimation animations:^{
                btn.transform = CGAffineTransformRotate(btn.transform, M_PI);
                btn.transform = CGAffineTransformRotate(btn.transform, M_PI);
                btn.center = self.bottomButton.center;
            }];
        }
    }
}
/*
 * 点击其余的按钮
 */
- (void)clickBottomButton:(CXBottomButton *)button
{
    //先让4个按钮收回去
    [self bottomButtonClick:self.bottomButton];
    
    if (button.tag == CXArtileButton) { //文章
        CXArticleViewController *articleVc = [[CXArticleViewController alloc] init];
        articleVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        UIViewController *home = [UIApplication sharedApplication].keyWindow.rootViewController;
        [home presentViewController:articleVc animated:YES completion:nil];
    } else if (button.tag == CXPoemButton) {
        CXPoemViewController *poemVc = [[CXPoemViewController alloc] init];
        poemVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        UIViewController *home = [UIApplication sharedApplication].keyWindow.rootViewController;
        [home presentViewController:poemVc animated:YES completion:nil];
    } else if (button.tag == CXMusicButton) {
        CXLog(@"音乐");
    } else if (button.tag == CXPictureButton) {
        CXLog(@"图片");
    }
}
@end
