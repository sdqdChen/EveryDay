//
//  CXHomeItem.h
//  EveryDay
//
//  Created by 陈晓 on 2017/1/2.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXHomeItem : NSObject <NSCoding>
/** 文字 */
@property (nonatomic, copy) NSString *note;
/** 图片 */
@property (nonatomic, copy) NSString *picture2;
@property (nonatomic, copy) NSString *sid;

@end
