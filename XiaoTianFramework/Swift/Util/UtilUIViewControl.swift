//
//  UtilUIViewControl.swift
//  XiaoTianFramework
//
//  Created by 郭天蕊 on 2017/11/30.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//


import UIKit
import Foundation

open class UtilUIViewControl{
    open func changeNavigationBarColor(viewController:UIViewController,barTintColor:UIColor,titleTextColor:UIColor){
        viewController.navigationController?.navigationBar.barTintColor = barTintColor
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: titleTextColor]
        viewController.navigationController?.navigationBar.tintColor = titleTextColor // 如果设置了背景图片,则渲染颜色无效(注意appearance方式设置)
        viewController.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        let shadowImage = viewController.utilShared.image.genImageFromColor(UIColor.lightGray, CGSize(width: 1, height: 1))// 底部阴影线
        viewController.navigationController?.navigationBar.shadowImage = shadowImage
        if viewController.utilShared.color.contrastColor(barTintColor) == .white{
            UIApplication.shared.statusBarStyle = .lightContent
        }else{
            UIApplication.shared.statusBarStyle = .default
        }
    }
    open func changeStatusBarContentColor(contentColor:UIColor){
        if let statusBarWindow = UIApplication.shared.value(forKey: "statusBarWindow") as AnyObject?{
            if let statusBar = statusBarWindow.value(forKey: "statusBar") as AnyObject?{
                let setForegroundColorSEL = NSSelectorFromString("setForegroundColor:")
                if statusBar.responds(to: setForegroundColorSEL){
                    // IOS7+ Support Method
                    let _ = statusBar.perform(setForegroundColorSEL, with: contentColor)
                }
            }
        }
    }
    open func presendAnimateFromRight(viewController:UIViewController,nextViewController:UIViewController){
        let transition = CATransition()
        transition.duration = 0.25
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromRight
        viewController.view.window!.layer.add(transition, forKey: kCATransition)
        viewController.present(nextViewController, animated: false, completion: nil)
    }
    open func dismissAnimateFromLeft(viewController:UIViewController){
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        viewController.view.window!.layer.add(transition, forKey: kCATransition)
        viewController.dismiss(animated: false, completion: nil)
    }
}
