//
//  PP_SlideMenuView.h
//  PP_SlideMenu
//
//  Created by 小超人 on 16/8/21.
//  Copyright © 2016年 云之君兮鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PP_SlideMenuView : UIView

@property (assign, nonatomic) BOOL isMenuViewHidden;


// 单例方法
+ (instancetype)shareSliderMenuView;

// 绑定控制器 并进行相关的设置
- (void)bindWithViewController:(UIViewController *)rootVc;


@end
