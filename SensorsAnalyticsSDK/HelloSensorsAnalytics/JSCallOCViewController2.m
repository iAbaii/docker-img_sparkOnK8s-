//
//  JSCallOCViewController2.m
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 16/9/6.
//  Copyright © 2016年 SensorsData. All rights reserved.
//

#import "JSCallOCViewController2.h"
#import "SensorsAnalyticsSDK.h"
@import WebKit;

@interface JSCallOCViewController2 ()<WKNavigationDelegate, WKUIDelegate>
@property WKWebView *webView;
@end
@implementation JSCallOCViewContr