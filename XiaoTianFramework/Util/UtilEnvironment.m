//
//  UtilEnvironment.m
//  XiaoTianFramework
//  系统环境参数
//  Created by XiaoTian on 1/12/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//
#import "UtilEnvironment.h"
#import "Mylog.h"
#import "sys/utsname.h"
#import "UtilKeyChain.h"

@implementation UtilEnvironment

#pragma mark - 文件路径(Home目录下)
+(NSString *) pathHome{
    NSString *homeDir = NSHomeDirectory();
    return homeDir;
}
+(NSString *) pathDocument{
    //return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [paths objectAtIndex:0];
    return document;
}
+(NSString *) pathDownload{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    return cachesDir;
}
+(NSString *) pathCache{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = [paths objectAtIndex:0];
    return cachesDir;
}
+(NSString *) pathTmp{
    return NSTemporaryDirectory();
}
+(NSString *) pathApplication{
    return [[NSBundle mainBundle] bundlePath];
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

/// 系统环境
+ (NSString *)deviceInfo{
    UIScreen *uiScreen = [UIScreen mainScreen];
    NSMutableString* ms = [[NSMutableString alloc] initWithString:@"{"];
    //[ms appendFormat:@"\"DEBUG\":\"%@\"",@(DEBUG)];
    [ms appendFormat:@",\"device\":\"%@\"",[UtilEnvironment getDeviceName]];//硬件版本
    [ms appendFormat:@",\"systemVersion\":\"%@\"",[UIDevice currentDevice].systemVersion];//软件版本
    [ms appendFormat:@",\"Version\":\"%@\"",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];//app版本名
    [ms appendFormat:@",\"Build\":\"%@\"",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];//app版本号
    [ms appendFormat:@",\"Screen\":\"%@*%@\"",@(uiScreen.bounds.size.width * uiScreen.scale),@(uiScreen.bounds.size.height * uiScreen.scale)];//屏幕分辨率
    [ms appendString:@"}"];
    return ms;
}
+(NSString*)version{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
+(NSString*)build{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}
+(BOOL) isIphone{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}
//+(BOOL) isIPhoneX{//刘海屏
//    return [[UIScreen mainScreen] bounds].size.width >=375.0f && [[UIScreen mainScreen] bounds].size.height >=812.0f;
//}
+(BOOL) isStyleDark{
    if (@available(iOS 13.0, *)) {
        return [[UITraitCollection currentTraitCollection] userInterfaceStyle] == UIUserInterfaceStyleDark;
    } else {
        return NO;
    }
}
+(NSString*)uuid{
    // 从秘钥链中读取(格式化后没了)
    NSString* uid = [[UtilKeyChain share] getKeyChainData:@"UtilEnvironment_uuid"];
    if(uid) return uid;
    // 创建随机UUID
    CFUUIDRef uuidRef= CFUUIDCreate(kCFAllocatorDefault);
    uid = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
    // 保存到秘钥链中
    [[UtilKeyChain share] addKeyChainData:uid key:@"UtilEnvironment_uuid"];
    return uid;
}
// 数据存储: 归档，NSUserDefault，Core Data，sqlite，plist，文件(沙盒包含: 应用程序包、Documents、Libaray（下面有Caches和Preferences目录）、tmp
/// 系统属性信息
// 输出系统环境下得字体
+(void) infoFontFamilyNames{
    NSArray *familyNames = [UIFont familyNames];
    for (NSString *aFamilyName in familyNames) {
        NSArray *fontNames = [UIFont fontNamesForFamilyName:aFamilyName];
        for (NSString *aFontName in fontNames) {
            [Mylog info: aFontName];
        }
    }
}

/// 获取设备型号然后手动转化为对应名称
+(NSString *)getDeviceName{
    //https://www.jianshu.com/p/b23016bb97af
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"国行、日版、港行iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"港行、国行iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"美版、台版iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"美版、台版iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"国行(A1863)、日行(A1906)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"美版(Global/A1905)iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"国行(A1864)、日行(A1898)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"美版(Global/A1897)iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"国行(A1865)、日行(A1902)iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"美版(Global/A1901)iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"国行iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,11"])     return @"iPad 5 (WiFi)";
    if ([deviceString isEqualToString:@"iPad6,12"])     return @"iPad 5 (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,1"])      return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,2"])      return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,3"])      return @"iPad Pro 10.5 inch (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,4"])      return @"iPad Pro 10.5 inch (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,5"])      return @"iPad 6th generation";
    if ([deviceString isEqualToString:@"iPad7,6"])      return @"iPad 6th generation";
    if ([deviceString isEqualToString:@"iPad8,1"])      return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,2"])      return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,3"])      return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,4"])      return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,5"])      return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,6"])      return @"iPad Pro (12.9-inch) (3rd generation)";
    if ([deviceString isEqualToString:@"iPad8,7"])      return @"iPad Pro (12.9-inch) (3rd generation)";
    
    if ([deviceString isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])   return @"Apple TV 4";
    
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceString;
}
@end
