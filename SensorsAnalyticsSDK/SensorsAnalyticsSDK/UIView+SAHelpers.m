
//
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
/// Copyright (c) 2014 Mixpanel. All rights reserved.

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>
#import "UIView+SAHelpers.h"
#import "SALogger.h"

// NB If you add any more fingerprint methods, increment this.
#define MP_FINGERPRINT_VERSION 1

@implementation UIView (SAHelpers)

- (int)mp_fingerprintVersion {
    return MP_FINGERPRINT_VERSION;
}

- (UIImage *)sa_snapshotImage {
    CGFloat offsetHeight = 0.0f;
    
    //Avoid the status bar on phones running iOS < 7
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending &&
        ![UIApplication sharedApplication].statusBarHidden) {
        offsetHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    CGSize size = self.layer.bounds.size;
    size.height -= offsetHeight;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0f, -offsetHeight);
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:CGRectMake(0.0f, 0.0f, size.width, size.height) afterScreenUpdates:YES];
    } else {
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
#else
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
#endif

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)sa_snapshotForBlur {
    UIImage *image = [self sa_snapshotImage];
    // hack, helps with colors when blurring