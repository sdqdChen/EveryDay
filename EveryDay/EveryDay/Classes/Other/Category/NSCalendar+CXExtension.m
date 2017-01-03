//
//  NSCalendar+CXExtension.m
//
//  Created by 陈晓 on 15/11/20.
//  Copyright © 2015年 陈晓. All rights reserved.
//

#import "NSCalendar+CXExtension.h"

@implementation NSCalendar (CXExtension)
+ (instancetype)calendar
{
    if ([NSCalendar respondsToSelector:@selector(calendarWithIdentifier:)]) {
        return [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    } else {
        return [NSCalendar currentCalendar];
    }
}
@end
