//
//  ObjectSelector.h
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/20/16
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
///  Created by Alex Hofsteede on 5/5/14.
///  Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SAObjectSelector : NSObject

@property (nonatomic, strong, readonly) NSString *string;

+ (SAObjectSelector *)objectSelectorWithString:(NSString *)string;
- (instancetyp