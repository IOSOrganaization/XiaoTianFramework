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
    public func setColor(_ color: UIColor,_ key: String){
        // Key 归档
        let cData = NSKeyedArchiver.archivedData(withRootObject: color) // C Struct 转 NSData
        //NSKeyedUnarchiver.unarchiveObject(with: cData) 解档
        userDefault.set(cData, forKey: key)
    }
    /// Property Lists
    
    /// 全局可见参数
    //1.静态类常量
    //2.用户共享参数
    //3.Notification & KVO
}
