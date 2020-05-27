//
//  MessageQueueBySqlite.h
//  SensorsAnalyticsSDK
//
//  Created by 曹犟 on 15/7/7.
//  Copyright (c) 2015年 SensorsData. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @abstract
 *  一个基于Sqlite封装的接口，用于向其中添加和获取数据
 */
@interface MessageQueueBySqlite : NSObject


/**
 *  @abstract
 *  根据传入的文件路径初始化
 *
 *  @param filePath 传入的数据文件路径
 *
 *  @