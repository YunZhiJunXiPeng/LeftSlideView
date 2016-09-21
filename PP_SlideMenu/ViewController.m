//
//  ViewController.m
//  PP_SlideMenu
//
//  Created by 小超人 on 16/8/21.
//  Copyright © 2016年 云之君兮鹏. All rights reserved.
//

#import "ViewController.h"
#import "PP_SlideMenuView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PP_SlideMenuView *slidetView = [PP_SlideMenuView shareSliderMenuView];
    [slidetView bindWithViewController:self];
    [self.view addSubview:slidetView];

   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
