//
//  CXUMSocial.m
//  友盟
//
//  Created by 陈晓 on 2016/12/11.
//  Copyright © 2016年 陈晓. All rights reserved.
//

#import "CXUMSocial.h"
#import <SVProgressHUD.h>
#import <WSProgressHUD.h>

#pragma mark ----  字符串判断 ----
///判断字符串是否 为 Url
@interface NSObject (urlBOOL)
- (BOOL)urlBOOL;
@end
@implementation NSObject (urlBOOL)
- (BOOL)urlBOOL {
    if([self isKindOfClass:[NSNull class]]) {
        return NO;
    }
    else if([self isKindOfClass:[NSString class]] && [(NSString *)self isEqualToString:@""]){
        return NO;
    }
    else if(![self isKindOfClass:[NSString class]]) {
        return NO;
    }
    else if ([(NSString *)self rangeOfString:@"http://"].location != NSNotFound ) {
        return YES;
    }
    else if ([(NSString *)self rangeOfString:@"https://"].location != NSNotFound ) {
        return YES;
    }
    else {
        return NO;
    }
}
@end

NSString *GHSNonEmptyString(id obj);
NSString* GHSNonEmptyString(id obj){
    if ([obj isKindOfClass:[NSString class]] && [obj length]>0 && [obj isEqualToString:@"<null>"]) {
        return @"";
    }else if (obj == nil || obj == [NSNull null] || ([obj isKindOfClass:[NSString class]] && [obj length] == 0)) {
        return @"";
    }else if ([obj isKindOfClass:[NSNumber class]] && [obj integerValue]>0)
    {
        return GHSNonEmptyString([obj stringValue]);
    }
    return obj;
}

//判断字符串是否为空
BOOL GHSIsStringWithAnyText(id object);
BOOL GHSIsStringWithAnyText(id object) {
    
    object = GHSNonEmptyString(object);
    return [object isKindOfClass:[NSString class]] && [(NSString*)object length] > 0;
}

#pragma mark ----  根据图片名称取资源 ----
UIImage* GHSImageNamed(NSString *imageName);
#define iPhone5 (CGSizeEqualToSize(CGSizeMake(320, 568), [UIScreen mainScreen].bounds.size) ? YES : NO)

UIImage* GHSImageNamed(NSString *imageName) {
    if (iPhone5) {
        if ([[imageName lowercaseString] hasSuffix:@".png"] ||
            [[imageName lowercaseString] hasSuffix:@".jpg"] ||
            [[imageName lowercaseString] hasSuffix:@".gif"]) {
            NSString *name = [NSString stringWithFormat:@"%@-568h@2x%@",
                              [imageName substringToIndex:(imageName.length - 4)],
                              [imageName substringFromIndex:(imageName.length - 4)]];
            UIImage *image = [UIImage imageNamed:name];
            if (image) {
                return image;
            }
        }
    }
    return [UIImage imageNamed:imageName];
}

typedef void(^SHARECompletion)(NSString * result);
@implementation CXUMSocial
{
    NSString *_title;
    NSString *_content;
    id  _image;
    NSString *_url;
    SHARECompletion _shareCompletion;
}
+ (instancetype)defaultSocialManager
{
    static CXUMSocial *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (mgr == nil) {
            mgr = [[CXUMSocial alloc] init];
        }
    });
    return mgr;
}
/*
 * 分享应用
 */
- (void)shareAppWithTitle:(NSString *)title content:(NSString *)content image:(NSString *)image url:(NSString *)url completion:(void (^)(NSString *))completion
{
    //不显示QQ空间和复制链接
    [UMSocialUIManager removeAllCustomPlatformWithoutFilted];
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_WechatSession), @(UMSocialPlatformType_WechatTimeLine)]];
    _title = title;
    _content = content;
    _image = [self dataContent:image];
    _url = url;
    [self shareWeb];
    _shareCompletion = completion;
}
/*
 * 分享图片
 */
- (void)shareImageWithImage:(UIImage *)image completion:(void (^)(NSString *))completion
{
    //显示6个
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_WechatSession), @(UMSocialPlatformType_WechatTimeLine), @(UMSocialPlatformType_Qzone)]];
    _image = image;
    [self shareImage];
    _shareCompletion = completion;
}
/*
 * 分享内容
 */
