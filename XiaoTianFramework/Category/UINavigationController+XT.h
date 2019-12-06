//
//  UINavigationController+XT.h
//  XiaoTianFramework
//  导航控制容器
//  Created by XiaoTian on 12/31/14.
//  Copyright (c) 2014 XiaoTian. All rights reserved.
//

#import "Mylog.h"

@interface UINavigationController (XT)

// 初始化导航控制容器
+(instancetype) initWithLeftText:(NSString*) left leftIcon:(NSString*)leftIcon title:(NSString*) title rightText:(NSString*) rightText rightIcon:(NSString*)rightIcon target:(Class) targetPageClass;

//
@end
