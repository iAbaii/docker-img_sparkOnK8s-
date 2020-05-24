
//
//  AutoTrackUtils.m
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 2017/6/29.
//  Copyright © 2017年 SensorsData. All rights reserved.
//

#import "AutoTrackUtils.h"
#import "SensorsAnalyticsSDK.h"
#import "SALogger.h"

@implementation AutoTrackUtils

+ (NSString *)contentFromView:(UIView *)rootView {
    @try {
        NSMutableString *elementContent = [NSMutableString string];
        for (UIView *subView in [rootView subviews]) {
            if (subView) {
                if (subView.sensorsAnalyticsIgnoreView) {
                    continue;
                }

                if ([subView isKindOfClass:[UIButton class]]) {
                    UIButton *button = (UIButton *)subView;
                    if ([button currentTitle] != nil && ![@"" isEqualToString:[button currentTitle]]) {
                        [elementContent appendString:[button currentTitle]];
                        [elementContent appendString:@"-"];
                    }
                } else if ([subView isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)subView;
                    if (label.text != nil && ![@"" isEqualToString:label.text]) {
                        [elementContent appendString:label.text];
                        [elementContent appendString:@"-"];
                    }
                } else if ([subView isKindOfClass:[UITextView class]]) {
                    UITextView *textView = (UITextView *)subView;
                    if (textView.text != nil && ![@"" isEqualToString:textView.text]) {
                        [elementContent appendString:textView.text];
                        [elementContent appendString:@"-"];
                    }
                } else if ([subView isKindOfClass:NSClassFromString(@"RTLabel")]) {//RTLabel:https://github.com/honcheng/RTLabel
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    if ([subView respondsToSelector:NSSelectorFromString(@"text")]) {
                        NSString *title = [subView performSelector:NSSelectorFromString(@"text")];
                        if (title != nil && ![@"" isEqualToString:title]) {
                            [elementContent appendString:title];
                            [elementContent appendString:@"-"];
                        }
                    }
                    #pragma clang diagnostic pop
                } else if ([subView isKindOfClass:NSClassFromString(@"YYLabel")]) {//RTLabel:https://github.com/ibireme/YYKit
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    if ([subView respondsToSelector:NSSelectorFromString(@"text")]) {
                        NSString *title = [subView performSelector:NSSelectorFromString(@"text")];
                        if (title != nil && ![@"" isEqualToString:title]) {
                            [elementContent appendString:title];
                            [elementContent appendString:@"-"];
                        }
                    }
                    #pragma clang diagnostic pop
                } else if ([subView isKindOfClass:[NSClassFromString(@"UITableViewCellContentView") class]] ||
                            [subView isKindOfClass:[NSClassFromString(@"UICollectionViewCellContentView") class]] ||
                            subView.subviews.count > 0){
                    NSString *temp = [self contentFromView:subView];
                    if (temp != nil && ![@"" isEqualToString:temp]) {
                        [elementContent appendString:temp];
                        //[elementContent appendString:@"-"];
                    }
                }
            }
        }
        return elementContent;
    } @catch (NSException *exception) {
        SAError(@"%@ error: %@", self, exception);
        return nil;
    }
}

+ (void)trackAppClickWithUICollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {