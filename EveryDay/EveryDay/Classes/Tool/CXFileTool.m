//
//  CXFileTool.m
//
//  Created by 陈晓 on 2016/11/15.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import "CXFileTool.h"

@implementation CXFileTool
+ (void)removeDirectoryPath:(NSString *)directoryPath completion:(void (^)())completion
{
    //清空缓存
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL isExist = [manager fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (!isExist || !isDirectory) {
        // 抛异常
        // name:异常名称
        // reason:报错原因
        NSException *excp = [NSException exceptionWithName:@"pathError" reason:@"笨蛋 需要传入的是文件夹路径,并且路径要存在" userInfo:nil];
        [excp raise];
    }

    //获取文件夹下的所有文件(不包括子路径的子路径)
    NSArray *subPaths = [manager contentsOfDirectoryAtPath:directoryPath error:nil];
    for (NSString *subPath in subPaths) {
        //拼接全路径
        NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
        //删除路径
        [manager removeItemAtPath:filePath error:nil];
    }
    
    [self getFileSize:CachesPath completion:^(NSInteger size) {
        if (size == 0) {
            completion();
        }
    }];
}
+ (void)getFileSize:(NSString *)directoryPath completion:(void(^)(NSInteger))completion
{
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory;
    BOOL isExist = [manager fileExistsAtPath:directoryPath isDirectory:&isDirectory];
    if (!isExist || !isDirectory) {
        // 抛异常
        // name:异常名称
        // reason:报错原因
        NSException *excp = [NSException exceptionWithName:@"pathError" reason:@"需要传入的是文件夹路径,并且路径要存在" userInfo:nil];
        [excp raise];
    }
    //计算文件夹尺寸过程异步执行
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSInteger totalSize = 0;
        //获取文件夹下的所有子路径(包括子路径的子路径)
        NSArray *subPaths = [manager subpathsAtPath:directoryPath];
        //遍历所有子路径
        for (NSString *subPath in subPaths) {
            //获取文件的全路径：目标文件夹+子路径
            NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
            //判断隐藏文件
            if ([filePath containsString:@".DS"]) continue;
            //判断是否是文件夹
            BOOL isDirectory;
            BOOL isExist = [manager fileExistsAtPath:filePath isDirectory:&isDirectory];
            if (!isExist || isDirectory) continue;
            //获取文件属性
            NSDictionary *attr = [manager attributesOfItemAtPath:filePath error:nil];
            NSInteger fileSize = attr.fileSize;
            //所有文件的尺寸
            totalSize += fileSize;
        }
        //计算完成之后回调，药回到主线程
        //因为异步执行不能马上获取数据，等计算完成后再执行
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (completion) {
                //把数据传出去
                completion(totalSize);
            }
        });
    });
}
@end
