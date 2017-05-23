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
    let userDefault:UserDefaults = UserDefaults.standard
    /// 是否已经登录
    func isLogin() -> Bool{
        return userDefault.bool(forKey: KEY_PERSON_IS_LOGIN)
    }
    
    func setIsLogin(_ isLogin:Bool){
        userDefault.set(isLogin, forKey: KEY_PERSON_IS_LOGIN)
    }
    func getLastLoginPhone() -> String?{
        return userDefault.string(forKey: KEY_PHONE_LOGIN)
    }
    func setLastLoginPhone(_ phone:String){
        userDefault.set(phone, forKey: KEY_PHONE_LOGIN)
    }
    /// 首次打开APP
    func isFirstOpenApp() -> Bool{
        let result = userDefault.bool(forKey: KEY_FIRST_OPEN_APP)
        if result == false {
            userDefault.set(true, forKey: KEY_FIRST_OPEN_APP)
        }
        return !result
    }
    /// 首次打开本版本APP
    func isFirstOpenAppVersion() -> Bool{
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let key = "\(KEY_FIRST_OPEN_APP_VERSION)_\(version==nil ? "1.0" : version!)"
        let result = userDefault.bool(forKey: key)
        if result == false {
            userDefault.set(true, forKey: key)
        }
        return !result
    }
    /// 消息提醒
    func setMessageNotification(_ notificat: Bool){
        userDefault.set(notificat, forKey: KEY_MESSAGE_NOTIFICATION)
    }
    func isMessageNotification() -> Bool{
        return userDefault.bool(forKey: KEY_MESSAGE_NOTIFICATION)
    }
}
