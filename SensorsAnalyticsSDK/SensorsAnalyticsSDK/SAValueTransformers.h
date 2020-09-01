//
//  SAValueTransformers.h
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/20/16
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
///  Created by Alex Hofsteede on 5/5/14.
///  Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAPassThroughValueTransformer : NSValueTransformer

@end

@interface SABOOLToNSNumberValueTransformer : NSValueTransformer

@end

@interface SACATransform3DToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface SACGAffineTransformToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface SACGColorRefToNSStringValueTransformer : NSValueTransformer

@end

@interface SACGPointToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface SACGRectToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface SACGSizeToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface SANSAttributedStringToNSDictionaryValueTransformer : NSValueTransformer

@end

@interface SANSNumberToCGFloatValueTransformer : NSValueTransformer

@end

__unused static id transformValue(id value, NSString *toType) {
    assert(value != nil);

    if ([