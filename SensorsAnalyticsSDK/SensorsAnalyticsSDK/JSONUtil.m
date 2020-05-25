
//
//  JSONUtil.m
//  SensorsAnalyticsSDK
//
//  Created by 曹犟 on 15/7/7.
//  Copyright (c) 2015年 SensorsData. All rights reserved.
//

#import "JSONUtil.h"
#import "SALogger.h"

@implementation JSONUtil {
    NSDateFormatter *_dateFormatter;
}

- (id)init {
    self = [super init];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
    return self;
}

/**
 *  @abstract
 *  把一个Object转成Json字符串
 *
 *  @param obj 要转化的对象Object
 *
 *  @return 转化后得到的字符串
 */