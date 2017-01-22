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
#import <AVFoundation/AVFoundation.h>
#import "CALayer+PauseAimate.h"
#import "CXLrcTool.h"
#import "NSString+HTML.h"
#import "CXLrcItem.h"
#import "CXLoadingAnimation.h"
#import <SVProgressHUD.h>
#import "CXCircleView.h"
#import "CXUMSocial.h"

static NSString * const musicUrl = @"http://route.showapi.com/213-4";
static NSString * const lrcUrl = @"http://route.showapi.com/213-2";
static NSString * const searchUrl = @"http://route.showapi.com/213-1";
static NSInteger const showapi_appid = 16085;
static NSString * const showapi_sign = @"8ec343d2c5cd450da68391505fd73a76";
static NSString * const randomKey = @"randomKey";

@interface CXMusicViewController ()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
/** 歌曲图片 */
@property (weak, nonatomic) IBOutlet UIImageView *albumPicture;
/** 歌手名 */
@property (weak, nonatomic) IBOutlet UILabel *singerNameLabel;
/** 歌曲名 */
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
/** 播放按钮 */
@property (weak, nonatomic) IBOutlet UIButton *playOrPauseButton;
/** 显示的一行歌词 */
@property (weak, nonatomic) IBOutlet UILabel *lrcLabel;
/** 所有的歌曲 */
@property (nonatomic, strong) NSArray *allSongsArray;
/** 当前播放的歌曲模型对象 */
@property (nonatomic, strong) CXMusicItem *currentItem;
/** 当前播放器 */
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
//当前歌曲进度监听者
@property(nonatomic,strong) id timeObserver;
/** 歌曲播放进度 */
@property (nonatomic, assign) float progress;
/** 歌词模型数组 */
@property (nonatomic, strong) NSArray *lrcArray;
/** 加载动画 */
@property (nonatomic, weak) CXLoadingAnimation *animationView;
/** 是否已准备好播放 */
@property (nonatomic, assign, getter=isReadyToPlay) BOOL readyToPlay;
/** 圆圈 */
@property (nonatomic, strong) CXCircleView *circle;
/** 一开始的蒙版 */
@property (nonatomic, strong) UIView *whiteView;
@end

@implementation CXMusicViewController
#pragma mark - 懒加载
- (AFHTTPSessionManager *)manager
{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}
- (AVPlayer *)player
{
    if (!_player) {
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:@""]];
        _player  = [[AVPlayer alloc] initWithPlayerItem:item];
    }
    return _player;
}
#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    //获取音乐数据
    [self loadMusicData];
    //设置字体
    [self setupLabelFont];
    //添加播放按钮的进度圆圈
    [self addCircleView];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CXScreenW, CXScreenH)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteView];
    self.whiteView = whiteView;
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.isReadyToPlay == NO) { //还没有准备好播放
        [self addloadAnimate];
    }
}
- (void)addloadAnimate
{
    CXLoadingAnimation *animationView = [[CXLoadingAnimation alloc] init];
    animationView.frame = CGRectMake(0, 0, CXScreenW, CXScreenH);
    [self.view addSubview:animationView];
    self.animationView = animationView;
    [self.view bringSubviewToFront:self.closeButton];
}
- (void)setupLabelFont
{
    self.songNameLabel.font = [UIFont fontWithName:CXPingFangLight size:18.0];
    self.singerNameLabel.font = [UIFont fontWithName:CXPingFangLight size:15.0];
    self.lrcLabel.font = [UIFont fontWithName:CXPingFangLight size:16.0];
}
- (void)addCircleView
{
    CXCircleView *circle = [[CXCircleView alloc] init];
    [self.playOrPauseButton addSubview:circle];
    self.circle = circle;
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    //设置歌曲图片为圆形
    self.albumPicture.layer.cornerRadius = self.albumPicture.cx_width * 0.5;
    self.albumPicture.layer.masksToBounds = YES;
    self.circle.frame = self.playOrPauseButton.bounds;
}
#pragma mark - 获取音乐数据
/*
 * 根据时间判断是否应该更新数据
 */
