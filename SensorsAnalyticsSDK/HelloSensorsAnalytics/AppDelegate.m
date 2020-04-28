//
//  AppDelegate.m
//  HelloSensorsAnalytics
//
//  Created by 曹犟 on 15/7/4.
//  Copyright (c) 2015年 SensorsData. All rights reserved.
//

#import "AppDelegate.h"

#import "SensorsAnalyticsSDK.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [SensorsAnalyticsSDK sharedInstanceWithServerURL:@"http://test-zouyuhan.cloud.sensorsdata.cn:8006/sa?project=wangzhuozhou&token=db52d13749514676"
                                     andConfigureURL:@"http://test-zouyuhan.cloud.sensorsdata.cn:8006/config/?project=wangzhuozhou"
                                        andDebugMode:SensorsAnalyticsDebugAndTrack];
//  