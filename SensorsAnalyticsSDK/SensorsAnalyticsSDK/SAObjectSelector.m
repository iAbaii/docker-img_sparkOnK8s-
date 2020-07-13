
//
//  ObjectSelector.m
//  SensorsAnalyticsSDK
//
//  Created by 雨晗 on 1/20/16
//  Copyright (c) 2016年 SensorsData. All rights reserved.
//
///  Created by Alex Hofsteede on 5/5/14.
///  Copyright (c) 2014 Mixpanel. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>

#import "NSData+SABase64.h"
#import "SALogger.h"
#import "SAObjectSelector.h"

@interface SAObjectFilter : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, assign) BOOL unique;
@property (nonatomic, assign) BOOL nameOnly;

- (NSArray *)apply:(NSArray *)views;
- (NSArray *)applyReverse:(NSArray *)views;
- (BOOL)appliesTo:(NSObject *)view;
- (BOOL)appliesToAny:(NSArray *)views;

@end

@interface SAObjectSelector () {
    NSCharacterSet *_classAndPropertyChars;
    NSCharacterSet *_separatorChars;
    NSCharacterSet *_predicateStartChar;
    NSCharacterSet *_predicateEndChar;
    NSCharacterSet *_flagStartChar;
    NSCharacterSet *_flagEndChar;

}

@property (nonatomic, strong) NSScanner *scanner;
@property (nonatomic, strong) NSArray *filters;

@end

@implementation SAObjectSelector

+ (SAObjectSelector *)objectSelectorWithString:(NSString *)string {
    return [[SAObjectSelector alloc] initWithString:string];
}

- (instancetype)initWithString:(NSString *)string {
    if (self = [super init]) {
        _string = string;
        _scanner = [NSScanner scannerWithString:string];
        [_scanner setCharactersToBeSkipped:nil];
        _separatorChars = [NSCharacterSet characterSetWithCharactersInString:@"/"];
        _predicateStartChar = [NSCharacterSet characterSetWithCharactersInString:@"["];
        _predicateEndChar = [NSCharacterSet characterSetWithCharactersInString:@"]"];
        _classAndPropertyChars = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.*"];
        _flagStartChar = [NSCharacterSet characterSetWithCharactersInString:@"("];
        _flagEndChar = [NSCharacterSet characterSetWithCharactersInString:@")"];

        NSMutableArray *filters = [NSMutableArray array];
        SAObjectFilter *filter;
        BOOL isRoot = true;
        while((filter = [self nextFilter])) {
            // RootViewController不写入filters中
            if (isRoot) {
                isRoot = false;
                continue;
            }
            [filters addObject:filter];
        }
        self.filters = [filters copy];
    }
    return self;
}

/*
 Starting at the root object, try and find an object
 in the view/controller tree that matches this selector.
*/

- (NSArray *)selectFromRoot:(id)root {
    return [self selectFromRoot:root evaluatingFinalPredicate:YES];
}

- (NSArray *)fuzzySelectFromRoot:(id)root {
    return [self selectFromRoot:root evaluatingFinalPredicate:NO];
}

- (NSArray *)selectFromRoot:(id)root evaluatingFinalPredicate:(BOOL)finalPredicate {
    NSArray *views = @[];
    if (root) {
        views = @[root];

        for (NSUInteger i = 0, n = [_filters count]; i < n; i++) {
            SAObjectFilter *filter = _filters[i];
            filter.nameOnly = (i == n-1 && !finalPredicate);
            views = [filter apply:views];
            if ([views count] == 0) {
                break;
            }
        }
    }
    return views;
}


/*
 Starting at a leaf node, determine if it would be selected
 by this selector starting from the root object given.
 */

- (BOOL)isLeafSelected:(id)leaf fromRoot:(id)root {