//
//  XTFUtilLocation.m
//  XiaoTianFramework
//  
//  Created by XiaoTian on 1/5/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//

#import "XTFUtilLocation.h"

@implementation XTFUtilLocation


// 获取地域字符串
+(NSString*) string:(NSString*) name{
    return [self string:name comment:nil];
}
+(NSString*) string:(NSString*) name comment:(NSString*) comment{
    return NSLocalizedString(name, comment);
}


@end