- (void)shareTopicWithTitle:(NSString *)title content:(NSString *)content image:(NSString *)image url:(NSString *)url completion:(void (^)(NSString *))completion
{
    //显示6个
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_WechatSession), @(UMSocialPlatformType_WechatTimeLine), @(UMSocialPlatformType_Qzone)]];
    _title = title;
    _content = content;
    _image = [self dataContent:image];
    _url = url;
    [self shareWeb];
    _shareCompletion = completion;
}
/*
 * 分享音乐
 */
- (void)shareMusicWithTitle:(NSString *)title content:(NSString *)content image:(NSString *)image url:(NSString *)url completion:(void(^)(NSString *))completion
{
    //显示6个
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_Sina),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_WechatSession), @(UMSocialPlatformType_WechatTimeLine), @(UMSocialPlatformType_Qzone)]];
    _title = title;
    _content = content;
    _image = [self dataContent:image];
    _url = url;
    [self shareMusic];
    _shareCompletion = completion;
}
- (void)shareImage
{
    //自定义分享面板
    [self setupShareUI];
    //显示分享面板
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        if (platformType == UMSocialPlatformType_QQ) {//QQ
            [self shareImageToPlatformType:UMSocialPlatformType_QQ];
        } else if (platformType == UMSocialPlatformType_WechatSession) {//微信好友
            [self shareImageToPlatformType:UMSocialPlatformType_WechatSession];
        } else if (platformType == UMSocialPlatformType_WechatTimeLine) {//朋友圈
            [self shareImageToPlatformType:UMSocialPlatformType_WechatTimeLine];
        } else if (platformType == UMSocialPlatformType_Sina) {//微博
            [self shareImageToPlatformType:UMSocialPlatformType_Sina];
        } else if (platformType == UMSocialPlatformType_Qzone) {//QQ
            [self shareImageToPlatformType:UMSocialPlatformType_Qzone];
        }
    }];
}
- (void)shareMusic
{
    //自定义分享面板
    [self setupShareUI];
    //显示分享面板
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        if (platformType == UMSocialPlatformType_QQ) {//QQ
            [self shareMusicToPlatformType:UMSocialPlatformType_QQ];
        } else if (platformType == UMSocialPlatformType_WechatSession) {//微信好友
            [self shareMusicToPlatformType:UMSocialPlatformType_WechatSession];
        } else if (platformType == UMSocialPlatformType_WechatTimeLine) {//朋友圈
            [self shareMusicToPlatformType:UMSocialPlatformType_WechatTimeLine];
        } else if (platformType == UMSocialPlatformType_Sina) {//微博
            [self shareMusicToPlatformType:UMSocialPlatformType_Sina];
        } else if (platformType == UMSocialPlatformType_Qzone) {//QQ
            [self shareMusicToPlatformType:UMSocialPlatformType_Qzone];
        }
    }];
}
- (void)shareWeb
{
    //自定义分享面板
    [self setupShareUI];
    //显示分享面板
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        if (platformType == UMSocialPlatformType_QQ) {//QQ
            [self shareWebPageToPlatformType:UMSocialPlatformType_QQ];
        } else if (platformType == UMSocialPlatformType_WechatSession) {//微信好友
            [self shareWebPageToPlatformType:UMSocialPlatformType_WechatSession];
        } else if (platformType == UMSocialPlatformType_WechatTimeLine) {//朋友圈
            [self shareWebPageToPlatformType:UMSocialPlatformType_WechatTimeLine];
        } else if (platformType == UMSocialPlatformType_Sina) {//微博
            [self shareTextToPlatformType:UMSocialPlatformType_Sina];
        } else if (platformType == UMSocialPlatformType_Qzone) {//QQ
            [self shareWebPageToPlatformType:UMSocialPlatformType_Qzone];
        }
    }];
}
/*
 * 复制链接
 */
