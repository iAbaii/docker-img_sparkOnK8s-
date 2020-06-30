//
//  SAEventBinding.m
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/20/16
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//

#import "SAEventBinding.h"
#import "SALogger.h"
#import "SAUIControlBinding.h"
#import "SAUITableViewBinding.h"
#import "SensorsAnalyticsSDK.h"

@implementation SAEventBinding

+ (SAEventBinding *)bindingWithJSONObject:(NSDictionary *)object {
    if (object 