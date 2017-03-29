//
//  UtilNSNotificationDefaultCenter.swift
//  DriftBook
//  NSNotificationDefaultCenter Util
//  Created by XiaoTian on 2016/11/26.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

class UtilNSNotificationDefaultCenter: NSObject{
    
    /// Post Notification
    func postNotificationName(notificationName:String,_ userInfo:[NSObject: AnyObject]? = nil){
        NSNotificationCenter.defaultCenter().postNotificationName(notificationName, object: nil, userInfo: userInfo)
    }
    /// 注册通知侦听器/观察者
    func addObserver(observer:AnyObject,_ selector:Selector,_ name:String){
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: name, object: nil)
    }
    /// 移除通知侦听器/观察者
    func removeAllObserve(observer:AnyObject){
        NSNotificationCenter.defaultCenter().removeObserver(observer)
    }
    /// 注册侦听器
    func addObserver(observer: NSObject) {
        // 默认获取指定回调的 function
        if observer.respondsToSelector(Selector("addObserver")){
            
        }
    }
    /// 发送通知/推播通知
    //func postNotification(observer: NSObject){
    
    //}
    
    /// 添加键盘弹出侦听器
    func addObserverKeyboardWillShow(observer: NSObject,_ selector:Selector) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: UIKeyboardWillShowNotification, object: nil)
    }
    /// 添加键盘收起侦听器
    func addObserverKeyboardDidHide(observer: NSObject,_ selector:Selector) {
        NSNotificationCenter.defaultCenter().addObserver(observer, selector: selector, name: UIKeyboardDidHideNotification, object: nil)
    }
    /// 移除键盘弹出侦听器
    func removeObserverKeyboardWillShow(observer: NSObject){
        NSNotificationCenter.defaultCenter().removeObserver(observer, name: UIKeyboardWillShowNotification, object: nil)
    }
    /// 移除键盘收起侦听器
    func removeObserverKeyboardDidHide(observer: NSObject){
        NSNotificationCenter.defaultCenter().removeObserver(observer, name: UIKeyboardDidHideNotification, object: nil)
    }

}