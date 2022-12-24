//
//  UIImage.m
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 2017/6/13.
//  Copyright © 2017年 SensorsData. All rights reserved.
//

#import "UIImage+AutoTrack.h"
#import "SensorsAnalyticsSDK.h"
#import "SALogger.h"
#import "SASwizzle.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation UIImage (AutoTrack)
#ifndef SENSORS_ANALYTICS_DISABLE_AUTOTRACK_UIIMAGE_IMAGENAME
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @try {
            Class selfClass = object_getClass([self class]);
            
  