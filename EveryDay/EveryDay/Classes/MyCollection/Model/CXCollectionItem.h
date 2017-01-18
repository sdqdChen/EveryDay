//
//  CXCollectionItem.h
//  EveryDay
//
//  Created by 陈晓 on 2017/1/17.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXCollectionItem : NSObject
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *itemid;
@end
