
//
//  SADesignerDeviceInfoMessage.m
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/18/16.
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
/// Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SADesignerConnection.h"
#import "SADesignerDeviceInfoMessage.h"
#import "SensorsAnalyticsSDK.h"

#pragma mark -- DeviceInfo Request

NSString *const SADesignerDeviceInfoRequestMessageType = @"device_info_request";

@implementation SADesignerDeviceInfoRequestMessage

+ (instancetype)message {
    return [(SADesignerDeviceInfoRequestMessage *)[self alloc] initWithType:SADesignerDeviceInfoRequestMessageType];
}

+ (NSString *)defaultDeviceId{
    // 优先使用IDFV
    if (NSClassFromString(@"UIDevice")) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    
    // 没有IDFV，则肯定有UUID，此时使用UUID
    return [[NSUUID UUID] UUIDString];
}

- (NSOperation *)responseCommandWithConnection:(SADesignerConnection *)connection {
    __weak SADesignerConnection *weak_connection = connection;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        __strong SADesignerConnection *conn = weak_connection;
        
        SADesignerDeviceInfoResponseMessage *deviceInfoResponseMessage = [SADesignerDeviceInfoResponseMessage message];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            // 服务端是否支持 Payload 压缩
            id supportGzip = [self payloadObjectForKey:@"support_gzip"];
            conn.useGzip = (supportGzip == nil) ? NO : [supportGzip boolValue];
            
            UIDevice *currentDevice = [UIDevice currentDevice];
            struct CGSize size = [UIScreen mainScreen].bounds.size;
            
            deviceInfoResponseMessage.libName = @"iOS";
            deviceInfoResponseMessage.libVersion = [[SensorsAnalyticsSDK sharedInstance] libVersion];
            deviceInfoResponseMessage.systemName = currentDevice.systemName;
            deviceInfoResponseMessage.systemVersion = currentDevice.systemVersion;
            deviceInfoResponseMessage.screenHeight = [NSString stringWithFormat:@"%ld", (long)size.height];
            deviceInfoResponseMessage.screenWidth = [NSString stringWithFormat:@"%ld", (long)size.width];
            deviceInfoResponseMessage.mainBundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            deviceInfoResponseMessage.deviceId = [[self class] defaultDeviceId];
            deviceInfoResponseMessage.deviceName = currentDevice.name;
            deviceInfoResponseMessage.deviceModel = currentDevice.model;
            deviceInfoResponseMessage.appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
        });
        
        [conn sendMessage:deviceInfoResponseMessage];
    }];
    
    return operation;
}

@end

#pragma mark -- DeviceInfo Response

@implementation SADesignerDeviceInfoResponseMessage

+ (instancetype)message {
    return [(SADesignerDeviceInfoResponseMessage *)[self alloc] initWithType:@"device_info_response"];
}

- (NSString *)libName {
    return [self payloadObjectForKey:@"$lib"];
}

- (void)setLibName:(NSString *) libName {
    [self setPayloadObject:libName forKey:@"$lib"];
}

- (NSString *)systemName {
    return [self payloadObjectForKey:@"$os"];
}

- (void)setSystemName:(NSString *)systemName {
    [self setPayloadObject:systemName forKey:@"$os"];
}

- (NSString *)systemVersion {
    return [self payloadObjectForKey:@"$os_version"];
}

- (void)setSystemVersion:(NSString *)systemVersion {
    [self setPayloadObject:systemVersion forKey:@"$os_version"];
}