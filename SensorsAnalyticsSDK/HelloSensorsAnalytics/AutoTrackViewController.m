//
//  AutoTrackViewController.m
//  SensorsAnalyticsSDK
//
//  Created by 王灼洲 on 2017/4/27.
//  Copyright © 2017年 SensorsData. All rights reserved.
//

#import "AutoTrackViewController.h"

@interface AutoTrackViewController ()

@end

@implementation AutoTrackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _myLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer al