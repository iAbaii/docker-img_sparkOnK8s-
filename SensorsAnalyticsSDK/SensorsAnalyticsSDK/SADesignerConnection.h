//
//  SADesignerConnection.h
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/18/16.
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
/// Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SAWebSocket.h"

@protocol SADesignerMessage;

@interface SADesignerConnection : NSObject

@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, assign) BOOL sessionEnded;
@property (nonatomic, assign) BOOL useGzip;

- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSUR