//
//  CXLrcTool.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/9.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXLrcTool.h"
#import "CXLrcItem.h"

@implementation CXLrcTool
+ (NSArray *)analysisLrcWithString:(NSString *)string
{
    NSArray *lrcArray = [string componentsSeparatedByString:@"\n"];
    NSMutableArray *tmpArray = [NSMutableArray array];
    for (NSString *string in lrcArray) {
        if ([string hasPrefix:@"[ti:"] ||
            [string hasPrefix:@"[ar:"] ||
            [string hasPrefix:@"[al:"] ||
            [string hasPrefix:@"[by:"] ||
            [string hasPrefix:@"[offset:"] ||
            ![string hasPrefix:@"["]) {
            continue;
        }
        //[00:00.10]小半 - 陈粒
        CXLrcItem *lrcItem = [CXLrcItem LrcLineString:string];
        [tmpArray addObject:lrcItem];
    }
    return tmpArray;
}
@end
