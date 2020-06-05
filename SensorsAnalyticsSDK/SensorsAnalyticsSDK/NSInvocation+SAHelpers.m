//
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
/// Copyright (c) 2014 Mixpanel. All rights reserved.

#import <objc/runtime.h>
#import "SALogger.h"
#import "NSInvocation+SAHelpers.h"

typedef union {
    char                    _chr;
    unsigned char           _uchr;
    short                   _sht;
    unsigned short          _usht;
    int                     _int;
    unsigned int            _uint;
    long                    _lng;
    unsigned long           _ulng;
    lon