//
//  UtilNSNotificationDefaultCenter.swift
//  DriftBook
//  NSNotificationDefaultCenter Util
//  Created by XiaoTian on 2016/11/26.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

open class UtilNSNotificationDefaultCenter: NSObject{
    
    /// Post Notification
    func postNotificationName(_ notificationName:String,_ userInfo:[AnyHashable: Any]? = nil){
        NotificationCenter.default.post(name: Notification.Name(rawValue: notificationName), object: nil, userInfo: userInfo)
    }
    /// 注册通知侦听器/观察者
    func addObserver(_ observer:AnyObject,_ selector:Selector,_ name:String){
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
    }
    /// 移除通知侦听器/观察者
    func removeAllObserve(_ observer:AnyObject){
        NotificationCenter.default.removeObserver(observer)
    }
    /// 注册侦听器
    func addObserver(_ observer: NSObject) {
        // 默认获取指定回调的 function
        if observer.responds(to: Selector("addObserver")){
            
        }
    }
    /// 发送通知/推播通知
    //func postNotification(observer: NSObject){
    
    //}
    
    /// 添加键盘弹出侦听器
    func addObserverKeyboardWillShow(_ observer: NSObject,_ selector:Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    /// 添加键盘收起侦听器
    func addObserverKeyboardDidHide(_ observer: NSObject,_ selector:Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    /// 移除键盘弹出侦听器
    func removeObserverKeyboardWillShow(_ observer: NSObject){
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    /// 移除键盘收起侦听器
    func removeObserverKeyboardDidHide(_ observer: NSObject){
        NotificationCenter.default.removeObserver(observer, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }

}
