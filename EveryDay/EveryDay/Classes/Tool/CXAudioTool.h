//
//  CXAudioTool.h
//
//  Created by 陈晓 on 2017/1/6.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface CXAudioTool : NSObject
/*
 * 播放音效
 */
+ (void)playSoundWithSoundName:(NSString *)soundName;
/*
 * 开始播放网络音乐
 */
+ (AVPlayer *)playMusicWithUrl:(NSString *)url;
/*
 * 暂停播放网络音乐
 */
+ (void)pauseMusicWithUrl:(NSString *)url;
@end
