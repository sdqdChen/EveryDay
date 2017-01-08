//
//  CXMusicViewController.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/7.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXMusicViewController.h"
#import <AFNetworking.h>
#import <UIImageView+WebCache.h>
#import "CXMusicItem.h"
#import <MJExtension.h>
#import "CXAudioTool.h"
#import <AVFoundation/AVFoundation.h>
#import "CALayer+PauseAimate.h"

@interface CXMusicViewController ()
/** 歌曲图片 */
@property (weak, nonatomic) IBOutlet UIImageView *albumPicture;
/** 歌手名 */
@property (weak, nonatomic) IBOutlet UILabel *singerNameLabel;
/** 歌曲名 */
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
/** 显示的一行歌词 */
@property (weak, nonatomic) IBOutlet UILabel *lrcLabel;
/** 所有的歌曲 */
@property (nonatomic, strong) NSArray *allSongsArray;
/** 当前播放的歌曲模型对象 */
@property (nonatomic, strong) CXMusicItem *musicItem;
/** 当前播放器 */
@property (nonatomic, strong) AVPlayer *currentPlayer;
@end

@implementation CXMusicViewController
#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    //获取音乐数据
    [self loadMusicData];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //设置歌曲图片为圆形
    self.albumPicture.layer.cornerRadius = self.albumPicture.cx_width * 0.5;
    self.albumPicture.layer.masksToBounds = YES;
}
#pragma mark - 获取音乐数据
- (void)loadMusicData
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"showapi_appid"] = @16085;
    para[@"showapi_sign"] = @"8ec343d2c5cd450da68391505fd73a76";
    para[@"topid"] = @26;
    [manager GET:@"http://route.showapi.com/213-4" parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject[@"showapi_res_body"][@"pagebean"];
        self.allSongsArray = [CXMusicItem mj_objectArrayWithKeyValuesArray:dic[@"songlist"]];
        NSInteger randomIndex = arc4random() % self.allSongsArray.count;
        CXMusicItem *musicItem = self.allSongsArray[randomIndex];
        self.musicItem = musicItem;
        self.songNameLabel.text = musicItem.songname;
        self.singerNameLabel.text = musicItem.singername;
        [self.albumPicture sd_setImageWithURL:[NSURL URLWithString:musicItem.albumpic_big]];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}
#pragma mark - 播放或暂停歌曲
- (IBAction)playOrPause:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected == YES) { //开始播放歌曲
        self.currentPlayer = [CXAudioTool playMusicWithUrl:self.musicItem.url];
        //添加旋转动画
//        [self addAlbumPictureAnimate];
    } else { //暂停播放
        [CXAudioTool pauseMusicWithUrl:self.musicItem.url];
        
//        [self.albumPicture.layer pauseAnimate];
    }
    CXLog(@"%@", self.currentPlayer.currentItem);
}
#pragma mark - 旋转动画
- (void)addAlbumPictureAnimate
{
    CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animate.fromValue = @(0);
    animate.toValue = @(M_PI * 2);
    animate.repeatCount = MAXFLOAT;
    animate.duration = 35;
    [self.albumPicture.layer addAnimation:animate forKey:nil];
}
#pragma mark - 监听事件
/*
 * 返回
 */
- (IBAction)return {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}
/*
 * 分享
 */
- (IBAction)share {
    
}
/*
 * 收藏
 */
- (IBAction)collect {
    
}

@end
