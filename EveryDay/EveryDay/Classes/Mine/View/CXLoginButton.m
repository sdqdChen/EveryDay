//
//  CXLoginButton.m
//  EveryDay
//
//  Created by 陈晓 on 2017/1/13.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import "CXLoginButton.h"
#import "CXLoginRegisterViewController.h"
#import "CXNavigationController.h"
#import "CXUserDefaults.h"
#import "CXAlertController.h"
#import <Photos/Photos.h>
#import <SVProgressHUD.h>
#import <RSKImageCropper.h>
#import "UIImage+CXImage.h"
#import <MaxLeap/MaxLeap.h>


@interface CXLoginButton () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, RSKImageCropViewControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *pickVc;
/** 当前用户 */
@property (nonatomic, strong) MLUser *currentUser;
/** 导航控制器 */
@property (nonatomic, strong) CXNavigationController *nav;
@end

@implementation CXLoginButton
#pragma mark - 懒加载
- (UIImagePickerController *)pickVc
{
    if (!_pickVc) {
        _pickVc = [[UIImagePickerController alloc] init];
    }
    return _pickVc;
}
- (MLUser *)currentUser
{
    if (!_currentUser) {
        _currentUser = [MLUser currentUser];
    }
    return _currentUser;
}
- (CXNavigationController *)nav
{
    if (!_nav) {
        _nav = (CXNavigationController *)self.window.rootViewController;
    }
    return _nav;
}
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        //根据是否登录设置不同图片
        if ([CXUserDefaults readBoolForKey:LoginSuccess]) { //已经登录
            //先从本地缓存中取
            UIImage *avator = [self readImageFromCache];
            if (avator) {
                [self setBackgroundImage:avator forState:UIControlStateNormal];
            } else { //本地缓存没有就从服务器取
                [self readImageFromServer];
            }
        } else { //未登录
            [self setBackgroundImage:[UIImage imageNamed:@"loginButton"] forState:UIControlStateNormal];
        }
        self.frame =  CGRectMake(0, 0, loginButtonW * KRATE, loginButtonW * KRATE);
        [self addTarget:self action:@selector(loginButtonClick) forControlEvents:UIControlEventTouchUpInside];
        //添加通知
        [self addNotification];
    }
    return self;
}
/*
 * 取消按钮高亮
 */
- (void)setHighlighted:(BOOL)highlighted
{
    
}
#pragma mark - 通知
- (void)addNotification
{
    //监听登录成功的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:CXLoginSuccessNotification object:nil];
    //退出登录的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut) name:CXLoginOutNotification object:nil];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CXLoginSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CXLoginOutNotification object:nil];
}
#pragma mark - 监听事件
/*
 * 点击登录
 */
- (void)loginButtonClick
{
    if ([CXUserDefaults readBoolForKey:LoginSuccess]) { //已登录
        //弹框提示是否修改头像
        [CXAlertController alertSureAndCancelWithTitle:@"修改头像?" message:nil sureHandler:^(UIAlertAction *action) {
            [self editAvatarWith:self.nav];
        } cancelHandler:nil viewController:self.nav];
    } else { //未登录
        CXLoginRegisterViewController *loginVc = [[CXLoginRegisterViewController alloc] init];
        [self.nav presentViewController:loginVc animated:YES completion:nil];
    }
}
/*
 * 如果登录成功-设置默认头像
 */
- (void)loginSuccess
{
    //先从本地缓存中取
    UIImage *avator = [self readImageFromCache];
    if (avator) {
        [self setBackgroundImage:avator forState:UIControlStateNormal];
    } else { //本地缓存没有就从服务器取
        [self readImageFromServer];
    }
}
/*
 * 退出登录
 */
- (void)loginOut
{
    [self setBackgroundImage:[UIImage imageNamed:@"loginButton"] forState:UIControlStateNormal];
}
#pragma mark - 修改头像
- (void)editAvatarWith:(UIViewController *)viewController
{
    [CXAlertController alertForEditAvatorWithCameraHandler:^(UIAlertAction *action) {
        [self openCamera];
    } photoHandler:^(UIAlertAction *action) {
        [self openPhotoAlbum];
    } viewController:viewController];
}
#pragma mark - 打开相机
- (void)openCamera
{
    self.pickVc.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.pickVc.delegate = self;
    //判断相机授权状态
    [self judgeCameraAuthorizationStatus];
}
/*
 * 判断相机授权状态
 */
- (void)judgeCameraAuthorizationStatus
{
    //判断授权状态
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) { //用户接受
                [self.nav presentViewController:self.pickVc animated:YES completion:nil];
            } else { //用户拒绝
                if (status == AVAuthorizationStatusDenied) { //不是第一次拒绝
                    [self remindUserAuthWithTitle:@"相机访问受限" message:@"请前往设置-隐私-相机开启相册访问权限"];
                }
            }
        });
    }];
}
#pragma mark - 打开相册
- (void)openPhotoAlbum
{
    self.pickVc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    self.pickVc.delegate = self;
    [self judgePhotoAuthorizationStatus];
}
/*
 * 判断相册授权状态
 */
- (void)judgePhotoAuthorizationStatus
{
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusDenied) { //用户第一次拒绝
                if (oldStatus != PHAuthorizationStatusNotDetermined) { //用户拒绝之后还想修改头像
                    [self remindUserAuthWithTitle:@"相册访问受限" message:@"请前往设置-隐私-照片开启相册访问权限"];
                }
            } else if (status == PHAuthorizationStatusAuthorized) { //用户同意
                [self.nav presentViewController:self.pickVc animated:YES completion:nil];
            } else if (status == PHAuthorizationStatusRestricted) { //系统原因无法访问
                [SVProgressHUD showErrorWithStatus:@"因系统原因，无法访问相册！"];
            }
        });
    }];
}
/*
 * 提醒用户授权
 */
- (void)remindUserAuthWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:sure];
    [self.nav presentViewController:alert animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate
/*
 * 从相册选取或拍照完成都会调用
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    RSKImageCropViewController *imageVc = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCircle];
    imageVc.delegate = self;
    [picker pushViewController:imageVc animated:YES];
}
#pragma mark - RSKImageCropViewControllerDelegate
/*
 * 取消裁剪
 */
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.pickVc popViewControllerAnimated:YES];
}
/*
 * 裁剪成功
 */
- (void)imageCropViewController:(RSKImageCropViewController *)controller
                   didCropImage:(UIImage *)croppedImage
                  usingCropRect:(CGRect)cropRect
{
    //裁剪圆形图片
    UIImage *circleImage = [UIImage imageCircledWithimage:croppedImage];
    //压缩图片
    UIImage *newImage = [UIImage scaleToSize:circleImage size:CGSizeMake(200, 200)];
    //更改头像
    [self setBackgroundImage:newImage forState:UIControlStateNormal];
    NSData *imageData = UIImageJPEGRepresentation(newImage, 0.5);
    //保存头像到本地
    [self saveToCacheWithData:imageData];
    //保存头像到服务器
    [self saveToServerWithData:imageData];
    //退出
    [self.pickVc dismissViewControllerAnimated:YES completion:nil];
    [self.pickVc popViewControllerAnimated:YES];
}
#pragma mark - 保存和读取头像
/*
 * 保存头像到本地
 */
- (void)saveToCacheWithData:(NSData *)data
{
    NSString *filePath = [CachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", self.currentUser.objectId]];
    [data writeToFile:filePath atomically:YES];
}
/*
 * 保存修改后的头像到服务器
 */
- (void)saveToServerWithData:(NSData *)data
{
    MLFile *file = [MLFile fileWithName:@"avatar.jpg" data:data];
    self.currentUser[@"avatar"] = file;
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            CXLog(@"%@", error);
        } else {
            CXLog(@"成功");
        }
    }];
}
/*
 * 从本地读取头像
 */
- (UIImage *)readImageFromCache
{
    NSString *filePath = [CachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", self.currentUser.objectId]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return [UIImage imageWithData:data];
}
/*
 * 从服务器读取头像
 */
- (void)readImageFromServer
{
    MLFile *file = [MLUser currentUser][@"avatar"];
    [file getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        UIImage *image = [UIImage imageWithData:data];
        if (image) {
            [self setBackgroundImage:image forState:UIControlStateNormal];
        } else { //服务器也没有就设置默认头像
            [self setBackgroundImage:[UIImage imageNamed:@"avatar"] forState:UIControlStateNormal];
        }
    }];
}
@end