- (BOOL)isShouldUpdate
{
    NSString *lastUpdateDateStr = [CXUserDefaults readObjectForKey:lastMusicUpdateKey];
    if (!lastUpdateDateStr) return YES;
    [CXUserDefaults setObject:lastUpdateDateStr forKey:lastMusicUpdateKey];
    //今天
    NSDate *date = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [cal components:NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    //把日期保存起来，为了判断是否刷新文章
    NSString *todayDateStr = [NSString stringWithFormat:@"%ld月%ld日", cmps.month, cmps.day];
    [CXUserDefaults setObject:todayDateStr forKey:lastMusicUpdateKey];
    if ([lastUpdateDateStr isEqualToString:todayDateStr]) { //同一天
        return NO;
    } else {
        return YES;
    }
}
- (void)loadMusicData
{
    BOOL update = [self isShouldUpdate];
    if (update) {
        NSInteger randomIndex = arc4random() % 300;
        [self loadDataWithIndex:randomIndex];
    } else {
        NSInteger specificIndex = [[CXUserDefaults readObjectForKey:randomKey] integerValue];
        [self loadDataWithIndex:specificIndex];
    }
}
- (void)loadDataWithIndex:(NSInteger)index
{
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"showapi_appid"] = @(showapi_appid);
    para[@"showapi_sign"] = showapi_sign;
    para[@"topid"] = @26;
    [self.manager GET:musicUrl parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = responseObject[@"showapi_res_body"][@"pagebean"];
        self.allSongsArray = [CXMusicItem mj_objectArrayWithKeyValuesArray:dic[@"songlist"]];
        CXMusicItem *currentItem = self.allSongsArray[index];
        self.currentItem = currentItem;
        //刷新界面
        [self reloadUIWithItem:currentItem];
        //准备播放歌曲
        [self playMusicWithItem:currentItem];
        //获取歌词
        [self loadLrcWithSongid:currentItem.songid];
        //保存特定歌曲信息
        [CXUserDefaults setObject:@(index) forKey:randomKey];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        CXLog(@"%@", error);
        //移除加载动画
        [self loadFailed];
    }];
}
- (void)loadFailed
{
    [SVProgressHUD showErrorWithStatus:@"似乎已断开与网络的链接..."];
    if (self.animationView) {
        [self.animationView removeFromSuperview];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.animationView removeFromSuperview];
        });
    }
}
#pragma mark - 获取歌词
- (void)loadLrcWithSongid:(NSString *)songid
{
    NSMutableDictionary *para = [NSMutableDictionary dictionary];
    para[@"showapi_appid"] = @16085;
    para[@"showapi_sign"] = @"8ec343d2c5cd450da68391505fd73a76";
    para[@"musicid"] = songid;
    [self.manager GET:lrcUrl parameters:para progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        NSString *lrcString = [responseObject[@"showapi_res_body"][@"lyric"] stringByReplacingHTMLEntities];
        NSArray *lrcArray = [CXLrcTool analysisLrcWithString:lrcString];
        self.lrcArray = lrcArray;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}
#pragma mark - 音乐播放相关
/*
 * 准备播放歌曲
 */
- (void)playMusicWithItem:(CXMusicItem *)item
{
    //1.设置音乐资源
    [self playMusicWithUrl:item.url];
    //2.监听播放器状态
    [self addPlayerStatusObserver];
    //3.监听音乐缓冲进度
    
    //4.监听音乐播放进度
    [self addProgressObserverWithPlayerItem:self.playerItem];
    //5.监听音乐播放完成的通知
    [self addPlayFinishNotification];
}
- (void)playMusicWithUrl:(NSString *)url
{
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
    self.playerItem = playerItem;
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
}
/*
 * 更新UI
 */
- (void)reloadUIWithItem:(CXMusicItem *)item
{
    self.songNameLabel.text = item.songname;
    self.singerNameLabel.text = item.singername;
    [self.albumPicture sd_setImageWithURL:[NSURL URLWithString:item.albumpic_big]];
    self.lrcLabel.text = @"";
}
#pragma mark - 监听音乐的各种状态
/*
 * KVO监听播放器状态
 */
- (void)addPlayerStatusObserver
{
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}
/*
 * 移除监听播放器状态
 */
- (void)removePlayerStatusObserver
{
    if (!self.currentItem) return;
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
}
/*
 * 监听音乐播放进度
 */
- (void)addProgressObserverWithPlayerItem:(AVPlayerItem *)item
{
    [self removeProgressObserver];
    __weak typeof(self) weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        float currentTime = CMTimeGetSeconds(time);
        //设置当前显示歌词
        NSInteger count = weakSelf.lrcArray.count;
        for (NSInteger i = 0; i < count; i++) {
            //取出当前歌词
            CXLrcItem *currentItem = weakSelf.lrcArray[i];
            //取出下一句歌词
            NSInteger nextIndex = i + 1;
            CXLrcItem *nextItem = nil;
            if (nextIndex < count) {
                nextItem = weakSelf.lrcArray[nextIndex];
            }
            if (currentTime >= currentItem.time && currentTime < nextItem.time) {
                weakSelf.lrcLabel.text = currentItem.text;
            }
        }
        //总时间
        float totalTime = CMTimeGetSeconds(item.duration);
        if (currentTime) {
            float progress = currentTime / totalTime;
            weakSelf.progress = progress;
            weakSelf.circle.progress = progress;
        }
    }];
}
/*
 * 移除监听音乐播放进度
 */
