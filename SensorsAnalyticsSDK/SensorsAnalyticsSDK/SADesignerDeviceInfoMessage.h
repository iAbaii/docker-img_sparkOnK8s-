//
//  SADesignerDeviceInfoMessage.h
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/18/16.
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
/// Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAAbstractDesignerMessage.h"

#pragma mark -- DeviceInfo Request

extern NSString *const SADesignerDeviceInfoRequestMessageType;

@interface SADesignerDeviceInfoRequestMessage : SAAbstractDesignerMessage

@end

#pragma mark -- DeviceInfo Response

@interface SADesignerDeviceInfoResponseMessage : SAAbstractDesignerMessage

+ (instancetype)message;

@property (nonatomic, co