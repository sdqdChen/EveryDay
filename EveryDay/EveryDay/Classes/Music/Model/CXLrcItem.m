//
//  CXLrcItem.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/10.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXLrcItem.h"

@implementation CXLrcItem
- (instancetype)initWithLrcLineString:(NSString *)lrcLineString
{
    if (self = [super init]) {
        NSArray *array = [lrcLineString componentsSeparatedByString:@"]"];
        //[00:00.10]小半 - 陈粒
        self.text = array[1];
        self.time = [self timeWithString:[array[0] substringFromIndex:1]];
    }
    return self;
}
+ (instancetype)LrcLineString:(NSString *)lrcLineString
{
    return [[self alloc] initWithLrcLineString:lrcLineString];
}

/*
 * NSString - > NSTimeInterval
 */
- (NSTimeInterval)timeWithString:(NSString *)timeString
{
    //01:02.38
    NSInteger min = [[timeString componentsSeparatedByString:@":"][0] integerValue];
    NSInteger sec = [[timeString substringWithRange:NSMakeRange(3, 2)] integerValue];
    NSInteger hs = [[timeString componentsSeparatedByString:@"."][1] integerValue];
    return min * 60 + sec + hs * 0.01;
//    return 0;
}
@end