- (void)removeProgressObserver
{
    if (self.timeObserver) {
        [self.player removeTimeObserver:self.timeObserver];
        self.timeObserver = nil;
    }
}
/*
 * 监听音乐播放完成的通知
 */
- (void)addPlayFinishNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinished) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}
- (void)playFinished
{
    //播放完毕
    self.playOrPauseButton.selected = NO;
    self.circle.progress = 0;
    self.lrcLabel.text = @"";
    [self.albumPicture.layer removeAllAnimations];
    [self removePlayer];
    [self playMusicWithItem:self.currentItem];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}
#pragma mark - 播放或暂停歌曲
- (IBAction)playOrPause:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected == YES) { //开始播放歌曲
        [self.player play];
        if (!self.progress) {
            [self addAlbumPictureAnimate];
        } else {
            [self.albumPicture.layer resumeAnimate];
        }
    } else { //暂停播放
        [self.player pause];
        [self.albumPicture.layer pauseAnimate];
    }
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
#pragma mark - 观察者回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) { //播放器状态回调
        switch (self.player.currentItem.status) {
            case AVPlayerItemStatusUnknown:
                NSLog(@"未知状态");
                break;
            case AVPlayerItemStatusFailed:
                [SVProgressHUD showErrorWithStatus:@"网络状况不佳,请稍后再试"];
                self.playOrPauseButton.enabled = NO;
                //移除加载动画
                [self.animationView removeFromSuperview];
                [self.whiteView removeFromSuperview];
                break;
            case AVPlayerItemStatusReadyToPlay:
                self.readyToPlay = YES;
                //移除加载动画
                [self.animationView removeFromSuperview];
                [self.whiteView removeFromSuperview];
                break;
                
            default:
                break;
        }
    }
}
#pragma mark - 监听事件
/*
 * 返回
 */
- (IBAction)return {
    [self dismissViewControllerAnimated:YES completion:nil];
    //清除播放器相关
    [self removePlayer];
    //移除动画
    if (self.animationView) {
        [self.animationView removeFromSuperview];
    }
}
- (void)removePlayer
{
    [self.player pause];
    [self removePlayerStatusObserver];
    [self removeProgressObserver];
}
/*
 * 分享
 */
- (IBAction)share {
    CXMusicItem *item = self.currentItem;
    [[CXUMSocial defaultSocialManager] shareMusicWithTitle:item.songname content:item.singername image:item.albumpic_big url:item.url completion:nil];
}

@end
