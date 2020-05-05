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
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
    
    [_myLabel addGestureRecognizer:labelTapGestureRecognizer];
    
    [_myUISwitch addTarget:self action:@selector(picSwitchClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _myButton1.sensorsAnalyticsDelegate = self;
}

-(void)picSwitchClick:(UISwitch *)sender {

}

-(void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    UILabel *label=(