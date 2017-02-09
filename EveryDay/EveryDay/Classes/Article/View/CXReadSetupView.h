//
//  CXReadSetupView.h
//  EveryDay
//
//  Created by 陈晓 on 2017/2/8.
//  Copyright © 2017年 陈晓. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CXReadSetupView : UIView

@property (nonatomic, strong) UIWebView *webView;

+ (instancetype)loadFromXib;
@end
