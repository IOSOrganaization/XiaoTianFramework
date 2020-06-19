//
//  ExtensionUIViewController.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/5/24.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController{
    private struct AssociatedKeys{
        static var descriptiveName = "UIViewController_AssociatedKeys_descriptiveName"
    }
    fileprivate var descriptiveName: String? {
        get{
            return objc_getAssociatedObject(self, &AssociatedKeys.descriptiveName) as? String
        }
        set{
            if let newValue = newValue{
                objc_setAssociatedObject(self, &AssociatedKeys.descriptiveName, newValue as NSString?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    // 全局单例
    private class var sharedOnce : InitializeMethodSwizzling? {
        struct Static{
            static let instanceResult = InitializeMethodSwizzling()
        }
        return Static.instanceResult
    }
    // 方法交叉,方法混合,方法替换
    // Method swizzling lets you swap the implementations of two methods, essentially overriding an existing method with your own while keeping the original around.
    //open override class func initialize(){ // OBJC 每次创建实例化都会触发这个方法(Swift4被禁)
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
    //    let _ = sharedOnce
    //}
    
    fileprivate class InitializeMethodSwizzling{
        init() {
            Mylog.log("方法交叉,方法混合,方法替换[获取两个方法的实现指针,然后两个方法的实现指针交换]")
            let originalSelector = #selector(UIViewController.viewWillAppear(_:)) // 原方法
            let swizzledSelector = #selector(UIViewController.nsh_viewWillAppear(_:))// 变形方法
            let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
            // 添加自定义的方法到指定的类里面,如果添加成功则返回true,否则false[已经存在]
            let didAddMethod = class_addMethod(UIViewController.self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
            if didAddMethod {
                // 添加成功,替换原方法
                Mylog.log("添加成功,替换原类方法")
                class_replaceMethod(UIViewController.self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                // 交换两个方法的实现
                Mylog.log("添加失败,交换两个方法的实现指针")
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }
        }
    }
    
    // 用这个方法替换系统方法
    @objc
    dynamic public func nsh_viewWillAppear(_ animated: Bool) {
        // self 当前的实体类,extension 不属于self
        self.nsh_viewWillAppear(animated)
        if let name = self.descriptiveName {
            Mylog.log("viewWillAppear: \(name)")
        } else {
            Mylog.log("viewWillAppear: \(self)")
        }
    }
    open func executeNavigationBackButtonItem(_ navigationItem: UINavigationItem?) -> Bool{
        return true
    }
    open func executeNavigationPopGestureRecognizer() -> Bool{
        return true
    }
    open func changeNavigationBarColor(barTintColor:UIColor,titleTextColor:UIColor){
        navigationController?.navigationBar.barTintColor = barTintColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleTextColor]
        navigationController?.navigationBar.tintColor = titleTextColor // 如果设置了背景图片,则渲染颜色无效(注意appearance方式设置)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        if utilShared.color.contrastColor(barTintColor) == .white{
            UIApplication.shared.statusBarStyle = .lightContent
        }else{
            UIApplication.shared.statusBarStyle = .default
        }
    }
    // Lefttime Method:
    //  initWithCoder: or initWithNibName:bundle: where you perform instance initializations
    //  viewDidLoad: where you perform view-related initializations
    //  viewDidAppear: if you’re going to register for a notification or set up a timer, this is a likely place to do it.
    //  viewDidDisappear: this would be a likely place to unregister for a notification or invalidate a repeating timer that you set up in viewDidAppear:
    //  supportedInterfaceOrientations: where you specify what device orientations are allowed for this view controller’s main view.
    //  deinit: where you perform end-of-life cleanup
    
    func popoverViewController(contentCV:UIViewController){
        //contentCV.modalPresentationStyle = UIModalPresentationStyle.popover //呈现样式
        //let popPC = contentCV.popoverPresentationController // 呈现控制器
        //contentCV.popoverPresentationController?.sourceRect = button.frame // 出现源位置
        //contentCV.popoverPresentationController?.sourceView = view // 出现源View
        //popPC?.permittedArrowDirections = UIPopoverArrowDirection.any // 可以出现的方向
        //popPC?.delegate = self // 控制器委托
        //present(contentCV, animated: true, completion: nil)
        /* Delegate 重写
         func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
            return UIModalPresentationStyle.popover // 20
         }
         
         private func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
            let navController = UINavigationController.init(rootViewController: controller.presentedViewController)
            return navController // 21
         }
         */
    }
}
