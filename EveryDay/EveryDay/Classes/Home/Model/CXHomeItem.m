//
//  CXHomeItem.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/2.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXHomeItem.h"

@implementation CXHomeItem

/*
 * 归档
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_note forKey:@"_note"];
    [aCoder encodeObject:_picture2 forKey:@"_picture2"];
    [aCoder encodeObject:_sid forKey:@"_sid"];
}
/*
 * 解档
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _note = [aDecoder decodeObjectForKey:@"_note"];
        _picture2 = [aDecoder decodeObjectForKey:@"_picture2"];
        _sid = [aDecoder decodeObjectForKey:@"_sid"];
    }
    return self;
}
@end