- (void)copyLink
{
    [UMSocialUIManager addCustomPlatformWithoutFilted:UMSocialPlatformType_Copy
                                     withPlatformIcon:[UIImage imageNamed:@"umsocial_default"]
                                     withPlatformName:@"复制链接"];
    [UMSocialShareUIConfig shareInstance].sharePageGroupViewConfig.sharePageGroupViewPostionType = UMSocialSharePageGroupViewPositionType_Bottom;
    [UMSocialShareUIConfig shareInstance].sharePageScrollViewConfig.shareScrollViewPageItemStyleType = UMSocialPlatformItemViewBackgroudType_None;
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        //在回调里面获得点击的
        if (platformType == UMSocialPlatformType_Copy) {
            UIPasteboard *pastboad = [UIPasteboard generalPasteboard];
            pastboad.string = _url;
            [WSProgressHUD showImage:nil status:@"复制成功"];
        }
    }];
}
/*
 * 分享图片
 */
- (void)shareImageToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建图片内容对象
    UMShareImageObject *shareObject = [[UMShareImageObject alloc] init];
    //如果有缩略图，则设置缩略图
    shareObject.thumbImage = _image;
    [shareObject setShareImage:_image];
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        [self error:error];
    }];
}
/*
 * 分享文本
 */
- (void)shareTextToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    //设置文本
    messageObject.text = [NSString stringWithFormat:@"%@ %@", _content, _url];
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        [self error:error];
    }];
}
/*
 * 分享网页
 */
- (void)shareWebPageToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:_title descr:_content thumImage:_image];
    //设置网页地址
    shareObject.webpageUrl =_url;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        [self error:error];
    }];
}
/*
 * 分享歌曲
 */
- (void)shareMusicToPlatformType:(UMSocialPlatformType)platformType
{
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建音乐内容对象
    UMShareMusicObject *shareObject = [UMShareMusicObject shareObjectWithTitle:_title descr:_content thumImage:_image];
    //设置音乐网页播放地址
    shareObject.musicUrl = _url;
    //            shareObject.musicDataUrl = @"这里设置音乐数据流地址（如果有的话，而且也要看所分享的平台支不支持）";
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        [self error:error];
    }];
}
- (void)error:(NSError *)error
{
    if(error) {
        NSInteger errorCode = error.code;
        if (errorCode == UMSocialPlatformErrorType_Cancel) {
            [SVProgressHUD showErrorWithStatus:@"分享取消"];
        } else {
            [SVProgressHUD showErrorWithStatus:@"分享失败"];
        }
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}
- (void)setupShareUI
{
    //自定义分享面板
    [UMSocialShareUIConfig shareInstance].shareTitleViewConfig.isShow = NO;
    [UMSocialShareUIConfig shareInstance].sharePageGroupViewConfig.sharePageGroupViewMaskColor = [UIColor lightGrayColor];//分享菜单上面view的背景色
    [UMSocialShareUIConfig shareInstance].sharePageGroupViewConfig.sharePageGroupViewMaskViewAlpha = 0.8;
    //以下三句设置整个面板的背景颜色为白色
    [UMSocialShareUIConfig shareInstance].sharePageScrollViewConfig.shareScrollViewBackgroundColor = [UIColor whiteColor];
    [UMSocialShareUIConfig shareInstance].sharePageScrollViewConfig.shareScrollViewPageBGColor = [UIColor whiteColor];
    [UMSocialShareUIConfig shareInstance].shareContainerConfig.isShareContainerHaveGradient = false;
    [UMSocialShareUIConfig shareInstance].shareCancelControlConfig.shareCancelControlBackgroundColor = [UIColor whiteColor];
    //设置按钮里icon的宽高
    [UMSocialShareUIConfig shareInstance].sharePageScrollViewConfig.shareScrollViewPageMaxItemIconWidth = 50;
    [UMSocialShareUIConfig shareInstance].sharePageScrollViewConfig.shareScrollViewPageMaxItemIconHeight = 50;
}
/*
 * 字符串转NDSata
 */
- (NSData *)dataContent:(NSString *)string {
    if(!GHSIsStringWithAnyText(string)) {
        return nil;
    }
    if([string urlBOOL]) {
        return [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]] returningResponse:NULL error:NULL];;
    }
    else {
        NSData * data =  UIImagePNGRepresentation([UIImage imageNamed:string]);
        if(data.length > 0) {
            return [NSData data];
        }
        if ([[NSFileManager defaultManager] fileExistsAtPath:string])
        {
            return  [NSData dataWithContentsOfFile:string];
        }
        else {
            NSLog(@"分享的图片地址 不存在");
        }
        return nil;
    }
}
@end
