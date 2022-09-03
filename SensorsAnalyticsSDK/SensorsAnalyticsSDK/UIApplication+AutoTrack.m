//
//  UIApplication+AutoTrack.m
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 17/3/22.
//  Copyright (c) 2017年 SensorsData. All rights reserved.
//

#import "UIApplication+AutoTrack.h"
#import "SALogger.h"
#import "SensorsAnalyticsSDK.h"
#import "AutoTrackUtils.h"

@implementation UIApplication (AutoTrack)

- (BOOL)sa_sendAction:(SEL)action to:(id)to from:(id)from forEvent:(UIEvent *)event {

    /*
     默认先执行 AutoTrack
     如果先执行原点击处理逻辑，可能已经发生页面 push 或者 pop，导致获取当前 ViewController 不正确