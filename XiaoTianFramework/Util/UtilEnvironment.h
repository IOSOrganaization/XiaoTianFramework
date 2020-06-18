//
//  UtilEnvironment.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 1/12/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//
NS_ASSUME_NONNULL_BEGIN

@interface UtilEnvironment : NSObject

// 获取系统 Info
/// Home目录
+(NSString *) pathHome;
/// Document目录
+(NSString *) pathDocument;
/// Download目录
+(NSString *) pathDownload;
/// 缓冲目录
+(NSString *) pathCache;
/// 临时目录
+(NSString *) pathTmp;
/// 程序目录
+(NSString *) pathApplication;
/// 获取Bundle可执行APP目录中的文件
+(NSString *) pathBundleFile:(NSString *) filename;
/// 获取Document目录中的文件
+(NSString *) pathDocumentFile:(NSString *) filename;

// 硬件信息
+(NSString*)deviceInfo;
+(NSString*)getDeviceName;
+(NSString*)version;
+(NSString*)build;
/// 在秘钥链中获取或生成随机UUID并存储到秘钥链
+(NSString*)uuid;
// 软件信息
+(BOOL) isIPhone;// IPhone设备
+(BOOL) isStyleDark;
+(BOOL) copyFileFromBundleToDocument:(NSString *)bundleFile error:(NSError *)error;
+(BOOL) copyFileFromBundleToDocument:(NSString *)bundleFile toFile:(NSString*)toFile error:(NSError *)error;

// 输出系统 Info
+(void) infoFontFamilyNames;//输出系统字体
@end

NS_ASSUME_NONNULL_END
