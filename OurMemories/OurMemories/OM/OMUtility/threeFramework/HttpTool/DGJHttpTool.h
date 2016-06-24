//
//  DGJHttpTool.h
//  OurMemories
//
//  Created by LanHai on 16/6/3.
//  Copyright © 2016年 斗高甲. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "DGJNetHeader.h"
#import "DGJHttpView.h"

@interface DGJHttpTool : NSObject
typedef void (^successBlock)(id responseObject, DGJHttpTool *httpTool);
typedef void (^failureBlock)(NSString *error);
//typedef void (^errorBlock)(NSString *error, NSInteger resultCode);
typedef void (^completeBlock)(void);
typedef void (^reloadBlock)(void);
typedef void (^tokenErrorBlock)(void);
typedef void (^uploadImgBlock) (id<AFMultipartFormData> formData);

@property (nonatomic, strong) DGJHttpView *failedView;  // 加载失败view
@property (nonatomic, strong) DGJHttpView *loadingView;  // 加载中view
@property (nonatomic, strong) DGJHttpView *emptyView;  // 加载内容为空view
@property (nonatomic, copy)completeBlock myCompleteBlock;
@property (nonatomic, copy)tokenErrorBlock tokenErrorBlock;
@property (nonatomic, assign) BOOL isEmpty;
@property (nonatomic, assign) NSInteger requestType;  // 请求type


/**
 *  获取ZWHttpToolTool单例
 */
+ (id)sharedTool;

/**
 *  异步发送post请求不带view带token方法
 */
- (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters token:(NSString *)token success:(successBlock)success failure:(failureBlock)failure;

/**
 *  异步发送post请求带view-flag-token方法
 */
- (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters token:(NSString *)token success:(successBlock)success failure:(failureBlock)failure onView:(UIView *)view saveFlag:(BOOL)saveFlag getFlag:(BOOL)getFlag;

/**
 *  异步发送post请求带view-flag-token-带图片方法
 */
- (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters token:(NSString *)token uploadImg:(uploadImgBlock)uploadImg success:(successBlock)success failure:(failureBlock)failure onView:(UIView *)view saveFlag:(BOOL)saveFlag getFlag:(BOOL)getFlag;

/**
 *  隐藏所有状态view
 */
- (void)hiddenAllViews;

/**
 *  显示加载为空时状态框
 */
- (void)showLoadEmptyView;

/**
 *  移除所有状态view
 */
- (void)removeAllViews;


/**
 *  重新加载事件
 */
- (void)reloadAction:(UIButton *)btn;

/**
 *  清空所有缓存
 */
- (void)removeAllRequestsCache;

/**
 *  清空过期缓存
 */
- (void)removeAllRequestsExpirationCache;
@end
