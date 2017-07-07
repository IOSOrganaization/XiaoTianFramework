//
//  UtilPreference.swift
//  DriftBook
//  NSUserDefaults的preference管理
//  Created by XiaoTian on 16/7/3.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

open class UtilPreference : NSObject {
    // Property Key Lists
    let KEY_PERSON_LOGIN = "UtilPreference.KEY_PERSON_LOGIN"
    let KEY_PHONE_LOGIN = "UtilPreference.KEY_PHONE_LOGIN"
    let KEY_PERSON_IS_LOGIN = "UtilPreference.KEY_PERSON_IS_LOGIN"
    let KEY_FIRST_OPEN_APP = "UtilPreference.KEY_FIRST_OPEN_APP"
    let KEY_FIRST_OPEN_APP_VERSION = "UtilPreference.KEY_FIRST_OPEN_APP_VERSION"
    let KEY_MESSAGE_NOTIFICATION = "UtilPreference.KEY_MESSAGE_NOTIFICATION"
    //
    let userDefault:UserDefaults = UserDefaults.standard
    /// 是否已经登录
    public func isLogin() -> Bool{
        return userDefault.bool(forKey: KEY_PERSON_IS_LOGIN)
    }
    
    public func setIsLogin(_ isLogin:Bool){
        userDefault.set(isLogin, forKey: KEY_PERSON_IS_LOGIN)
    }
    public func getLastLoginPhone() -> String?{
        return userDefault.string(forKey: KEY_PHONE_LOGIN)
    }
    public func setLastLoginPhone(_ phone:String){
        userDefault.set(phone, forKey: KEY_PHONE_LOGIN)
    }
    /// 首次打开APP
    public func isFirstOpenApp() -> Bool{
        let result = userDefault.bool(forKey: KEY_FIRST_OPEN_APP)
        if result == false {
            userDefault.set(true, forKey: KEY_FIRST_OPEN_APP)
        }
        return !result
    }
    /// 首次打开本版本APP
    public func isFirstOpenAppVersion() -> Bool{
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let key = "\(KEY_FIRST_OPEN_APP_VERSION)_\(version==nil ? "1.0" : version!)"
        let result = userDefault.bool(forKey: key)
        if result == false {
            userDefault.set(true, forKey: key)
        }
        return !result
    }
    /// 消息提醒
    public func setMessageNotification(_ notificat: Bool){
        userDefault.set(notificat, forKey: KEY_MESSAGE_NOTIFICATION)
    }
    public func isMessageNotification() -> Bool{
        return userDefault.bool(forKey: KEY_MESSAGE_NOTIFICATION)
    }
    /// 保存C Struct的UIColor
    public func setColor(_ key: String,_ color: UIColor){
        // Key 归档
        let cData = NSKeyedArchiver.archivedData(withRootObject: color) // C Struct 转 NSData
        //NSKeyedUnarchiver.unarchiveObject(with: cData) 解档
        userDefault.set(cData, forKey: key)
    }
    /// 保存对象,必须实现 NSCoding 接口协议[调用encodeWithCoder方法]
    public func setAny<T: NSObject>(_ key: String, _ any: T?){
        if any == nil{
            userDefault.set(nil, forKey: key)
            return
        }
        let archivedData = NSKeyedArchiver.archivedData(withRootObject: any!)
        userDefault.set(archivedData, forKey: key)
    }
    /// 获取对象,必须实现 NSCoding 接口协议[调用initWithCoder方法]
    public func getAny<T: NSObject>(_ key: String,_ clazz: T.Type) -> T?{
        if let unArchiveData = userDefault.data(forKey: key){
            return NSKeyedUnarchiver.unarchiveObject(with: unArchiveData) as? T
        }else{
            return nil
        }
    }
    /// Property Lists
    public func stringArrayForKey(_ key:String) -> [String]?{
        if let stringData = userDefault.data(forKey: key){
            return NSKeyedUnarchiver.unarchiveObject(with: stringData) as? [String]
        }
        return nil
    }
    /// Set Property Lists
    public func setStringArray(_ string:[String]?,_ key:String){
        var stringData: Data?
        if let string = string{
            stringData = NSKeyedArchiver.archivedData(withRootObject: string)
        }
        userDefault.set(stringData, forKey: key)
    }
    /// Property Dictionary
    public func stringDictionnaryForKey(_ key:String) -> [String: String]?{
        if let stringData = userDefault.data(forKey: key){
            return NSKeyedUnarchiver.unarchiveObject(with: stringData) as? [String: String]
        }
        return nil
    }
    /// 全局可见参数
    //1.静态类常量
    //2.用户共享参数
    //3.Notification & KVO
}
