//
//  UtilRuntime.swift
//  XiaoTianFramework
//  运行时
//  Created by guotianrui on 2017/5/25.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilRuntimeSwiftXT)
open class UtilRuntimeSwift: NSObject{
    //
    public static func exchangeMethod(_ clazz: AnyClass,_ originalSelector: Selector,_ swizzledSelector: Selector){
        let originalMethod = class_getInstanceMethod(clazz, originalSelector)// 原方法
        let swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector)// 变形方法
        // 添加自定义的方法到指定的类里面,如果添加成功则返回true,否则false[已经存在]
        let didAddMethod = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        if didAddMethod {
            // 添加成功,替换原方法
            class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        } else {
            // 交换两个方法的实现
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        /*
         Attention: add "dynamic" keyword in front of method name!!!
         
         Answer Detail:
         Method swizzling is a technique that substitutes one method implementation for another. If you're not familiar with swizzling, check out this blog post. Swift optimizes code to call direct memory addresses instead of looking up the method location at runtime as in Objective-C. So by default swizzling doesn’t work in Swift classes unless we:
         1. Disable this optimization with the dynamic keyword. This is the preferred choice, and the choice that makes the most sense if the codebase is entirely in Swift.
         2. Extend NSObject. Never do this only for method swizzling (use dynamic instead). It’s useful to know that method swizzling will work in already existing classes that have NSObject as their base class, but we're better off selectively choosing methods with dynamic .
         3. Use the @objc annotation on the method being swizzled. This is appropriate if the method we would like to swizzle also needs to be exposed to Objective-C code at the same time.
         */
    }
    //
}
