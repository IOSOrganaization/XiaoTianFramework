//
//  XTFUtilEnvironment.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 1/12/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "XTFMylog.h"

@interface XTFUtilEnvironment : NSObject

// 获取系统 Info
+(NSString *) pathDocument;// Document 目录
+(NSString *) pathApplication;// 程序目录
+(NSString *) pathCache;// 缓冲目录
+(NSString *) pathHome;// Home目录
+(NSString *) pathBundleFile:(NSString *) filename;// 获取Bundle可执行APP目录中的文件
+(NSString *) pathDocumentFile:(NSString *) filename;// 获取Document目录中的文件


+(BOOL) isIphone;// IPhone设备
+(BOOL) copyFileFromBundleToDocument:(NSString *)bundleFile error:(NSError *)error;
+(BOOL) copyFileFromBundleToDocument:(NSString *)bundleFile toFile:(NSString*)toFile error:(NSError *)error;

// 输出系统 Info
+(void) infoFontFamilyNames;//输出系统字体
@end
