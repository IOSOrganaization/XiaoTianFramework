//
//  UtilKVC.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/6/28.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
open class UtilKVC: NSObject{
    // KVC: Key Value Coding
    // 1.注册变量侦听器
    // 1.重写变量侦听方法
    // 2.自动(变量值改变),手动发送变量值改变通知
    /// 添加属性侦听器 KVC [NSKeyValueObserving,the property is dynamic. @objc dynamic var ]
    public class func addPropertyObserve(_ target: NSObject,_ observer: NSObject,_ targetPropetyNamePath:String){
        // .new 新值 .old 旧值 .initial 初始化 .prior初始化前值
        // context:地址引用[UnsafeMutableRawPointer?]
        // private var con = "ObserveValue" 取地址:&con,由地址取取值:let c = UnsafeMutablePointer<String>(context) let s = c.memory // "ObserveValue"]
        target.addObserver(observer, forKeyPath: targetPropetyNamePath, options: [.new,.old,.initial,.prior], context: nil)
        // 属性改变接收器,target必须要重写这个方法接收改变
        // override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    }
    /// 移除属性侦听器 KVC[ KeyPath:属性 KeyValue:属性值,必须在deinit中移除]
    public class func removePropertyObserver(_ target: NSObject,_ observer: NSObject,_ targetPropetyNamePath:String){
        target.removeObserver(observer, forKeyPath: targetPropetyNamePath)
        //target.removeObserver(observer, forKeyPath: targetPropetyName, context: nil)
    }
    // Accessors, Properties, and Key–Value Coding
    public class func setPropertyValue(_ target:AnyObject?,_ value: Any?, forKey key: String) {
        // 设置value到属性key在target上
        target?.setValue(value, forKey: key) // target必须要有key的属性,并且类型必须一致,不然崩溃
        //1. If you send valueForKey: to an NSArray, it sends valueForKey: to each of its elements and returns a new array consisting of the results, an elegant shorthand. NSSet behaves similarly.
        //2. NSDictionary implements valueForKey: as an alternative to objectForKey: (useful particularly if you have an NSArray of dictionaries). Similarly, NSMutableDictionary treats setValue:forKey: as a synonym for setObject:forKey:, except that value: can be nil, in which case removeObject:forKey: is called.
        //3. NSSortDescriptor sorts an NSArray by sending valueForKey: to each of its elements. This makes it easy to sort an array of dictionaries on the value of a particular dictionary key, or an array of objects on the value of a particular property.
        //4. NSManagedObject, used in conjunction with Core Data, is guaranteed to be key–value coding compliant for attributes you’ve configured in the entity model. Thus, it’s common to access those attributes with valueForKey: and setValue:forKey:.
        //5. CALayer and CAAnimation permit you to use key–value coding to define and retrieve the values for arbitrary keys, as if they were a kind of dictionary; they are, in effect, key–value coding compliant for every key. This is extremely helpful for attaching identifying and configuration information to an instance of one of these classes. That, in fact, is my own most common way of using key–value coding in Swift.
        //6. KVC and Outlets
        //7. Key Paths [object.property, Dictionary,Array的读取]
        //8. NSObject:
        //  Creation, destruction, and memory management
        //  Class relationships[such as superclass, isKindOfClass:, and isMemberOfClass:]
        //  Object introspection and comparison[such as respondsToSelector:]
        //  Message response[such as doesNotRecognizeSelector:]
        //  Message sending[For example, performSelector:, performSelector:withObject:afterDelay:]
    }
    /// 手动发送变量通知
    public class func sendPropertyChangeNotification(_ target:AnyObject?,forKey:String){
        target?.willChangeValue(forKey: forKey)// Will Change Notification
        target?.didChangeValue(forKey: forKey)// Did Change Notification
    }

}
