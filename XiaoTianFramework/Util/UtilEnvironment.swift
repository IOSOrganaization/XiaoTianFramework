//
//  UtilEnvironment.swift
//  DriftBook
//  App 环境工具
//  Created by 郭天蕊 on 2016/10/26.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//
import UIKit
import Foundation
import SystemConfiguration

@objc(UtilEnvironment)
class UtilEnvironment : NSObject{
    /// App Version
    class var appVersion:String{
        return NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as! String
    }
    /// App Build Version
    class var appBuildVersion:String!{
        return NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey as String] as! String
    }
    /// System Version eg: 7.0,8.0,9.0
    class var systemVersion:String{
        return UIDevice.currentDevice().systemVersion
    }
    /// 拷贝到粘贴板
    class func copyToPasteboard(text:String){
        UIPasteboard.generalPasteboard().string = text
    }
    /// 从粘贴板复制
    class func pasteFromPasteboard()->String?{
        return UIPasteboard.generalPasteboard().string
    }
    /// 打开AppStore 中的 App
   class func openAppStore(bundleName: String!){
        if bundleName == nil{
            let bundleInfo = NSBundle.mainBundle().infoDictionary
            var bundleName = bundleInfo!["CFBundleName"] as! String
            bundleName = bundleName.stringByReplacingOccurrencesOfString(" ", withString: "")
            UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.com/app/\(bundleName)")!)
        } else {
            UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.com/app/\(bundleName)")!)
        }
    }
    /// 打开App设置
    class func openSettingNetwork(){
        guard let settingsUrl = NSURL(string: UIApplicationOpenSettingsURLString) else {
                return
        }
        if UIApplication.sharedApplication().canOpenURL(settingsUrl) {
            let result = UIApplication.sharedApplication().openURL(settingsUrl)
            Mylog.log("Setting open: \(result)")
        }
    }
    /// Class Method
    /// 系统版本大于
    class func systemVersionAfter(version:Double) -> Bool{
        let currentVersion:Double! = Double(UtilEnvironment.systemVersion)
        return currentVersion - version > 0.0
    }
    /// 打开系统邮件
//    class func openEmail(viewController:UIViewController,_ delegate:MFMailComposeViewControllerDelegate?){
//        let mailComposerVC = MFMailComposeViewController()
//        mailComposerVC.mailComposeDelegate = delegate
//        mailComposerVC.setToRecipients(["nurdin@gmail.com"])
//        mailComposerVC.setSubject("Sending you an in-app e-mail...")
//        mailComposerVC.setMessageBody("Sending e-mail in-app is not so bad!", isHTML: false)
//        
//        if MFMailComposeViewController.canSendMail() {
//            viewController.presentViewController(mailComposerVC, animated: true, completion: nil)
//        }else{
//            Mylog.log("打开系统邮件失败, 系统不支持发送.")
//        }
//    }
    /// 是否是模拟器
    class var isSimulator:Bool{
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
        //return TARGET_IPHONE_SIMULATOR != 0 // Use this line in Xcode 6
    }
    /// 是否是 Iphone
    class var isIphone:Bool{
        return TARGET_OS_IPHONE != 0
    }
    /// 是否已经联网
    class var isConnectedToNetwork: Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.Reachable)
        let needsConnection = flags.contains(.ConnectionRequired)
        
        return (isReachable && !needsConnection)
    }
    /// 设备唯一 ID :UUID
    class var driverUUID: String?{
        get{
            return UIDevice.currentDevice().identifierForVendor?.UUIDString
        }
    }
}