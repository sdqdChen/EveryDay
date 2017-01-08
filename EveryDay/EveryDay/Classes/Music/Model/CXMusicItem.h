//
//  CXMusicItem.h
//  EveryDay
//
//  Created by 陈晓 on 2017/1/8.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXMusicItem : NSObject
/** 歌曲图片 */
@property (nonatomic, copy) NSString *albumpic_big;
/** 歌手名 */
@property (nonatomic, copy) NSString *singername;
/** 歌曲名 */
@property (nonatomic, copy) NSString *songname;
/** url */
@property (nonatomic, copy) NSString *url;
/** 歌曲id */
@property (nonatomic, copy) NSString *songid;
@end
