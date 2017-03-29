//
//  UtilPreference.swift
//  DriftBook
//  NSUserDefaults的preference管理
//  Created by XiaoTian on 16/7/3.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

class UtilPreference : NSObject {
    let KEY_PERSON_LOGIN = "UtilPreference.KEY_PERSON_LOGIN"
    let KEY_PHONE_LOGIN = "UtilPreference.KEY_PHONE_LOGIN"
    let KEY_PERSON_IS_LOGIN = "UtilPreference.KEY_PERSON_IS_LOGIN"
    let KEY_FIRST_OPEN_APP = "UtilPreference.KEY_FIRST_OPEN_APP"
    let KEY_FIRST_OPEN_APP_VERSION = "UtilPreference.KEY_FIRST_OPEN_APP_VERSION"
    let KEY_MESSAGE_NOTIFICATION = "UtilPreference.KEY_MESSAGE_NOTIFICATION"
    //
    let userDefault:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    /// 是否已经登录
    func isLogin() -> Bool{
        return userDefault.boolForKey(KEY_PERSON_IS_LOGIN)
    }
    
    func setIsLogin(isLogin:Bool){
        userDefault.setBool(isLogin, forKey: KEY_PERSON_IS_LOGIN)
    }
    func getLastLoginPhone() -> String?{
        return userDefault.stringForKey(KEY_PHONE_LOGIN)
    }
    func setLastLoginPhone(phone:String){
        userDefault.setObject(phone, forKey: KEY_PHONE_LOGIN)
    }
    /// 首次打开APP
    func isFirstOpenApp() -> Bool{
        let result = userDefault.boolForKey(KEY_FIRST_OPEN_APP)
        if result == false {
            userDefault.setBool(true, forKey: KEY_FIRST_OPEN_APP)
        }
        return !result
    }
    /// 首次打开本版本APP
    func isFirstOpenAppVersion() -> Bool{
        let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String
        let key = "\(KEY_FIRST_OPEN_APP_VERSION)_\(version==nil ? "1.0" : version!)"
        let result = userDefault.boolForKey(key)
        if result == false {
            userDefault.setBool(true, forKey: key)
        }
        return !result
    }
    /// 消息提醒
    func setMessageNotification(notificat: Bool){
        userDefault.setBool(notificat, forKey: KEY_MESSAGE_NOTIFICATION)
    }
    func isMessageNotification() -> Bool{
        return userDefault.boolForKey(KEY_MESSAGE_NOTIFICATION)
    }
}
