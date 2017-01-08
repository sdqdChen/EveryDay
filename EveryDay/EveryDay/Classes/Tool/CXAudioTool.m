//
//  CXAudioTool.m
//
//  Created by 陈晓 on 2017/1/6.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXAudioTool.h"

@implementation CXAudioTool
//不能用创建字典属性，因为是类方法
static NSMutableDictionary *_soundIDs;
static NSMutableDictionary *_players;

+ (void)initialize
{
    //一定要初始化可变字典
    _soundIDs = [NSMutableDictionary dictionary];
    _players = [NSMutableDictionary dictionary];
}
/*
 * 开始播放音乐
 */
+ (AVPlayer *)playMusicWithUrl:(NSString *)url
{
    AVPlayer *player = nil;
    player = _players[url];
    if (!player) {
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
        player = [AVPlayer playerWithPlayerItem:playerItem];
        
        [_players setObject:player forKey:url];
    }
    [player play];
    return player;
}
/*
 * 暂停播放音乐
 */
+ (void)pauseMusicWithUrl:(NSString *)url
{
    AVPlayer *player = _players[url];
    if (player) {
        [player pause];
    }
}

/*
 * 播放音效
 */
+ (void)playSoundWithSoundName:(NSString *)soundName
{
    // 1.创建soundID = 0
    SystemSoundID soundID = 0;
    
    // 2.从字典中取出soundID
    soundID = [_soundIDs[soundName] unsignedIntValue];;
    
    // 3.判断soundID是否为0
    if (soundID == 0) {
        // 3.1生成soundID
        CFURLRef url = (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
        AudioServicesCreateSystemSoundID(url, &soundID);
        
        // 3.2将soundID保存到字典中
        [_soundIDs setObject:@(soundID) forKey:soundName];
    }
    // 4.播放音效
    AudioServicesPlaySystemSound(soundID);
}

@end
