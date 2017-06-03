//
//  UtilRuntime.m
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/5/25.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

#import "XTFUtilRuntime.h"
@import ObjectiveC.runtime;

@implementation XTFUtilRuntime

// 交换实现
+(void) exchangeMethodImplementations: (Class) clazz originalSelector:(SEL) originalSelector  swizzledSelector:(SEL) swizzledSelector{
    struct objc_method* originalMethod = class_getInstanceMethod(clazz, originalSelector);
    struct objc_method* swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector);
    // 添加自定义的方法到指定的类里面,如果添加成功则返回true,否则false[已经存在]
    BOOL didAddMethod = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        // 添加成功,替换原方法
        class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        // 交换两个方法的实现
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }

}

@end
