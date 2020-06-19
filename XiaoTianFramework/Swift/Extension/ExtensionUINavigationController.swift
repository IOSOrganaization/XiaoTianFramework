//
//  ExtensionNavigationViewController.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/5/25.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController: UIGestureRecognizerDelegate{
    private struct AssociatedKeys{
        static var CacheDefaultInteractivePopGestureRecognizerKey = "Extension_UINavigationController_CacheDefaultInteractivePopGestureRecognizerKey"
    }
    //苹果审核可能会拒绝的方法: dynamic methods such as dlopen(), dlsym(), respondsToSelector:, performSelector:, method_exchangeImplementations()
    //可以把框架打成静态包模式,在代码层屏蔽苹果审核
    private var cacheDefaultInteractivePopGestureRecognizer: UIGestureRecognizerDelegate?{
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.CacheDefaultInteractivePopGestureRecognizerKey) as? UIGestureRecognizerDelegate
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.CacheDefaultInteractivePopGestureRecognizerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    // 全局单例
    private class var sharedOnceInitPopViewController : InitializePopViewControllerMethodSwizzling {
        struct Static{
            static let instanceResult = InitializePopViewControllerMethodSwizzling()
        }
        return Static.instanceResult
    }
    
    //open override class func initialize(){ // OBJC 每次创建实例化都会触发这个方法
    //It is not possible to override functionality (like properties or methods) in extensions as documented in Apple's Swift Guide.
    //
    //Extensions can add new functionality to a type, but they cannot override existing functionality.
    //Apple Developer Guide
    //The compiler is allowing you to override in the extension for compatibility with Objective-C. But it's actually violating the language directive.
    //
    // Directive Notes
    // You can only override a superclass method i.e. load() initialize()in an extension of a subclass if the method is Objective-C compatible.
    // Therefore we can take a look at why it is allowing you to compile using layoutSubviews.
    // All Swift apps execute inside the Objective-C runtime except for when using pure Swift-only frameworks which allow for a Swift-only runtime.
    // As we found out the Objective-C runtime generally calls two class main methods load() and initialize() automatically when initializing classes in your app’s processes.
    //let _ = sharedOnceInitPopViewController
    //}
    
    private class InitializePopViewControllerMethodSwizzling{
        init() {
            // Pop Button
            let shouldPop = #selector(UINavigationBarDelegate.navigationBar(_:shouldPop:))
            let xiaotianShouldPopViewController = #selector(UINavigationController.xiaotianShouldPopViewController(_:_:))
            UtilRuntimeSwift.exchangeMethod(UINavigationController.self, shouldPop, xiaotianShouldPopViewController)
            // Cancel Gesture Right
            let viewDidLoad = #selector(UINavigationController.viewDidLoad)
            let xiaotianViewDidLoad = #selector(UINavigationController.xiaotianViewDidLoad)
            UtilRuntimeSwift.exchangeMethod(UINavigationController.self, viewDidLoad, xiaotianViewDidLoad)
        }
    }
    // 重写划回手势处理
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer != self.interactivePopGestureRecognizer{
            return true
        }
        guard let isPop = self.visibleViewController?.executeNavigationPopGestureRecognizer() else {
            return false
        }
        if !isPop{
            return false
        }
        guard let result = self.cacheDefaultInteractivePopGestureRecognizer?.gestureRecognizerShouldBegin?(gestureRecognizer) else{
            return false
        }
        return result
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer != self.interactivePopGestureRecognizer{
            return false
        }
        guard let result = self.cacheDefaultInteractivePopGestureRecognizer?.gestureRecognizer?(gestureRecognizer, shouldRecognizeSimultaneouslyWith:otherGestureRecognizer) else{
            return  false
        }
        return result
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        guard let result = self.cacheDefaultInteractivePopGestureRecognizer?.gestureRecognizer?(gestureRecognizer, shouldRequireFailureOf: otherGestureRecognizer) else{
            return  false
        }
        return result;
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == self.interactivePopGestureRecognizer
    }
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer != self.interactivePopGestureRecognizer{
            return true
        }
        guard let isEnable = self.interactivePopGestureRecognizer?.isEnabled else{
            return true
        }
        guard let isPop = self.visibleViewController?.executeNavigationPopGestureRecognizer() else {
            return true
        }
        if isEnable && isPop{
            guard let result = self.cacheDefaultInteractivePopGestureRecognizer?.gestureRecognizer?(gestureRecognizer, shouldReceive: touch) else {
                return true
            }
            return result
        }
        return true
    }
    @objc
    private dynamic func xiaotianShouldPopViewController(_ navigationBar: UINavigationBar,_ shouldPopItem:UINavigationItem)-> Bool{
        // 代码pop不受这个方法限制,因为pop后才会触发这个方法(用于改变navigationbar控制器的UI栈)
        let viewController:UIViewController = self.visibleViewController!
        // 点击返回键,topViewController.navigationItem = shouldPopItem
        let backButtonPopable = viewController.navigationItem == shouldPopItem && self.canPopViewController(viewController, shouldPopItem)
        // 代码pop返回,shouldPopItem等于上一个已出栈的VC 的navigationItem(用于nabigationbar的UI栈的改变)
        let codePop = viewController.navigationItem != shouldPopItem
        //
        if backButtonPopable || codePop{
            // 可返回/已经Pop,调用原来的被替换的方法
            return self.xiaotianShouldPopViewController(navigationBar, shouldPopItem) // navigationBar:shouldPop:
        } else {
            // 不可返回,不处理
            // Workaround for >= iOS7.1. Thanks to @boliva - http://stackoverflow.com/posts/comments/34452906
            for subview in navigationBar.subviews { // 恢复点击触摸变暗
                if subview.alpha < 1.0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        subview.alpha = 1.0
                    })
                }
            }
        }
        return backButtonPopable
    }
    
    /// 是否可以pop的视图控制器,VC重写canPopViewController方法
    private func canPopViewController(_ popViewController: UIViewController?,_ navigationItem:UINavigationItem?) -> Bool{
        guard let isPop = popViewController?.executeNavigationBackButtonItem(navigationItem) else {
            return true
        }
        return isPop
    }
    @objc
    private dynamic func xiaotianViewDidLoad(){
        self.xiaotianViewDidLoad() // 调用原来的被替换的方法 viewDidLoad
        cacheDefaultInteractivePopGestureRecognizer = self.interactivePopGestureRecognizer?.delegate // 缓冲
        self.interactivePopGestureRecognizer?.delegate = nil // 重写 GestureDelegate
        self.interactivePopGestureRecognizer?.delegate = self
    }
}
