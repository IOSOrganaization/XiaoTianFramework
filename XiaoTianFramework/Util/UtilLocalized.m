//
//  UtilLocalized.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 2019/12/5.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import "UtilLocalized.h"

@implementation UtilLocalized
/// 获取地域字符串
+(NSString*) string:(NSString*) name{
    return [self string:name comment:nil];
}
+(NSString*) string:(NSString*) name comment:(NSString* _Nullable) comment{
    return NSLocalizedString(name, comment);
}

@end
