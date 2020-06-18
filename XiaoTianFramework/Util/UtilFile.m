//
//  UtilFile.m
//  XiaoTianFramework
//  文件
//  Created by XiaoTian on 1/12/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//

#import "UtilFile.h"

@implementation UtilFile

/// 文件/文件夹是否存在
+(BOOL) existFile:(NSString *)file{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName = [file lastPathComponent];
    NSString* fileDir = [file substringToIndex:[file rangeOfString:fileName].location];
    if([fileManager fileExistsAtPath:fileDir isDirectory:nil]){
        return YES;
    }
    return [fileManager fileExistsAtPath:file];
}
@end
