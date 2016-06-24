//
//  DGJNetHeader.h
//  OurMemories
//
//  Created by LanHai on 16/5/30.
//  Copyright © 2016年 斗高甲. All rights reserved.
//

#ifndef DGJNetHeader_h
#define DGJNetHeader_h

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

#endif /* DGJNetHeader_h */
