//
//  DGJHttpView.m
//  OurMemories
//
//  Created by LanHai on 16/5/31.
//  Copyright © 2016年 斗高甲. All rights reserved.
//

#import "DGJHttpView.h"
#import "MBProgressHUD.h"

@interface DGJHttpView ()<MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}
@end


#define VIEW_FRAME (CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT))
#define BACKGROUD_COLOR ([UIColor whiteColor])
#define IMAGE_WIDTH 100
#define IMAGE_HEIGHT  100

@implementation DGJHttpView


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
#pragma mark - 创建的默认view
/**
 *  带文字提示view
 */
- (instancetype)initInfoViewWithInfo:(NSString *)info {
    if (self = [self initWithFrame:VIEW_FRAME]) {
        HUD.mode = MBProgressHUDModeText;
        HUD = [[MBProgressHUD alloc] initWithView:self];
        HUD.labelText = info;
        [self addSubview:HUD];
        [HUD show:YES];
        HUD.color = RGBACOLOR(0.23, 0.50, 0.82, 0.90);//[UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90];
        [HUD hide:YES afterDelay:3];
    }
    return self;
}


- (instancetype)initLoadingViewWithFatherView:(UIView *)fatherView {
    
    if (self = [self initWithFrame:VIEW_FRAME]) {
        if (fatherView) {
            self.frame = fatherView.bounds;
        }
        self.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [indicatorView setCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/3.0)];
        [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView startAnimating];
        [self addSubview:indicatorView];
    }
    return self;
}

- (instancetype)initFailedViewWithFatherView:(UIView *)fatherView {
    if (self = [self initWithFrame:VIEW_FRAME Image:[UIImage imageNamed:@"failed"]]) {
        if (fatherView) {
            self.frame = fatherView.bounds;
        }
        self.backgroundColor = BACKGROUD_COLOR;
        //        self.httpLabel.text = @"";
        //        [self addReloadRqeustAction];
        //        [self.httpBtn setTitle:@"重新加载" forState:UIControlStateNormal];
        //        [self.httpBtn addTarget:self action:@selector(httpBtnAction) forControlEvents:UIControlEventTouchUpInside];
        //        [self.httpLabel sizeToFit];
    }
    return self;
}


/**
 *  添加点击背景手势移除当前view
 *
 *  根据传入的请求返回内容，result_type为0时返回yes，没有result_type时空串或者空字典或者空数组是返回yes,其他时候返回no
 */
- (void)addRemoveAction {
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenView)];
    [self addGestureRecognizer:tgr];
}


/**
 *  添加点击背景手势
 *
 *  根据传入的请求返回内容，result_type为0时返回yes，没有result_type时空串或者空字典或者空数组是返回yes,其他时候返回no
 *  @param  type  1:重新加载   0:移除当前view
 */
//- (void)addRemoveAction {
//    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenView)];
//    [self addGestureRecognizer:tgr];
//}


//- (void)addReloadRqeustAction:(NSInteger)type {
//    SEL sel;
//    if (type) {
//        sel = @selector(reloadRequest);
//    } else {
//        sel = @selector(httpBtnAction);
//    }
//
//    //
//    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]initWithTarget:self action:sel];
//    [self addGestureRecognizer:tgr];
//}


- (instancetype)initInfoView {
    if (self = [self initWithFrame:VIEW_FRAME]) {
        HUD = [[MBProgressHUD alloc] initWithView:self];
        HUD.mode = MBProgressHUDModeText;
        [self addSubview:HUD];
        HUD.color = [UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90];
        HUD.delegate = self;
    }
    return self;
}

- (instancetype)initEmptyViewWithFatherView:(UIView *)fatherView {
    if (self = [self initWithFrame:VIEW_FRAME Image:[UIImage imageNamed:@"empty"]]) {
        if (fatherView) {
            self.frame = fatherView.bounds;
        }
        self.backgroundColor = BACKGROUD_COLOR;
        //        [self addReloadRqeustAction];
        self.httpLabel.text = @"加载内容为空！";
        //        [self.httpBtn addTarget:self action:@selector(hiddenView) forControlEvents:UIControlEventTouchUpInside];
        //        [self.httpBtn setTitle:@"back" forState:UIControlStateNormal];
        //        [self.httpLabel sizeToFit];
    }
    return self;
}

