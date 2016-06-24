//
//  OMViewController.h
//  OurMemories
//
//  Created by LanHai on 16/5/25.
//  Copyright © 2016年 斗高甲. All rights reserved.
//

#import "ViewController.h"

@interface OMViewController : ViewController

/**
 *  推出导航时隐藏tabbar
 */
- (void)navPushVC:(UIViewController *)viewController;



/**
 * 导航左按键点击事件，默认pop当前控制器
 */
- (void)navLeftClick:(UIBarButtonItem *)barItem;

/**
 * 导航右按键点击事件
 */
- (void)navRightClick:(UIBarButtonItem *)barItem;

/**
 *导航条左侧按钮设置
 */
- (void)setNavLeftBtn:(NSString *)imageName;
@end
