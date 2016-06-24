//
//  common.h
//  OurMemories
//
//  Created by LanHai on 16/5/25.
//  Copyright © 2016年 斗高甲. All rights reserved.
//

#ifndef common_h
#define common_h

//屏幕宽度
#define UI_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
//屏幕高度
#define UI_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
// 透明色
#define kClearColor [UIColor clearColor]

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

//navgationcontroller
#define MyNavRightColor [UIColor whiteColor]
#define MyNavTitleColor [UIColor whiteColor]
#define MyNavRightFont [UIFont systemFontOfSize:15]
#define MyNavTitleFont [UIFont systemFontOfSize:18]

#define SECRET_KEY (@"12345678")
//十六进制颜色
#define UIColorFromHEXWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#endif /* common_h */
