//
//  CXFileTool.h
//
//  Created by 陈晓 on 2016/11/15.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CXFileTool : NSObject
/*
 * 计算文件夹尺寸
 */
+ (void)getFileSize:(NSString *)directoryPath completion:(void(^)(NSInteger))completion;
/*
 * 删除文件夹所有文件
 */
+ (void)removeDirectoryPath:(NSString *)directoryPath completion:(void(^)())completion;
@end
