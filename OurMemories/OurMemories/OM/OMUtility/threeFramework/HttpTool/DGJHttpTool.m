//
//  DGJHttpTool.m
//  OurMemories
//
//  Created by LanHai on 16/6/3.
//  Copyright © 2016年 斗高甲. All rights reserved.
//

#import "DGJHttpTool.h"
#import "DGJFileApi.h"
#import "MBProgressHUD.h"
#import "NSString+MD5Addition.h"

#define FILEPATH ([[DGJFileApi getDocumentDir] stringByAppendingString:@"request.plist"])  // 保存路径
#define REQUEST_COUNT 10  // 保存条数
#define EXPIRATION_TIME 1000.0  // 过期时间
#define DATE_FORMATTER (@"yyyy-MM-dd HH:mm:ss")  // 保存时间格式
#define CONNECTION_OFFLINE (@"网络无法连接，刷新试试吧")   // 联网失败提示
#define FILE_NOTFONTD (@"请求失败（错误代码404）")   // 404失败提示

@interface DGJHttpTool ()

@property (nonatomic, strong) NSMutableArray *requestsArray;  // 存储url请求数组
@property (nonatomic, strong) NSMutableDictionary *requestsCacheDic;  // 存储url请求字典

@property (nonatomic, assign) CGRect viewFrame;  // 传进来的viewFrame,需要改变大小时用

@property (nonatomic, strong) UIView *myHttpView;  // 传进来的view

// 存储重新加载时用
@property (nonatomic, copy) NSString *paraUrl;  // 传进来的url
@property (nonatomic, strong) NSDictionary *paraDic;  // 传进来的参数
@property (nonatomic, copy) successBlock paraSuccess;  // 传进来的成功回调
@property (nonatomic, copy) failureBlock paraFailure;  // 传进来的失败回调
@property (nonatomic, copy) uploadImgBlock uploadImgBlock;  // 传进来的失败回调
@property (nonatomic, assign) BOOL saveFlag;
@property (nonatomic, assign) BOOL getFlag;
@property (nonatomic, copy) NSString *paraToken;  // 传进来的token
//@property (nonatomic, copy) NSString *requeType;  // 使用请求方式 POST or GET

@property (nonatomic, assign) BOOL flag;

@property (nonatomic, assign) BOOL update;

@property (nonatomic, strong) id obj; // 返回数据
@property (nonatomic, strong) NSMutableDictionary *currentRequestDataDic;  // 当前请求数据，存在字典里 url:地址，parameters:参数，requestObj:数据  expirationDate:过期时间

@property (nonatomic, assign) NSInteger index;  // 更新时索引

@end

@implementation DGJHttpTool


/**
 *  获取DGJHttpToolTool单例
 */
