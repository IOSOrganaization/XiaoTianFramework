//
//  UtilNotification.swift
//  DriftBook
//  系统通知
//  Created by 郭天蕊 on 2016/12/27.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
class UtilNotification: NSObject{
    let DEFAULT_USER_INFO_KEY = "UtilNotificationDefaultUserInfoKey"
    let DEFAULT_USER_INFO_VALUE = "UtilNotificationDefaultUserInfoValue"
    
    /// 发送本地系统通知
    func sendLocalNotification(text:String,_ userInfo:[String:AnyObject]?){
        if UtilEnvironment.systemVersionAfter(10.0){
            // IOS 10+
            //if (NSClassFromString(@"UNUserNotificationCenter")) {
                //                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
                //                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                //                content.sound = [UNNotificationSound defaultSound];
                //                content.body =[NSString stringWithFormat:NSLocalizedString(@"friend.somebodyAddWithName", @"%@ add you as a friend"), aUsername];
                //                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate] * 1000] stringValue] content:content trigger:trigger];
                //                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
            //}
        }else{
            let notification = UILocalNotification()
            notification.fireDate = NSDate()
            notification.timeZone = NSTimeZone.defaultTimeZone()
            //
            notification.alertBody = text
            //notification.alertAction = "open"
            //notification.repeatInterval = NSWeekCalendarUnit
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.applicationIconBadgeNumber = 1
            notification.userInfo = userInfo
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
    }
    /// 发送本地默认系统通知
    func sendDefaultLocalNotification(text:String){
        sendLocalNotification(text,[DEFAULT_USER_INFO_KEY:DEFAULT_USER_INFO_VALUE])
    }
    /// 取消本地默认系统通知
    func cancelDefaultLocalNotification(){
        if let localNotification = UIApplication.sharedApplication().scheduledLocalNotifications{
            for notification in localNotification{
                if let userInfo = notification.userInfo{
                    if let defaultValue = userInfo[DEFAULT_USER_INFO_KEY] as? String{
                        if defaultValue == DEFAULT_USER_INFO_VALUE{
                            // 取消本地通知
                            UIApplication.sharedApplication().cancelLocalNotification(notification)
                            break
                        }
                    }
                }
            }
        }
    }
    /// 设置Icon图标的Badge标识数字[当badgeNumber = 0 时隐藏 Badge]
    func setIconBadge(badgeNumber: Int){
        let application = UIApplication.sharedApplication()
        let badge = application.applicationIconBadgeNumber
        if badgeNumber == badge{
            return
        }
        application.applicationIconBadgeNumber = badgeNumber
    }
    /// 
}