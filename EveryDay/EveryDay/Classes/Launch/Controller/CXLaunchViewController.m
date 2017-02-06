//
//  CXLaunchViewController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/22.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXLaunchViewController.h"
#import "CXHomeViewController.h"
#import "CXNavigationController.h"

#define iphone6p (CXScreenH == 736)
#define iphone6 (CXScreenH == 667)
#define iphone5 (CXScreenH == 568)
#define iphone4 (CXScreenH == 480)

@interface CXLaunchViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation CXLaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //屏幕适配
    [self setupLaunchImage];
    //设置日期
    [self setupDate];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            CXNavigationController *nav = [[CXNavigationController alloc] initWithRootViewController:[[CXHomeViewController alloc] init]];
            [UIApplication sharedApplication].keyWindow.rootViewController = nav;
        }];
    });
}
- (void)setupDate
{
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [cal components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    self.dateLabel.text = [NSString stringWithFormat:@"%@年%@月%@日", [self dateFromNumberToChinese:cmps.year], [self dateFromNumberToChinese:cmps.month], [self dateFromNumberToChinese:cmps.day]];
}
- (void)setupLaunchImage
{
    if (iphone6p) {
        self.bgImageView.image = [UIImage imageNamed:@"LaunchImage414x736@3x"];
    } else if (iphone6) {
        self.bgImageView.image = [UIImage imageNamed:@"LaunchImage375x667@2x"];
    } else if (iphone5) {
        self.bgImageView.image = [UIImage imageNamed:@"LaunchImage320x568@2x"];
    } else if (iphone4) {
        self.bgImageView.image = [UIImage imageNamed:@"LaunchImage320x480@2x"];
    }
}
- (BOOL)prefersStatusBarHidden
{
    return YES;
}
/*
 * 将年月日数字转换成中文
 */
- (NSString *)dateFromNumberToChinese:(NSInteger)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = kCFNumberFormatterRoundHalfDown;
    NSString *string = [formatter stringFromNumber:[NSNumber numberWithInteger:number]];
    NSString *string1 = [string stringByReplacingOccurrencesOfString:@"千" withString:@""];
    NSString *string2 = [string1 stringByReplacingOccurrencesOfString:@"百" withString:@""];
    if (number > 100) { //年
        NSString *string3 = [string2 stringByReplacingOccurrencesOfString:@"十" withString:@""];
        return string3;
    } else { //月、日
        return string2;
    }
}
@end