+ (id)sharedTool {
    static DGJHttpTool* sharedInstance = nil;
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark- post请求

/**
 *  异步发送post请求+方法
 *
 *  @param url        请求的地址
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
+ (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters success:(successBlock)success failure:(failureBlock)failure
{
    DGJHttpTool *httpTool = [[DGJHttpTool alloc] init];
    [httpTool post:url parameters:parameters success:success failure:failure];
    return httpTool;
}


/**
 *  异步发送post请求-方法
 *
 *  @param url        请求的地址
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
- (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters success:(successBlock)success failure:(failureBlock)failure
{
    [self post:url parameters:parameters success:success failure:failure onView:nil];
    return self;
}


#pragma mark带view请求
/**
 *  异步发送post请求+方法
 *
 *  @param url        请求的地址
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *  @param views      请求传过来的view
 */
+ (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters success:(successBlock)success failure:(failureBlock)failure onView:(UIView *)view {
    DGJHttpTool *httpTool = [[DGJHttpTool alloc] init];
    [httpTool post:url parameters:parameters success:success failure:failure onView:view];
    return httpTool;
}

/**
 *  异步发送post请求-方法
 *
 *  @param url        请求的地址
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *  @param views      请求传过来的view
 */
- (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters success:(successBlock)success failure:(failureBlock)failure onView:(UIView *)view  {
    NSLog(@"self == %@",self);
    [self post:url parameters:parameters success:success failure:failure onView:view saveFlag:NO getFlag:NO];
    return self;
}

/**
 *  异步发送post请求带view-flag-方法
 *
 *  @param url        请求的地址
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *  @param views      请求传过来的view
 *  @param saveFlag   BOOL 是否需要保存加载，如果YES,存储本条请求，NO 不保存
 *  @param getFlag    BOOL 是否检测加载过，如果YES,先检查本地是否有，有的话先加载本地 NO直接重新加载
 */
+ (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters success:(successBlock)success failure:(failureBlock)failure onView:(UIView *)view saveFlag:(BOOL)saveFlag getFlag:(BOOL)getFlag {
    DGJHttpTool *httpTool = [[DGJHttpTool alloc] init];
    [httpTool post:url parameters:parameters success:success failure:failure onView:view saveFlag:saveFlag getFlag:getFlag];
    return httpTool;
}


#pragma mark 请求(逻辑在此函数中)
/**
 *  异步发送post请求带view-flag-方法
 *
 *  @param url        请求的地址
 *  @param parameters 请求的参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *  @param views      请求传过来的view
 *  @param saveFlag   BOOL 是否需要保存加载，如果YES,存储本条请求，NO 不保存
 *  @param getFlag    BOOL 是否检测加载过，如果YES,先检查本地是否有，有的话先加载本地 NO直接重新加载
 */
- (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters success:(successBlock)success failure:(failureBlock)failure onView:(UIView *)view saveFlag:(BOOL)saveFlag getFlag:(BOOL)getFlag {
    
    // 创建AFN管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    self.requeType = @"POST";  // 设置type,调用重新加载时使用
    self.saveFlag = saveFlag;
    self.getFlag = getFlag;
    self.paraUrl = url;
    self.paraDic = parameters;
    self.paraSuccess = success;
    self.paraFailure = failure;
    
    if (view) {
        _viewFrame = view.frame;
        self.myHttpView = view;
        [self addSubViews];
        [self showLoadingView];
    }
    __weak __typeof(self)weakSelf = self;
    
    
    if (getFlag) {  // 需要从缓存中取出 搜索本地有没有存过
        if ([self searchDataInFile]) {  // 存储过
            NSDate *expirationDate = _currentRequestDataDic[@"expirationDate"];  // 取出过期时间
            if (![self isOverdue:expirationDate]) {   //  数据没有过期
                id obj = _currentRequestDataDic[@"requestObj"];
                // 可以从最近数据请求中读数据
                [weakSelf showLoadSuccessView];  // 加载内容成功
                if (success) {
                    success(obj,self);
                }
                return self;
            } else {
                
            }
            
        };
    }
    
    
    /** 从服务器请求新数据*/
    
    // 没有请求过，请求数据并保存
    _currentRequestDataDic = [NSMutableDictionary dictionary];
    _currentRequestDataDic[@"url"] = url;
    _currentRequestDataDic[@"parameters"] = parameters;
    
    
    [manager POST:url parameters:parameters success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            _currentRequestDataDic[@"requestObj"] = responseObject;
        }
        
        NSInteger result = (NSInteger)responseObject[@"result"];
        NSInteger resultType = [responseObject[@"userinfo"] count];
        if (_isEmpty) {
            resultType = 0;
        }
        if (result && resultType > 0) {  // 请求数据成功
            
            // 更新数据
            if (saveFlag) {  // 需要保持请求
                [weakSelf addRequestToDic];  //增加该条数据
                [weakSelf writeRequestsData:YES];  // 写入文件
            }
            
            [weakSelf showLoadSuccessView];  // 加载内容成功
            
            if (success) {
                success(responseObject,self);
            }
        } else if (result && resultType == 0) {  // 请求数据为空
            
            if (success) {
                success(responseObject,self);
            }
            
            [weakSelf showLoadEmptyView];  // 加载内容为空
            
        } else {  // 其他错误
            [self showLoadFailedViewWithError:@"出错了"];
        }
        
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) { // 请求失败
        
        if ((error.code == -1009)) {  // 没有网络
            [self showLoadFailedViewWithError:CONNECTION_OFFLINE];
        } else if ((error.code == -1011)) {  // 404
            [self showLoadFailedViewWithError:FILE_NOTFONTD];
        } else {  // 其它
            [self showLoadFailedViewWithError:error.userInfo[@"NSLocalizedDescription"]];  // 返回失败错误提示
        }
        
        
    }];
    return self;
    
}



/**
 *  异步发送post请求不带view带token方法
 */
- (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters token:(NSString *)token success:(successBlock)success failure:(failureBlock)failure{
    return [self post:url parameters:parameters token:token success:success failure:failure onView:nil saveFlag:NO getFlag:NO];
}



/**
 *  异步发送post请求带view-flag-token方法
 */
- (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters token:(NSString *)token success:(successBlock)success failure:(failureBlock)failure onView:(UIView *)view saveFlag:(BOOL)saveFlag getFlag:(BOOL)getFlag {
    return [self post:url parameters:parameters token:token uploadImg:nil success:success failure:failure onView:view saveFlag:saveFlag getFlag:getFlag];
    //    // 创建AFN管理者
    //    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    self.requeType = @"POST";  // 设置type,调用重新加载时使用
    //    self.saveFlag = saveFlag;
    //    self.getFlag = getFlag;
    //    self.paraUrl = url;
    //    self.paraDic = parameters;
    //    self.paraSuccess = success;
    //    self.paraFailure = failure;
    //    self.paraToken = token;
    //
    //    NSString *signStr;
    //    NSMutableDictionary *dicSign = [NSMutableDictionary dictionary];
    //
    //
    //    if (parameters.count) {  // 有参数，进行签名
    //        [dicSign setDictionary:parameters];
    //        signStr = [self sign:dicSign];//MD5转换
    //
    //    }else{
    //        signStr = [self sign:dicSign];
    //    }
    //
    //
    //    if (view) {
    //        _viewFrame = view.frame;
    //        self.myHttpView = view;
    //        [self addSubViews];
    //        [self showLoadingView];
    //    }
    //    __weak __typeof(self)weakSelf = self;
    //
    //    NSLog(@"count = %zd",self.requestsCacheDic.count);
    //    if (getFlag) {  // 需要从缓存中取出 搜索本地有没有存过
    //        if ([self searchDataInFile]) {  // 存储过
    //            NSDate *expirationDate = _currentRequestDataDic[@"expirationDate"];  // 取出过期时间
    //            if (![self isOverdue:expirationDate]) {   //  数据没有过期
    //                id obj = _currentRequestDataDic[@"requestObj"];
    //                // 可以从最近数据请求中读数据
    //                [weakSelf showLoadSuccessView];  // 加载内容成功
    //                if (success) {
    //                    success(obj,self);
    //                }
    //                return self;
    //            } else {
    //
    //            }
    //
    //        };
    //    }
    //
    //
    //    /** 从服务器请求新数据*/
    //
    //    // 没有请求过，请求数据并保存
    //    _currentRequestDataDic = [NSMutableDictionary dictionary];
    //    _currentRequestDataDic[@"url"] = url;
    //    _currentRequestDataDic[@"parameters"] = parameters;
    //    _currentRequestDataDic[@"token"] = token;
    //
    //    [manager POST:url sign:signStr token:token parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    //
    //        if ([responseObject isKindOfClass:[NSDictionary class]]) {
    //            _currentRequestDataDic[@"requestObj"] = responseObject;
    //        }
    //
    //        NSInteger result = [responseObject[@"resultCode"] integerValue];
    //        BOOL emptyData = [self isEmptyDataWithResponseObject:responseObject];  // 判断数据是否为空
    //
    //        if (result == 200 && !emptyData) {  // 请求数据成功
    //
    //            // 更新数据
    //            if (saveFlag) {  // 需要保持请求
    //                [weakSelf addRequestToDic];  //增加该条数据
    //                [weakSelf writeRequestsData:YES];  // 写入文件
    //            }
    //
    //            [weakSelf showLoadSuccessView];  // 加载内容成功
    //
    //            if (success) {
    //                success(responseObject,self);
    //            }
    //        } else if (result == 200 && emptyData) {  // 请求数据为空
    //
    //            if (success) {
    //                success(responseObject,self);
    //            }
    //
    //            [weakSelf showLoadEmptyView];  // 加载内容为空view
    //
    //        } else if (result == 410) {  // token为空
    //
    //            [self showLoadFailedViewWithError:@"您已在其他地方登录，请重新登录"];
    //
    //        } else {  // 其他错误
    //            [self showLoadFailedViewWithError:@"出错了"];  // 返回失败错误提示
    //        }
    //
    //    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) { // 请求失败
    //
    //        NSLog(@"error:%@",error.userInfo[@"NSLocalizedDescription"]);
    //
    //        if ((error.code == -1009)) {  // 没有网络
    //            [self showLoadFailedViewWithError:CONNECTION_OFFLINE];
    //        } else if ((error.code == -1011)) {  // 404
    //            [self showLoadFailedViewWithError:FILE_NOTFONTD];
    //        } else {  // 其它
    //            [self showLoadFailedViewWithError:error.userInfo[@"NSLocalizedDescription"]];  // 返回失败错误提示
    //        }
    //
    //    }];
    //
    //    return self;
}

/**
 *  异步发送post请求带view-flag-token-带图片方法
 */
- (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters token:(NSString *)token uploadImg:(uploadImgBlock)uploadImg success:(successBlock)success failure:(failureBlock)failure tokenError:(tokenErrorBlock)tokenError onView:(UIView *)view saveFlag:(BOOL)saveFlag getFlag:(BOOL)getFlag {
    
    
    
    
    
    // 创建AFN管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    self.requeType = @"POST";  // 设置type,调用重新加载时使用
    self.saveFlag = saveFlag;
    self.getFlag = getFlag;
    self.paraUrl = url;
    self.paraDic = parameters;
    self.paraSuccess = success;
    self.paraFailure = failure;
    self.paraToken = token;
    self.uploadImgBlock = uploadImg;
    
    NSString *signStr;
    NSMutableDictionary *dicSign = [NSMutableDictionary dictionary];
    
    
    if (parameters.count) {  // 有参数，进行签名
        [dicSign setDictionary:parameters];
        signStr = [self sign:dicSign];//MD5转换
        
    }else{
        signStr = [self sign:dicSign];
    }
    
    
    if (view) {
        _viewFrame = view.frame;
        self.myHttpView = view;
        [self addSubViews];
        [self showLoadingView];
    }
    __weak __typeof(self)weakSelf = self;
    
    
    if (getFlag) {  // 需要从缓存中取出 搜索本地有没有存过
        if ([self searchDataInFile]) {  // 存储过
            NSDate *expirationDate = _currentRequestDataDic[@"expirationDate"];  // 取出过期时间
            if (![self isOverdue:expirationDate]) {   //  数据没有过期
                id obj = _currentRequestDataDic[@"requestObj"];
                // 可以从最近数据请求中读数据
                [weakSelf showLoadSuccessView];  // 加载内容成功
                if (success) {
                    success(obj,self);
                }
                return self;
            } else {
                
            }
            
        };
    }
    
    
    /** 从服务器请求新数据*/
    
    // 没有请求过，请求数据并保存
    _currentRequestDataDic = [NSMutableDictionary dictionary];
    _currentRequestDataDic[@"url"] = url;
    _currentRequestDataDic[@"parameters"] = parameters;
    _currentRequestDataDic[@"token"] = token;
    
    [manager POST:url sign:signStr token:token parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (uploadImg) {
            uploadImg(formData);
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            _currentRequestDataDic[@"requestObj"] = responseObject;
        }
        
        NSInteger result = [responseObject[@"resultCode"] integerValue];
        NSString *info = responseObject[@"info"];
        BOOL emptyData = [self isEmptyDataWithResponseObject:info];  // 判断数据是否为空
        
        if (result == 200 && !emptyData) {  // 请求数据成功
            
            // 更新数据
            if (saveFlag) {  // 需要保持请求
                [weakSelf addRequestToDic];  //增加该条数据
                [weakSelf writeRequestsData:YES];  // 写入文件
            }
            
            [weakSelf showLoadSuccessView];  // 加载内容成功
            
            if (success) {
                success(responseObject,self);
            }
        } else if (result == 200 && emptyData) {  // 请求数据为空
            
            if (success) {
                success(responseObject,self);
            }
            
            
            
            [weakSelf showLoadEmptyView];  // 加载内容为空view
            
        } else if (result == 408) {  // token为空
            //            NSString *err = @"您已在其他地方登录，请重新登录";
            if (tokenError) {
                tokenError();
            }
            //            if (failure) {
            //                failure(info);
            //            }
            //            [self showLoadFailedViewWithError:err];
            
        } else {  // 其他错误
            //                    NSString *err = @"出错了";
            if (failure) {
                failure(info);
            }
            [self showLoadFailedViewWithError:info];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) { // 请求失败
        
        NSString *err = error.userInfo[@"NSLocalizedDescription"];
        
        //        NSInteger result = error.code;
        //        [self showLoadFailedViewWithError:err];
        if ((error.code == -1009)) {  // 没有网络
            [self showLoadFailedViewWithError:CONNECTION_OFFLINE];
            if (failure) {
                failure(CONNECTION_OFFLINE);
            }
        } else if ((error.code == -1011)) {  // 404
            [self showLoadFailedViewWithError:FILE_NOTFONTD];
            if (failure) {
                failure(FILE_NOTFONTD);
            }
        } else {  // 其它
            [self showLoadFailedViewWithError:err];  // 返回失败错误提示
            if (failure) {
                failure(err);
            }
        }
        
    }];
    return self;
}


/**
 *  异步发送post请求带view-flag-token-带图片方法
 */
- (instancetype)post:(NSString *)url parameters:(NSDictionary *)parameters token:(NSString *)token uploadImg:(uploadImgBlock)uploadImg success:(successBlock)success failure:(failureBlock)failure onView:(UIView *)view saveFlag:(BOOL)saveFlag getFlag:(BOOL)getFlag {
    
    
    // 创建AFN管理者
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //    self.requeType = @"POST";  // 设置type,调用重新加载时使用
    self.saveFlag = saveFlag;
    self.getFlag = getFlag;
    self.paraUrl = url;
    self.paraDic = parameters;
    self.paraSuccess = success;
    self.paraFailure = failure;
    self.paraToken = token;
    self.uploadImgBlock = uploadImg;
    
    NSString *signStr;
    NSMutableDictionary *dicSign = [NSMutableDictionary dictionary];
    
    
    if (parameters.count) {  // 有参数，进行签名
        [dicSign setDictionary:parameters];
        signStr = [self sign:dicSign];//MD5转换
        
    }else{
        signStr = [self sign:dicSign];
    }
    
    
    if (view) {
        _viewFrame = view.frame;
        self.myHttpView = view;
        [self addSubViews];
        [self showLoadingView];
    }
    __weak __typeof(self)weakSelf = self;
    
    
    if (getFlag) {  // 需要从缓存中取出 搜索本地有没有存过
        if ([self searchDataInFile]) {  // 存储过
            NSDate *expirationDate = _currentRequestDataDic[@"expirationDate"];  // 取出过期时间
            if (![self isOverdue:expirationDate]) {   //  数据没有过期
                id obj = _currentRequestDataDic[@"requestObj"];
                // 可以从最近数据请求中读数据
                [weakSelf showLoadSuccessView];  // 加载内容成功
                if (success) {
                    success(obj,self);
                }
                return self;
            } else {
                
            }
            
        };
    }
    
    
    /** 从服务器请求新数据*/
    
    // 没有请求过，请求数据并保存
    _currentRequestDataDic = [NSMutableDictionary dictionary];
    _currentRequestDataDic[@"url"] = url;
    _currentRequestDataDic[@"parameters"] = parameters;
    _currentRequestDataDic[@"token"] = token;
    
    [manager POST:url sign:signStr token:token parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (uploadImg) {
            uploadImg(formData);
        }
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"~~~~~~~~~~~~dgjhttp~success~~~~~~~~~~~~~~~~<<\nURL = %@\npara = %@ \n 转换后数据 = %@\n   >>~~~~~~~~~~~~zwyhttp~end~~~~~~~~~~~~~~~~",url, parameters, responseObject);
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            _currentRequestDataDic[@"requestObj"] = responseObject;
            
        }
        
        NSInteger result = [responseObject[@"resultCode"] integerValue];
        NSString *info = responseObject[@"info"];
        BOOL emptyData = [self isEmptyDataWithResponseObject:info];  // 判断数据是否为空 
        
        if (result == 200 && !emptyData) {  // 请求数据成功
            
            // 更新数据
            if (saveFlag) {  // 需要保持请求
                [weakSelf addRequestToDic];  //增加该条数据
                [weakSelf writeRequestsData:YES];  // 写入文件
            }
            
            [weakSelf showLoadSuccessView];  // 加载内容成功
            
            if (success) {
                success(responseObject,self);
            }
        } else if (result == 200 && emptyData) {  // 请求数据为空
            
            if (success) {
                success(responseObject,self);
            }
            [weakSelf showLoadEmptyView];  // 加载内容为空view
            
        } else if (result == 408) {  // token为空
            
            if (_tokenErrorBlock) {
                _tokenErrorBlock();
            } else {
                if (failure) {
                    failure(info);
                }
            }
            
            //            NSString *err = @"您已在其他地方登录，请重新登录";
            //            if (failure) {
            //                failure(info);
            //            }
            //            [self showLoadFailedViewWithError:err];
            
        } else {  // 其他错误
            //                    NSString *err = @"出错了";
            //            if (_tokenErrorBlock) {
            //                _tokenErrorBlock();
            //            }
            if (failure) {
                failure(info);
            }
            [self showLoadFailedViewWithError:info];
        }
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) { // 请求失败
        NSLog(@"~~~~~~~~~~~~zwyhttp~failure~~~~~~~~~~~~~~~~<<\nURL = %@\npara = %@ \n error = %@\n ",url, parameters,  error );
        
        NSString *err = error.userInfo[@"NSLocalizedDescription"];
        
        //        NSInteger result = error.code;
        //        [self showLoadFailedViewWithError:err];
        if ((error.code == -1009)) {  // 没有网络
            [self showLoadFailedViewWithError:CONNECTION_OFFLINE];
            if (failure) {
                failure(CONNECTION_OFFLINE);
            }
        } else if ((error.code == -1011)) {  // 404
            [self showLoadFailedViewWithError:FILE_NOTFONTD];
            if (failure) {
                failure(FILE_NOTFONTD);
            }
        } else {  // 其它
            [self showLoadFailedViewWithError:err];  // 返回失败错误提示
            if (failure) {
                failure(err);
            }
        }
        
    }];
    return self;
}




/**
 *  判断内容是否为空
 *
 *  根据传入的请求返回内容，result_type为0时返回yes，没有result_type时空串或者空字典或者空数组是返回yes,其他时候返回no
 *  @param  responseObject  请求返回内容
 *  @return BOOL            YES:无数据   NO:有数据
 */
- (BOOL)isEmptyDataWithResponseObject:(id)responseObject {
    
    if ([responseObject isKindOfClass:[NSString class]]) {  // 如果字符串类型""返回yes
        
        if ([responseObject isEqualToString:@""] || (responseObject == nil) || [responseObject isEqualToString:@"OK"]) {
            return YES;
        }
    }
    
    if (([responseObject isKindOfClass:[NSDictionary class]]) || ([responseObject isKindOfClass:[NSArray class]])) {  // 如果数组或字典类型
        
        if ([responseObject count] == 0) {
            return YES;
        }
    }
    
    return NO;
    
}

#pragma mark - 拆分线
#pragma mark - 缓存操作逻辑
/**
 *  根据url和parameter得到一个字符串，用来做当前请求的key
 */
- (NSString *)requestKey {
    
    NSMutableString * requestKey = [NSMutableString stringWithString:self.paraUrl];  // 拼url
    if (self.paraDic.count) {  // 有参数时，拼接参数
        [requestKey appendFormat:@"?%@",[_paraDic descriptionInStringsFileFormat]];
    }
    NSLog(@"request = %@",requestKey);
    return requestKey;
}



/**
 *  搜索本地有没有存储当前请求
 */
- (BOOL)searchDataInFile {
    
    NSString *requestKey = [self requestKey];
    
    NSDictionary *requestDic = self.requestsCacheDic[requestKey];  // 取出当前请求
    NSString *token = requestDic[@"token"];  // 取出当前请求token
    
    if (requestDic && ([token isEqualToString:self.paraToken])) {
        _currentRequestDataDic = (NSMutableDictionary *)requestDic;
        return YES;
    }
    return NO;
}


/**
 *  判断是否过期
 *
 *  根据传入的时间，跟当前时间进行比较，判断是否过期
 *  @param  date  过期时间
 *  @return BOOL  YES:过期   NO:没有过期
 */
- (BOOL)isOverdue:(NSDate *)date {
    
    double dateLong = [[NSDate date] timeIntervalSinceDate:date];
    BOOL expiration = dateLong>0?YES:NO;
    return expiration;
}


/**
 *  将当前请求添加进字典方法
 */
- (void)addRequestToDic {
    NSDate *expirationTime = [NSDate dateWithTimeIntervalSinceNow:EXPIRATION_TIME];  // 计算过期时间
    [_currentRequestDataDic setObject:expirationTime forKey:@"expiration"];
    
    NSString *key = [self requestKey];  // 计算key
    
    [self.requestsCacheDic setObject:_currentRequestDataDic forKey:key];  // 存储当前请求
}

/**
 *  根据过期时间移除请求  **未使用
 */
- (void)removeRequestWithExpirationTime {
    NSArray *sortedkeys = [self.requestsCacheDic keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    for (NSString *categoryId in sortedkeys) {
        NSLog(@"key = %@, value = %@",categoryId,_requestsCacheDic[categoryId]);
    }
    
    for (NSString *categoryId in sortedkeys) {
        if ([self isOverdue:_requestsCacheDic[categoryId]]) {
            [_requestsCacheDic removeObjectForKey:categoryId];
        }
        
    }
    NSLog(@"dic = %@",_requestsCacheDic);
}

/**
 *  将请求存进文件
 *
 *  @param  save       YES:写入    NO:删除
 *  @return BOOL       YES:写入成功   NO:写入失败
 */
- (BOOL)writeRequestsData:(BOOL)save {
    NSLog(@"%s", __func__);
    BOOL isSucc;
    if (save) {  // 写入新数据
        isSucc = [_requestsCacheDic writeToFile:FILEPATH atomically:YES];
    } else {  // 删除数据，这里写一个空的dictionary
        isSucc = [[NSDictionary dictionary] writeToFile:FILEPATH atomically:YES];
    }
    
    NSMutableArray *data1 = [[NSMutableArray alloc] initWithContentsOfFile:FILEPATH];
    NSLog(@"%@", data1);
    return isSucc;
}


#pragma mark 重新加载
/**
 *  重新加载事件
 */
- (void)reloadAction:(UIButton *)btn {
    
    //    [self hiddenAllViews];
    //    [self removeAllViews];
    if (self.uploadImgBlock) {
        [self post:self.paraUrl parameters:self.paraDic token:self.paraToken uploadImg:self.uploadImgBlock success:self.paraSuccess failure:self.paraFailure onView:self.myHttpView saveFlag:NO getFlag:NO];
        
    } else {
        [self post:self.paraUrl parameters:self.paraDic token:self.paraToken success:self.paraSuccess failure:self.paraFailure onView:self.myHttpView saveFlag:NO getFlag:NO];
    }
    
}


#pragma mark - 请求成功后添加自己效果
/**
 *  请求成功后自己回调
 */
- (completeBlock)myCompleteBlock {
    if (_myCompleteBlock == nil) {
        __weak __typeof(self)weakSelf = self;
        _myCompleteBlock = ^(void) {
            NSLog(@"%@", weakSelf);
            //            weakself.myHttpView.backgroundColor = [UIColor blueColor];
        };
    }
    return _myCompleteBlock;
}

/**
 *  请求成功后添加自己想要的效果
 */
-(void)setUpView{
    if (self.myCompleteBlock) {
        _myCompleteBlock();
    }
}

#pragma mark - getter
- (NSMutableDictionary *)requestsCacheDic {
    if (_requestsCacheDic == nil) {
        _requestsCacheDic = [NSMutableDictionary dictionaryWithContentsOfFile:FILEPATH];
    }
    if (_requestsCacheDic == nil) {
        _requestsCacheDic = [NSMutableDictionary dictionary];
    }
    return _requestsCacheDic;
}

#pragma mark - 控件(修改空、加载中、加载失败修改此处)
- (UIView *)emptyView {
    if (_emptyView == nil) {
        _emptyView = [[DGJHttpView alloc] initEmptyViewWithFatherView:_myHttpView];
        id weakSelf = self;
        self.emptyView.reloadBlock = ^() {
            NSLog(@"~~~~~~~~~~~");
            NSLog(@"reloadBlockweakself %@", weakSelf);
            [weakSelf reloadAction:nil];
        };
    }
    return _emptyView;
}

- (UIView *)loadingView {
    if (_loadingView == nil) {
        _loadingView = [[DGJHttpView alloc] initLoadingViewWithFatherView:_myHttpView];
        
    }
    return _loadingView;
}

- (UIView *)failedView {
    if (_failedView == nil) {
        _failedView = [[DGJHttpView alloc] initFailedViewWithFatherView:_myHttpView];
        id weakSelf = self;
        self.failedView.reloadBlock = ^() {
            NSLog(@"~~~~~~~~~~~");
            NSLog(@"reloadBlockweakself %@", weakSelf);
            [weakSelf reloadAction:nil];
        };
    }
    return _failedView;
}

#pragma mark - 设置状态框
/**
 *  隐藏所有view(加载、失败、空)
 */
- (void)hiddenAllViews {
    if (self.myHttpView) {
        _failedView.hidden = YES;
        _emptyView.hidden = YES;
        _loadingView.hidden = YES;
    }
}

/**
 *  显示所有view(加载、失败、空)
 */
- (void)showAllViews {
    if (self.myHttpView) {
        _failedView.hidden = NO;
        _emptyView.hidden = NO;
        _loadingView.hidden = NO;
    }
}

/**
 *  移除所有view(加载、失败、空)
 */
- (void)removeAllViews {
    if (self.myHttpView) {
        [self.loadingView removeFromSuperview];
        [self.emptyView removeFromSuperview];
        [self.failedView removeFromSuperview];
    }
}
/**
 *  添加所有view
 */
- (void)addSubViews {
    [self.myHttpView addSubview:self.emptyView];
    [self.myHttpView addSubview:self.loadingView];
    [self.myHttpView addSubview:self.failedView];
}


#pragma mark 显示状态框（修改网络提示（失败）修改此处）
/**
 *  显示网络失败状态框
 */
- (void)showToastViewWithInfo:(NSString *)str {
    NSTimeInterval delay = 3;  // delay秒后消失
    
    if (self.myHttpView) {
        [self removeAllViews];
        MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:_myHttpView];
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = str;
        [HUD show:YES];
        [_myHttpView addSubview:HUD];
        HUD.color = [UIColor colorWithRed:0.23 green:0.50 blue:0.82 alpha:0.90];
        [HUD hide:YES afterDelay:delay];
        
    }
}

/**
 *  显示加载中状态框
 */
- (void)showLoadingView {
    if (self.myHttpView) {
        [self hiddenAllViews];
        _loadingView.hidden = NO;
    }
}

/**
 *  显示加载成功状态框
 */
- (void)showLoadSuccessView {
    if (self.myHttpView) {
        [self hiddenAllViews];
        [self removeAllViews];
        [self setUpView];
    }
}

/**
 *  显示加载成功不刷新状态框
 */
- (void)showLoadEmptyView {
    if (self.myHttpView) {
        [self hiddenAllViews];
        
        _emptyView.hidden = NO;
    }
}

/**
 *  显示加载失败状态框
 */
- (void)showLoadFailedView {
    if (self.myHttpView) {
        [self hiddenAllViews];
        _failedView.hidden = NO;
    }
}


/**
 *  根据传进来的errorCode返回一个相应的错误描述
 */
- (NSString *)errorStringWithErrorCode:(NSInteger)errorCode {
    NSString *error = @"加载失败";
    switch (errorCode) {
        case 400:
            error = @"普通错误 ";
            NSLog(@"%@",error);
            break;
        case 401:
            error = @"未通过用户认证";
            NSLog(@"%@",error);
            break;
        case 404:
            error = @"未找到资源";
            NSLog(@"%@",error);
            break;
        case 410:
            error = @"TOKEN错误";
            NSLog(@"%@",error);
            break;
        case 411:
            error = @"签名错误";
            NSLog(@"%@",error);
            break;
        case 500:
            error = @"服务错误";
            NSLog(@"%@",error);
            break;
        case 600:
            error = @"网络错误";
            NSLog(@"%@",error);
            break;
        default:
            break;
    }
    return error;
}

/**
 *  显示加载失败状态框
 */
- (void)showLoadFailedViewWithError:(NSString *)error {
    if (self.myHttpView) {
        [self.failedView setHttpLabelText:error];
        
        //         __weak __typeof(self)weakSelf = self;
        id weakSelf = self;
        NSLog(@"weakself %@", weakSelf);
        
        self.failedView.reloadBlock = ^() {
            NSLog(@"~~~~~~~~~~~");
            NSLog(@"reloadBlockweakself %@", weakSelf);
            [weakSelf reloadAction:nil];
            //            [self reloadAction:nil];
        };
        
        [self showLoadFailedView];
    }
}

#pragma mark - 清空缓存

/**
 *  清空过期缓存
 */
- (void)removeAllRequestsExpirationCache {
    
    NSArray *array = [self.requestsCacheDic allKeys];  // 取出每条请求的key
    if (array.count == 0) {  // array == 0说明没有存储请求数据
        return;
    }
    for (int i = 0; i<array.count; i++) {
        NSString *key = array[i];
        NSDictionary *requestDic = _requestsCacheDic[key];  // 取出每条数据过期时间
        if ([self isOverdue:requestDic[@"date"]]) {  // 数据已过期，删除该条数据
            [_requestsCacheDic removeObjectForKey:key];
        }
    }
}


//MD5转换
- (NSString *)sign:(NSDictionary *)parameters{
    NSString *sign = SECRET_KEY;
    
    //  NSLog(@"parameters ==== %@",parameters);
    
    if (parameters) {
        NSMutableArray *array = [NSMutableArray arrayWithArray:parameters.allKeys];
        
        int count =(int)[array count];
        
        for(int j = 0; j <count-1; j++){
            
            for(int i = 0; i < [array count]-1-j; i++){
                NSString *a = (NSString *)[array objectAtIndex:i];
                NSString *b = (NSString *)[array objectAtIndex:(i+1)];
                if ([a compare:b] == NSOrderedDescending) {
                    [array exchangeObjectAtIndex:i withObjectAtIndex:(i+1)];
                }
            }
        }
        NSMutableArray *values = [[NSMutableArray alloc] init];
        for (int i = 0; i < [array count]; i++) {
            NSString *key = [array objectAtIndex:i];
            if ([[parameters objectForKey:key] isKindOfClass:[NSMutableArray class]]) {
                NSArray *valueArr = parameters[key];
                NSArray *newArr = [valueArr sortedArrayUsingSelector:@selector(compare:)];
                NSMutableString *totalStr = [NSMutableString string];
                for(NSString *str in newArr)
                {
                    [totalStr appendString:str];
                }
                [values addObject:totalStr];
            }else {
                [values addObject:[parameters objectForKey:key]];
            }
        }
        sign = [NSString stringWithFormat:@"%@%@", [values componentsJoinedByString:@""],SECRET_KEY];
    }
    NSLog(@"[sign stringFromMD5] ========= %@",[sign stringFromMD5]);
    
    return [sign stringFromMD5];
}

/**
 *  清空所有缓存
 */
- (void)removeAllRequestsCache {
    [self writeRequestsData:NO];
}



@end
