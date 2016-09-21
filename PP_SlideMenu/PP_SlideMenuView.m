//
//  PP_SlideMenuView.m
//  PP_SlideMenu
//
//  Created by 小超人 on 16/8/21.
//  Copyright © 2016年 云之君兮鹏. All rights reserved.
/**
 *   封装侧滑的菜单
 *   只需要在需要的试图控制上添加即可实现侧滑显露  菜单的 View 的功能
 */

#import "PP_SlideMenuView.h"

#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width


// 菜单宽度
#define MENU_WIDTH (kSCREEN_WIDTH * 2 / 3)
#define MASK_COLOR [UIColor redColor]
#define MASK_MAX_ALPHA 0.5




@interface PP_SlideMenuView ()
// 容纳 侧滑 的视图控制器
@property (nonatomic, strong) UIViewController *containerVC;
// 滑动时候 遮盖 在视图控制器上的一层 View
@property (nonatomic, strong) UIView *maskView;


@end


@implementation PP_SlideMenuView

// 构造左侧  整体的 View
+ (instancetype)shareSliderMenuView
{
    static PP_SlideMenuView *slideMenuView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        slideMenuView = [[NSBundle mainBundle] loadNibNamed:@"PP_SlideMenuView" owner:self options:nil].firstObject;
        slideMenuView.frame = CGRectMake(- MENU_WIDTH, 0, MENU_WIDTH, kSCREEN_HEIGHT);
    });
    return slideMenuView;
}
// 初始化相关的操作 Xib 使用走的方法
-(void)awakeFromNib
{
   
}

// 绑定控制器 并进行相关的设置
- (void)bindWithViewController:(UIViewController *)rootVc
{
    __weak UIViewController *tempVc = rootVc;
        self.containerVC = tempVc;// 设置为视图的一个属性方便在不同地方使用
        self.isMenuViewHidden = YES;// 记录开始状态为 隐藏菜单视图
        // 创建遮挡的 View
        self.maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = MASK_COLOR;
        _maskView.hidden = YES; // 只有在滑动菜单出现时候才会  出现 MaskView 遮挡
        [_containerVC.view addSubview:_maskView]; // 遮挡的 加到 控制器 view 上
        
        // 使用 KVO 监控 菜单View 的位置变化  然后改变遮挡视图的 透明度
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
        // 给视图控制器上的  View 添加平移 手势 以及 遮挡的 MaskView 加点击手势
        [self addOurGestureRecognizer];
  
}

#pragma mark ------>> 给视图控制器上的  View 添加平移 手势 以及 遮挡的 MaskView 加点击手势 <<------
- (void)addOurGestureRecognizer
{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panContainViewAction:)]; // 右滑动时候  出来菜单
    [_containerVC.view addGestureRecognizer:pan];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHiddenMenuAction:)]; // 要是菜单在  点击 MaskView 隐藏菜单
    [_maskView addGestureRecognizer:tap];

}
#pragma mark ------>> 滑动视图控制器的 View 的时候触发方法 <<------
- (void)panContainViewAction:(UIPanGestureRecognizer *)pan
{
    // 偏移量
    CGPoint offSet = [pan translationInView:_containerVC.view];
    // 平移进行时候
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged)
    {
        if (offSet.x > 0)//向右滑动
        {
            if (self.frame.origin.x == 0)
            {
                return;
            }
            CGFloat tempX = self.frame.origin.x + offSet.x;// 算出更新的 x
            if (tempX <= 0 )
            {// 小于 0 就随着拖动移动就好
                self.frame = CGRectMake(tempX, 0, MENU_WIDTH, kSCREEN_HEIGHT);
            }else
            {// 都出来之后 就让它完全展示就好  别滑到太靠右地方
                self.frame = CGRectMake(0, 0, MENU_WIDTH, kSCREEN_HEIGHT);
            }
        }else
        {// 向左滑动
            CGFloat tempX = self.frame.origin.x + offSet.x;// 算出更新的 x
            self.frame = CGRectMake(tempX, 0, MENU_WIDTH, kSCREEN_HEIGHT);
        }
    }else
    {// 在这里判断要 显示还是隐藏
        if (self.frame.origin.x >= - MENU_WIDTH * 0.5)
        {
            [self inputOfSightMenuView];
        }else
        {
            [self outOfSightMenuView];
        }
    }
    // 清除偏移量
    [pan setTranslation:(CGPointZero) inView:_containerVC.view];
    //self.maskView.frame = CGRectMake(CGRectGetMaxX(self.frame), 0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
}

// 点击遮挡  收起菜单
- (void)tapHiddenMenuAction:(UITapGestureRecognizer *)tap
{
    [self outOfSightMenuView];
}

#pragma mark ------>> MenuView 视图 移出 或者 移进 视线  <<------
// 放到视线之外
- (void)outOfSightMenuView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(- MENU_WIDTH, 0, MENU_WIDTH, kSCREEN_HEIGHT);
        self.isMenuViewHidden = YES;
        self.maskView.hidden = YES;
    }];
}
// 放到视线之内
- (void)inputOfSightMenuView
{
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(0, 0, MENU_WIDTH, kSCREEN_HEIGHT);
    } completion:^(BOOL finished) {
        self.maskView.hidden = NO;
        self.maskView.alpha = MASK_MAX_ALPHA;
    }];

}



#pragma mark ------>> KVO 监控 菜单View 的位置变化 <<------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"])
    {
        CGRect newFrame = [change[@"new"] CGRectValue];
        CGFloat newFrameX = newFrame.origin.x;
        // 判断是否需要改变 遮挡的透明度
        if (newFrameX != - MENU_WIDTH)
        {
            _maskView.hidden = NO;// 出现遮挡
            // 改变遮挡的透明度
            _maskView.alpha = (newFrameX + MENU_WIDTH) / MENU_WIDTH * MASK_MAX_ALPHA;
        }else
        {
            _maskView.hidden = YES;
        }
    }
}




















@end
