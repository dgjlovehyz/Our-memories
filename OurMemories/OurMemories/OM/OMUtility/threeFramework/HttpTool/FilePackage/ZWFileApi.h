//
//  ZWFileApi.h
//  netDemo
//
//  Created by gao on 15/11/11.
//  Copyright © 2015年 zwyl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWNetHeader.h"

@interface ZWFileApi : NSObject

// 获取应用沙盒根路径.
+ (NSString*)getHomeDir;

// Documents：苹果建议将程序创建产生的文件以及应用浏览产生的文件数据保存在该目录下，iTunes备份和恢复的时候会包括此目录
+ (NSString*)getDocumentDir;

// Library：存储程序的默认设置或其它状态信息
+ (NSString*)getLibraryDir;

// Library/Caches：存放缓存文件，保存应用的持久化数据，用于应用升级或者应用关闭后的数据保存，不会被itunes同步，所以为
// 了减少同步的时间，可以考虑将一些比较大的文件而又不需要备份的文件放到这个目录下。
+ (NSString*)getLibraryCacheDir;

// tmp：提供一个即时创建临时文件的地方，但不需要持久化，在应用关闭后，该目录下的数据将删除，也可能系统在程序不运行的时候清除
+ (NSString*)getTempDir;

// 产生一个随机的文件名.
+ (NSString*)generateRandomFileName;

// 按照给定的path 和 文件名 创建该文件，创建成功后，返回该文件的绝对路径。
+ (NSString*)createFile:(NSString*)filePath fileName:(NSString*)name;

// 创建指定的file。（file指定了文件的绝对路径）
+ (NSString*)createFile:(NSString*)file;

+ (void)createFile:(NSString*)file
          withData:(NSData*)data
     callbackQueue:(dispatch_queue_t)queue
     taskDoneBlock:(taskCompletionBlock)taskDoneBlock
        errorBlock:(errorHandlerBlock)errorBlock;

+ (long long)getFileSize:(NSString*)filePath;

// "/var/foo.txt" -> "foo.txt"
+ (NSString*)getFileNameFromFilePath:(NSString*)filePath;

// "/var/foo.txt" -> "foo"
+ (NSString*)getFileNameWithoutExtensionFromFilePath:(NSString*)filePath;

// "/var/foo.txt" -> "txt"
+ (NSString*)getExtensionPartFromFilePath:(NSString*)filePath;

@end
