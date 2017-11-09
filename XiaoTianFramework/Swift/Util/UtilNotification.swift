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
                    if error == nil{
                        Mylog.log("发送通知成功.")
                    }else{
                        Mylog.log(error)
                    }
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
    open func sendLocalNotification(_ hour: String, before: Int, line: String, direction: String){
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
                if granted {
                    let content = UNMutableNotificationContent()
                    if before == 0 {
                        content.title = "立即通知"
                        content.body = "行提示文本 " + line + " 描述文本 " + direction + " 立即自动消失"
                    } else {
                        content.title = "过 " + String(before) + " 分钟后自动消失"
                        var text =  "行提示文本 "
                        text += line
                        text += " 描述文本 "
                        text += direction
                        text += " 将在 "
                        text += String(before)
                        text += " 分钟后消失"
                        content.body = text
                    }
                    content.categoryIdentifier = "departureNotifications" // id
                    content.setValue(true, forKey: "shouldAlwaysAlertWhileAppIsForeground") // app在前台是也通知
                    content.userInfo = [:]
                    content.sound = UNNotificationSound.default()
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
                    var time = dateFormatter.date(from: hour)
                    time!.addTimeInterval(Double(before) * -60.0)
                    let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time!)
                    
                    let cal = Calendar(identifier: Calendar.Identifier.gregorian)
                    let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: Date())
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date!), repeats: false)
                    
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    center.add(request, withCompletionHandler: { (error) in
                        DispatchQueue.main.sync {
                            if error == nil {
                                // 发送通知成功
                                /*let okView = SCLAlertView()
                                if before == 0 {
                                    okView.showSuccess(
                                        "Vous serez notifié".localized,
                                        subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.".localized,
                                        closeButtonTitle: "OK",
                                        duration: 10)
                                } else {
                                    var texte =  "La notification à été enregistrée et sera affichée ".localized
                                    texte += String(before)
                                    texte += " minutes avant le départ.".localized
                                    okView.showSuccess(
                                        "Vous serez notifié".localized,
                                        subTitle: texte,
                                        closeButtonTitle: "OK",
                                        duration: 10)
                                }*/
                            } else {
                                DispatchQueue.main.sync {
                                    // 发送通知失败
                                    /*let alertView = SCLAlertView()
                                    alertView.showError(
                                        "Impossible d'enregistrer la notification",
                                        subTitle: "L'erreur a été reportée au développeur. Merci de réessayer.",
                                        closeButtonTitle: "OK", duration: 30)*/
                                }
                            }
                        }
                    })
                } else {
                    DispatchQueue.main.sync {
                        // 创建通知失败
                        /*let alertView = SCLAlertView()
                        alertView.showError(
                            "Notifications désactivées",
                            subTitle: "Merci d'activer les notifications dans les réglages",
                            closeButtonTitle: "OK",
                            duration: 30)*/
                    }
                    
                }
            }
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssz"
            var time = dateFormatter.date(from: hour)
            time!.addTimeInterval(Double(before) * -60.0)
            let now: DateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: time!)
            
            let cal = Calendar(identifier: Calendar.Identifier.gregorian)
            let date = cal.date(bySettingHour: now.hour!, minute: now.minute!, second: now.second!, of: Date())
            let reminder = UILocalNotification()
            reminder.fireDate = date
            reminder.soundName = UILocalNotificationDefaultSoundName
            if before == 0 {
                reminder.alertBody = "\("Le tpg de la ligne ".localized)\(line)\(" en direction de ".localized)\(direction)\(" va partir immédiatement".localized)"
            } else {
                var texte =  "行提示文本 "
                texte += line
                texte += " 直接发送通知 "
                texte += direction
                texte += "  描述文本  "
                texte += String(before)
                texte += " 自动销毁"
                reminder.alertBody = texte
            }
            
            UIApplication.shared.scheduleLocalNotification(reminder)
            
            print("Firing at \(String(describing: now.hour)):\(now.minute!-before):\(String(describing: now.second))")
            
            /*let okView = SCLAlertView()
            if before == 0 {
                okView.showSuccess(
                    "Vous serez notifié".localized,
                    subTitle: "La notification à été enregistrée et sera affichée à l'heure du départ.".localized,
                    closeButtonTitle: "OK", duration: 10)
            } else {
                var texte =  "La notification à été enregistrée et sera affichée ".localized
                texte += String(before)
                texte += " minutes avant le départ.".localized
                okView.showSuccess("Vous serez notifié".localized, subTitle: texte, closeButtonTitle: "OK", duration: 10)
            }*/
        }
    }
    /// 发送本地默认系统通知
    open func sendDefaultLocalNotification(_ text:String){
        sendLocalNotification(text, [DEFAULT_USER_INFO_KEY:DEFAULT_USER_INFO_VALUE as AnyObject])
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
