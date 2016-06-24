//
//  DGJHttpView.h
//  OurMemories
//
//  Created by LanHai on 16/5/31.
//  Copyright © 2016年 斗高甲. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DGJHttpView : UIView
typedef void (^btnBlock)(void);
typedef void (^reloadBlock)(void);

@property(nonatomic,strong)UIButton *httpBtn;  // 状态view上button
@property(nonatomic,strong)UILabel *httpLabel;  // 状态view上label
@property(nonatomic,strong)UIImageView *httpImageView;  // 状态view上imageview
@property(nonatomic,strong)UIImage *httpImage;  // 状态view上imageview中显示image
@property(nonatomic,copy)btnBlock btnClick;  // 状态view上按钮点击事件
@property(nonatomic,copy)reloadBlock reloadBlock;  // 状态view上按钮点击事件

- (instancetype)initEmptyViewWithFatherView:(UIView *)fatherView;  // 默认空View
- (instancetype)initLoadingViewWithFatherView:(UIView *)fatherView;  // 默认加载中View
- (instancetype)initFailedViewWithFatherView:(UIView *)fatherView;  // 默认失败View
- (instancetype)initInfoView;  // 提示view


/**
 *  带文字提示view
 */
- (instancetype)initInfoViewWithInfo:(NSString *)info;


/**
 *  设置文字提示view文字
 */
- (void)setInfoViewWithInfo:(NSString *)info;

/**
 *  创建一个跟fatherView一样大小的view
 */
- (instancetype)initWithFatherView:(UIView *)fatherView;


/**
 *  设置httpLabel文字
 */
- (void)setHttpLabelText:(NSString *)text;


/**
 *  隐藏view
 */
- (void)hiddenView;

@end
