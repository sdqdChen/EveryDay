//
//  CXEnglishMonth.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/7.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXEnglishMonth.h"

/** 月份 */
typedef NS_OPTIONS(NSUInteger, CXMonthKey) {
    CXJan = 1,
    CXFeb,
    CXMar,
    CXApr,
    CXMay,
    CXJun,
    CXJul,
    CXAug,
    CXSep,
    CXOct,
    CXNov,
    CXDec
};

@implementation CXEnglishMonth
/*
 * 转成英文月份
 */
+ (NSString *)englishMonthWith:(NSInteger)month
{
    switch (month) {
        case CXJan:
            return @"Jan.";
            break;
        case CXFeb:
            return @"Feb.";
            break;
        case CXMar:
            return @"Mar.";
            break;
        case CXApr:
            return @"Apr.";
            break;
        case CXMay:
            return @"May.";
            break;
        case CXJun:
            return @"Jun.";
            break;
        case CXJul:
            return @"Jul.";
            break;
        case CXAug:
            return @"Aug.";
            break;
        case CXSep:
            return @"Sep.";
            break;
        case CXOct:
            return @"Oct.";
            break;
        case CXNov:
            return @"Nov.";
            break;
        case CXDec:
            return @"Dec.";
            break;
        default:
            break;
    }
    return nil;
}
@end
