//
//  ZWFileApi.m
//  netDemo
//
//  Created by gao on 15/11/11.
//  Copyright © 2015年 zwyl. All rights reserved.
//

#import "ZWFileApi.h"

@implementation ZWFileApi

+ (NSString*)getHomeDir {
    NSString* homeDir = NSHomeDirectory();
    // NSLog(@"app home directory is : %@", homeDir);
    return homeDir;
}

+ (NSString*)getDocumentDir {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    // NSLog(@"app document directory is : %@", documentsDirectory);
    return documentsDirectory;
}

+ (NSString*)getLibraryDir {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* libraryDirectory = [paths objectAtIndex:0];
    //NSLog(@"app library directory is : %@", libraryDirectory);
    return libraryDirectory;
}

+ (NSString*)getLibraryCacheDir {
    NSArray* cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [cachePaths objectAtIndex:0];
    //NSLog(@"app cache dirctory is : %@", cachePath);
    return cachePath;
}

+ (NSString*)getTempDir {
    NSString* tmpDirectory = NSTemporaryDirectory();
    //NSLog(@"app tmp dirctory is : %@", tmpDirectory);
    return tmpDirectory;
}

+ (NSString*)generateRandomFileName {
    return @"";
}

+ (NSString*)createFile:(NSString*)filePath fileName:(NSString*)name {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* path = [filePath stringByAppendingPathComponent:name];
    if ([fileManager createFileAtPath:path contents:nil attributes:nil]) {
        return path;
    } else {
        return nil;
    }
}

+ (NSString*)createFile:(NSString*)file {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if ([fileManager createFileAtPath:file contents:nil attributes:nil]) {
        return file;
    } else {
        return nil;
    }
}

+ (void)createFile:(NSString*)file
          withData:(NSData*)data
     callbackQueue:(dispatch_queue_t)queue
     taskDoneBlock:(taskCompletionBlock)taskDoneBlock
        errorBlock:(errorHandlerBlock)errorBlock
{
    NSError* error = nil;
    if (![data writeToFile:file options:NSDataWritingAtomic error:&error]) {
        NSLog(@"Write file error: %@", error);
        dispatch_async(queue, ^{
            //errorBlock ? errorBlock(error) : nil;
            if (errorBlock)
                errorBlock(error);
        });
    } else {
        dispatch_async(queue, ^{
            //taskDoneBlock ? taskDoneBlock() : nil;
            if (taskDoneBlock)
                taskDoneBlock();
        });
    }
}

+ (long long)getFileSize:(NSString*)filePath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+ (NSString*)getFileNameFromFilePath:(NSString*)filePath {
    return [filePath lastPathComponent];
}

+ (NSString*)getFileNameWithoutExtensionFromFilePath:(NSString*)filePath {
    return [filePath stringByDeletingPathExtension];
}

+ (NSString*)getExtensionPartFromFilePath:(NSString*)filePath {
    return [filePath pathExtension];
}

@end
