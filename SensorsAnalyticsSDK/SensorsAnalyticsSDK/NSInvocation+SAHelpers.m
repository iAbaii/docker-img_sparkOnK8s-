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
    long long               _lng_lng;
    unsigned long long      _ulng_lng;
    float                   _flt;
    double                  _dbl;
    _Bool                   _bool;
} MPObjCNumericTypes;

static void SAFree(void *p)
{
    if (p) {
        free(p);
    }
}

static void *SAAllocBufferForObjCType(const char *objCType)
{
    void *buffer = NULL;

    NSUInteger size, alignment;
    NSGetSizeAndAlignment(objCType, &size, &alignment);

    int result = posix_memalign(&buffer, MAX(sizeof(void *), alignment), size);
    if (result != 0) {
        SAError(@"Error allocating aligned memory: %s", strerror(result));
    }

    if (buffer