//  SensorsAnalyticsSDK.m
//  SensorsAnalyticsSDK
//
//  Created by 曹犟 on 15/7/1.
//  Copyright (c) 2015年 SensorsData. All rights reserved.

#import <objc/runtime.h>
#include <sys/sysctl.h>
#include <stdlib.h>

#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>

#import "JSONUtil.h"
#import "SAGzipUtility.h"
#import "MessageQueueBySqlite.h"
#import "NSData+SABase64.h"
#import "SADesignerConnection.h"
#import "SADesignerEventBindingMessage.h"
#import "SADesignerSessionCollection.h"
#import "SAEventBinding.h"
#import "SALogger.h"
#import "SAReachability.h"
#import "SASwizzler.h"
#import "SensorsAnalyticsSDK.h"
#import "JSONUtil.h"
#import "UIApplication+AutoTrack.h"
#import "UIViewController+AutoTrack.h"
#import "SASwizzle.h"
#import "AutoTrackUtils.h"
#import "NSString+HashCode.h"
#import "SensorsAnalyticsExceptionHandler.h"
#define VERSION @"1.8.12"

#import "UIWindow+SASnapshotImage.h"

#define PROPERTY_LENGTH_LIMITATION 819100



// 自动追踪相关事件及属性
// App 启动或激活
NSString* const APP_START_EVENT = @"$AppStart";
// App 退出或进入后台
NSString* const APP_END_EVENT = @"$AppEnd";
// App 浏览页面
NSString* const APP_VIEW_SCREEN_EVENT = @"$AppViewScreen";
// App 首次启动
NSString* const APP_FIRST_START_PROPERTY = @"$is_first_time";
// App 是否从后台恢复
NSString* const RESUME_FROM_BACKGROUND_PROPERTY = @"$resume_from_background";
// App 浏览页面名称
NSString* const SCREEN_NAME_PROPERTY = @"$screen_name";
// App 浏览页面 Url
NSString* const SCREEN_URL_PROPERTY = @"$url";
// App 浏览页面 Referrer Url
NSString* const SCREEN_REFERRER_URL_PROPERTY = @"$referrer";

// APP 截屏行为
NSString* const APP_DID_TAKE_SCREENSHOT = @"$take_screenshot";


@implementation SensorsAnalyticsDebugException

@end

@implementation UIImage (SensorsAnalytics)
- (NSString *)sensorsAnalyticsImageName {
    return objc_getAssociatedObject(self, @"sensorsAnalyticsImageName");
}

- (void)setSensorsAnalyticsImageName:(NSString *)sensorsAnalyticsImageName {
    objc_setAssociatedObject(self, @"sensorsAnalyticsImageName", sensorsAnalyticsImageName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end

@implementation UIView (SensorsAnalytics)
- (UIViewController *)viewController {
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewContr