//
//  UtilNotification.swift
//  DriftBook
//  系统通知
//  Created by 郭天蕊 on 2016/12/27.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
import UserNotifications

open class UtilNotification: NSObject{
    let DEFAULT_USER_INFO_KEY = "UtilNotificationDefaultUserInfoKey"
    let DEFAULT_USER_INFO_VALUE = "UtilNotificationDefaultUserInfoValue"
    
    /// 发送本地系统通知
    open func sendLocalNotification(_ text:String,_ userInfo:[String:AnyObject]?){
        if UtilEnvironment.systemVersionAfter(10.0){
            // IOS 10+
            if #available(iOS 10.0, *) {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
                let content = UNMutableNotificationContent()
                content.sound = UNNotificationSound.default()
                content.body = text
                let request = UNNotificationRequest(identifier: "xiaotian_1", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                    Mylog.log("发送通知成功.")
                })
                return
            } else {
                // Fallback on earlier versions
            }
        }
        let notification = UILocalNotification()
        notification.fireDate = Date()
        notification.timeZone = TimeZone.current
        notification.alertBody = text
        //notification.alertAction = "open"
        //notification.repeatInterval = NSWeekCalendarUnit
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = 1
        notification.userInfo = userInfo
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    /// 发送本地默认系统通知
    open func sendDefaultLocalNotification(_ text:String){
        sendLocalNotification(text,[DEFAULT_USER_INFO_KEY:DEFAULT_USER_INFO_VALUE as AnyObject])
    }
    /// 取消本地默认系统通知
    open func cancelDefaultLocalNotification(){
        if let localNotification = UIApplication.shared.scheduledLocalNotifications{
            for notification in localNotification{
                if let userInfo = notification.userInfo{
                    if let defaultValue = userInfo[DEFAULT_USER_INFO_KEY] as? String{
                        if defaultValue == DEFAULT_USER_INFO_VALUE{
                            // 取消本地通知
                            UIApplication.shared.cancelLocalNotification(notification)
                            break
                        }
                    }
                }
            }
        }
    }
    /// 设置Icon图标的Badge标识数字[当badgeNumber = 0 时隐藏 Badge]
    open func setIconBadge(_ badgeNumber: Int){
        let application = UIApplication.shared
        let badge = application.applicationIconBadgeNumber
        if badgeNumber == badge{
            return
        }
        application.applicationIconBadgeNumber = badgeNumber
    }
    /// 
}
