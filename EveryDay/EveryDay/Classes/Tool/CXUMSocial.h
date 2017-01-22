//
//  CXUMSocial.h
//  友盟
//
//  Created by 陈晓 on 2016/12/11.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UMSocialCore/UMSocialCore.h>
#import <UShareUI/UShareUI.h>

@interface CXUMSocial : NSObject
+ (instancetype)defaultSocialManager;
/*
 * 分享应用
 */
- (void)shareAppWithTitle:(NSString *)title content:(NSString *)content image:(NSString *)image url:(NSString *)url completion:(void(^)(NSString *))completion;
/*
 * 分享内容
 */
- (void)shareTopicWithTitle:(NSString *)title content:(NSString *)content image:(NSString *)image url:(NSString *)url completion:(void(^)(NSString *))completion;
/*
 * 分享图片
 */
- (void)shareImageWithImage:(UIImage *)image completion:(void (^)(NSString *))completion;
/*
 * 分享音乐
 */
- (void)shareMusicWithTitle:(NSString *)title content:(NSString *)content image:(NSString *)image url:(NSString *)url completion:(void(^)(NSString *))completion;
@end
