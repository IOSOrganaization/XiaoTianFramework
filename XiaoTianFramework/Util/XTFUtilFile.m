//
//  XTFUtilFile.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 1/12/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//

#import "XTFUtilFile.h"

@implementation XTFUtilFile

+(BOOL) existFile:(NSString *)file{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:file];
}
@end
