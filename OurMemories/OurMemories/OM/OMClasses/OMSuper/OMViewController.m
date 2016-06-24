//
//  OMViewController.m
//  OurMemories
//
//  Created by LanHai on 16/5/25.
//  Copyright © 2016年 斗高甲. All rights reserved.
//

#import "OMViewController.h"

@implementation OMViewController


- (void)setNavColor:(UIColor *)navColor WithTitle:(NSString *)title withRightTitle:(NSString *)rightTitle andImageName:(NSString *)imageName{
    self.navigationController.navigationBar.barTintColor = navColor;
    [self setNavLeftBtn:imageName];
    [self setNavBarTitle:title];
    [self setNavRightBtnWithTitle:rightTitle];
}


- (void)setNavBarTitle:(NSString *)title {
    if (title && ![title isEqualToString:@""]) {
        [self setNavBarTitle];
        self.title = title;
    }
}

- (void)setNavBarTitle {
    if (self.navigationController) {
        self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:MyNavTitleFont,NSForegroundColorAttributeName:MyNavTitleColor};
    }
}
/**
 *  推出导航时隐藏tabbar
 */
#pragma -mark -- 推出导航时隐藏tabbar --
- (void)navPushVC:(UIViewController *)viewController  {
    if (self.navigationController) {
        viewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        [self presentViewController:viewController animated:YES completion:^{
            
        }];
    }
}


- (void)setNavLeftBtn:(NSString *)imageName{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 30, 30);
    [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navLeftClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)setNavRightBtnWithTitle:(NSString *)rightTitle  {
    if (rightTitle && ![rightTitle isEqualToString:@""]) {
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:rightTitle style:UIBarButtonItemStylePlain target:self action:@selector(navRightClick:)];
        [rightButton setTitleTextAttributes: @{NSFontAttributeName:MyNavRightFont,NSForegroundColorAttributeName:MyNavRightColor} forState:UIControlStateNormal];
        self.navigationItem.rightBarButtonItem = rightButton;
    }
    
}

#pragma -mark -- 导航条按钮点击事件 --
- (void)navLeftClick:(UIBarButtonItem *)barItem {
    [self navBack];
}

- (void)navRightClick:(UIBarButtonItem *)barItem {
    NSLog(@"点击right");
}


#pragma -mark -- 返回 --
- (void)navBack{
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
