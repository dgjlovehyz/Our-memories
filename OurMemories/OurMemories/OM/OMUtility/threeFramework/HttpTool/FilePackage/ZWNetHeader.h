//
//  ZWNetHeader.h
//  netDemo
//
//  Created by gao on 15/11/9.
//  Copyright © 2015年 zwyl. All rights reserved.
//

#ifndef ZWNetHeader_h
#define ZWNetHeader_h

typedef void(^completionBlock)(NSDictionary* json);
typedef void(^errorHandlerBlock)(NSError* error);
typedef void(^downloadCompletionBlock)(NSData* data);
typedef void(^taskCompletionBlock)(void);
typedef void(^uploadCompletionBlock)(NSNumber* fileID, NSString* fileURL);
typedef void(^uploadErrorBlock)(NSString* errorMsg);
typedef void(^loginSucessBlock)(BOOL needFinishPersonalInfo);
typedef void(^loginFailedBlock)(NSError* error);
typedef void(^cacheCompletionBlock)(void);
typedef void(^readCacheCompletionBlock)(NSArray* cacheData);

#endif /* ZWNetHeader_h */
