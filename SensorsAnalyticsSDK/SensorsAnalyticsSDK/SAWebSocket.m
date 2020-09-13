
//
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
/// Copyright (c) 2014 Mixpanel. All rights reserved.
//

//
//   Portions Copyright 2012 Square Inc.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//

#import "SAWebSocket.h"

#if TARGET_OS_IPHONE
#define HAS_ICU
#endif

#ifdef HAS_ICU

#import <unicode/utf8.h>

#endif

#if TARGET_OS_IPHONE

#import <Endian.h>

#else

#import <CoreServices/CoreServices.h>

#endif

#import <CommonCrypto/CommonDigest.h>
#import <Security/SecRandom.h>
#import "SALogger.h"
#import "NSData+SABase64.h"

#if OS_OBJECT_USE_OBJC_RETAIN_RELEASE
#define sa_dispatch_retain(x)
#define sa_dispatch_release(x)
#define maybe_bridge(x) ((__bridge void *) x)
#else
#define sa_dispatch_retain(x) dispatch_retain(x)
#define sa_dispatch_release(x) dispatch_release(x)
#define maybe_bridge(x) (x)
#endif