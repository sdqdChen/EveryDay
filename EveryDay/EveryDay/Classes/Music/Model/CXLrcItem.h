//
//  CXLrcItem.h
//  EveryDay
//
//  Created by 陈晓 on 2017/1/10.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXLrcItem : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) NSTimeInterval time;

- (instancetype)initWithLrcLineString:(NSString *)lrcLineString;
+ (instancetype)LrcLineString:(NSString *)lrcLineString;
@end