/**
 *  创建一个跟fatherView一样大小的view
 */
- (instancetype)initWithFatherView:(UIView *)fatherView {
    if (self = [super initWithFrame:fatherView.bounds]) {
        [fatherView addSubview:self];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame Image:(UIImage *)image {
    if (self = [super initWithFrame:frame]) {
        if (image) {
            self.httpImage = image;
        };
        [self addSubview:self.httpBtn];
        //        self.backgroundColor = [UIColor greenColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - 设置控件相关函数
/**
 *  设置httpLabel文字为text
 */
- (void)setHttpLabelText:(NSString *)text {
    self.httpLabel.text = text;
    //    [self.httpLabel sizeToFit];
}


/**
 *  设置文字提示view文字
 */
- (void)setInfoViewWithInfo:(NSString *)info {
    HUD.labelText = info;
}

/**
 *  httpBtn点击事件，如果想更改，可以设置_btnClick，如果_btnClick空，则将self移除
 */
- (void)httpBtnAction {
    NSLog(@"self - %@",[self class]);
    if (_btnClick) {
        _btnClick();
    }
}

/**
 *  加载失败点击重新加载
 */
- (void)reloadRequest {
    if (self.reloadBlock) {
        self.reloadBlock();
    }
}

- (void)hiddenView {
    [self removeFromSuperview];
}


- (void)setHttpImage:(UIImage *)httpImage {
    if (httpImage) {
        _httpImage = httpImage;
        [self.httpImageView setImage:httpImage];
        _httpImageView.frame = CGRectMake(0, 0, IMAGE_WIDTH, IMAGE_HEIGHT);  // imageView大小
        //        _httpImageView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        _httpImageView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-IMAGE_HEIGHT);
    }
}


- (UIButton *)httpBtn {
    if (_httpBtn == nil) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat btnX = self.httpImageView.frame.origin.x;
        CGFloat btnY = CGRectGetMaxY(self.httpImageView.frame)+20;
        CGFloat btnWidth = self.httpImageView.frame.size.width;
        CGFloat btnHeight = 50;
        button.layer.borderColor = [[UIColor grayColor] CGColor];
        button.layer.borderWidth = 1;
        button.frame = CGRectMake(btnX, btnY, btnWidth, btnHeight);  // 更改_httpBtn位置修改此处
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(reloadRequest) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:@"重新加载" forState:UIControlStateNormal];
        //        [button setBackgroundColor:[UIColor greenColor]];
        _httpBtn = button;
        
    }
    return _httpBtn;
}

- (UIImageView *)httpImageView {
    if (_httpImageView == nil) {
        //        CGFloat width = self.httpImage.size.width;
        //        CGFloat height = self.httpImage.size.height;
        //        _httpImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        _httpImageView = [[UIImageView alloc]init];
        NSLog(@" y = %@, y = %@", NSStringFromCGRect(self.frame), NSStringFromCGRect(_httpImageView.frame));
        //        _httpImageView.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-height);
        NSLog(@" y = %@, y = %@", NSStringFromCGRect(self.frame), NSStringFromCGRect(_httpImageView.frame));
        //        _httpImageView.backgroundColor = [UIColor brownColor];
        [self addSubview:_httpImageView];
    }
    return _httpImageView;
    
}

- (UILabel *)httpLabel {
    if (_httpLabel == nil) {
        CGFloat labelX = 20;
        CGFloat labelY = CGRectGetMinY(self.httpImageView.frame)-40;
        CGFloat labelWidth = self.frame.size.width-40;
        CGFloat labelHeight = 30;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelWidth, labelHeight)];  // 更改_httpLabel位置修改此处
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.textColor = [UIColor grayColor];
        //        label.backgroundColor = [UIColor blueColor];
        //         label.center = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-IMAGE_HEIGHT);
        _httpLabel = label;
        [self addSubview:_httpLabel];
    }
    return _httpLabel;
}

@end
