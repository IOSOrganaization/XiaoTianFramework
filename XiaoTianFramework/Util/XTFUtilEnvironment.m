//
//  XTFUtilEnvironment.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 1/12/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//
#import "XTFUtilEnvironment.h"

@implementation XTFUtilEnvironment

#pragma mark - 文件路径
+(NSString *) pathDocument{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [paths objectAtIndex:0];
    return document;
}

+(NSString *) pathApplication{
    return [[NSBundle mainBundle] bundlePath];
}

+(NSString *) pathCache{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    return cachesDir;
}

+(NSString *) pathHome{
    NSString *homeDir = NSHomeDirectory();
    return homeDir;
}

+(NSString *) pathBundleFile:(NSString*) filename{
    NSRange range = [filename rangeOfString:@"." options:NSBackwardsSearch];
    NSString *name = [filename substringToIndex:range.location];
    NSString *type = [filename substringFromIndex:range.location];
    return [[NSBundle mainBundle] pathForResource:name ofType:type];
}

+(NSString *) pathDocumentFile:(NSString*) filename{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pathDocumentFile = [documentsDirectory stringByAppendingPathComponent:filename];
    return pathDocumentFile;
}

#pragma mark - 文件操作
+(BOOL) copyFileFromBundleToDocument:(NSString *)bundleFile error:(NSError *)error{
    BOOL success = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *toPath = [documentsDirectory stringByAppendingPathComponent:bundleFile];
    NSString *fromPath = [self pathBundleFile:bundleFile];
    if ([fileManager fileExistsAtPath:toPath] == NO && [fileManager fileExistsAtPath:fromPath] == YES) {
            success = [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];
    }
    return success;
}

+(BOOL) copyFileFromBundleToDocument:(NSString *)bundleFile toFile:(NSString*)toFile error:(NSError *)error{
    BOOL success = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *toPath = [documentsDirectory stringByAppendingPathComponent:toFile];
    NSString *fromPath = [self pathBundleFile:bundleFile];
    if ([fileManager fileExistsAtPath:toPath] == NO && [fileManager fileExistsAtPath:fromPath] == YES) {
        success = [fileManager copyItemAtPath:fromPath toPath:toPath error:&error];
    }
    return success;
}

#pragma mark - 系统环境
+(BOOL) isIphone{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

#pragma mark - 系统属性信息
// 输出系统环境下得字体
+(void) infoFontFamilyNames{
    NSArray *familyNames = [UIFont familyNames];
    for (NSString *aFamilyName in familyNames) {
        NSArray *fontNames = [UIFont fontNamesForFamilyName:aFamilyName];
        for (NSString *aFontName in fontNames) {
            [XTFMylog info: aFontName];
        }
    }
}
@end
