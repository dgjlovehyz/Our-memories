//
//  OMTableBarController.m
//  OurMemories
//
//  Created by LanHai on 16/6/6.
//  Copyright © 2016年 斗高甲. All rights reserved.
//

#import "OMTableBarController.h"

@interface OMTableBarController ()

@property (nonatomic , strong)UIButton *selectedBtn;

@end

@implementation OMTableBarController
@synthesize viewControllerName;

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.tabBar removeFromSuperview];
    [self creatMYBar];
    [self createCotnrollers];
}

- (void)createCotnrollers{
    NSMutableArray *controllerAllay = [[NSMutableArray alloc]init];
    for (NSString *name in viewControllerName) {
        id viewController = NSClassFromString(name);
        UIViewController *viewControllers = [[viewController alloc]init];
        [controllerAllay addObject:viewControllers];
    }
    self.viewControllers = controllerAllay;
}

-(void)creatMYBar{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 430, 320, 50)];
    
    view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:view];
    
    for (int i = 0; i < 3; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        //当按钮处于一般状态时
        NSString *str = [NSString stringWithFormat:@"tab_%i", i];
        [btn setImage:[UIImage imageNamed:str] forState:UIControlStateNormal];
        //当按钮处于选中状态时
        NSString *str1 = [NSString stringWithFormat:@"tab_c%i.png", i];
        [btn setImage:[UIImage imageNamed:str1] forState:UIControlStateSelected];
        btn.frame = CGRectMake(i * 100 + 40, 10, 30, 30);
        [view addSubview:btn];
        //给按钮设置tag值
        btn.tag = 100 + i;
        if (btn.tag == 100) {
            btn.selected = YES;
            
            self.selectedBtn = btn;
        }
        //给按钮添加点击事件
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma -mark -- 按钮点击事件_状态转换 --
-(void)btnClick:(UIButton *)btn{
    if (btn.tag != self.selectedBtn.tag) {
        btn.selected = YES;
        //标签控制器对象中的selectedIndex可以切换viewControllers中的子页面
        self.selectedIndex = btn.tag - 100;
        self.selectedBtn.selected = NO;
        self.selectedBtn = btn;
    }
    
    
}



@end
