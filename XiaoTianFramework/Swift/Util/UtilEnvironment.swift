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

@objc(UtilEnvironmentXT)
open class UtilEnvironment : NSObject{
    /// App Version
    public class var appVersion:String{
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    /// App Build Version
    public class var appBuildVersion:String!{
        return Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as! String
    }
    /// System Version eg: 7.0,8.0,9.0
    public class var systemVersion:String{
        return UIDevice.current.systemVersion
    }
    /// 拷贝到粘贴板
    public class func copyToPasteboard(_ text:String){
        UIPasteboard.general.string = text
    }
    /// 从粘贴板复制
    public class func pasteFromPasteboard()->String?{
        return UIPasteboard.general.string
    }
    /// 打开AppStore 中的 App
    public class func openAppStore(_ bundleName: String!){
        if bundleName == nil{
            let bundleInfo = Bundle.main.infoDictionary
            var bundleName = bundleInfo!["CFBundleName"] as! String
            bundleName = bundleName.replacingOccurrences(of: " ", with: "")
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.com/app/\(bundleName)")!)
        } else {
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.com/app/\(bundleName)")!)
        }
    }
    /// 打开AppStore 中的 App,根据APP上线分发的APPID[Appirater:自动评价APP弹框]
    public class func openAppStoreByAppID(_ appID: String){
        var appStoreURL:String!
        let systemVersion: Float! = Float(UtilEnvironment.systemVersion)
        if systemVersion > 8.0{
            // iOS 8.0+
            appStoreURL = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software&id=\(appID)"
        }else if systemVersion > 7.0{
            // iOS 7.0 ~ iOS 8.0
            appStoreURL = "itms-apps://itunes.apple.com/app/id\(appID)"
        }else{
            // iOS 7.0-
            appStoreURL = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appID)"
        }
        UIApplication.shared.openURL(URL(string: appStoreURL)!)
    }
    /// 打开App设置
    public class func openSettingNetwork(){
        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            let result = UIApplication.shared.openURL(settingsUrl)
            Mylog.log("Setting open: \(result)")
        }
    }
    /// Class Method
    /// 系统版本大于
    public class func systemVersionAfter(_ version:Double) -> Bool{
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
    public class var isSimulator:Bool{
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
        //return TARGET_IPHONE_SIMULATOR != 0 // Use this line in Xcode 6
    }
    /// 是否是 Iphone
    public class var isIphone:Bool{
        return TARGET_OS_IPHONE != 0
    }
    /// 是否已经联网
    public class var isConnectedToNetwork: Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
            //SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }) else {
            return false
        }
        
        var flags : SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    /// 设备唯一 ID :UUID
    public class var driverUUID: String?{
        get{
            return UIDevice.current.identifierForVendor?.uuidString
        }
    }
    /// 屏幕横竖屏方向
    public class var screamOrientation:UIInterfaceOrientation{
        return UIApplication.shared.statusBarOrientation
    }
    public class var isScreen55Inch: Bool{
        return false
    }
    public class var isScreen47Inch: Bool{
        return false
    }
    public class var isScreen40Inch: Bool{
        return false
    }
    public class var isScreen35Inch: Bool{
        return false
    }
    public static var screenSizeFor55Inch = CGSize(width: 414, height: 736)
    public static var screenSizeFor47Inch = CGSize(width: 375, height: 667)
    public static var screenSizeFor40Inch = CGSize(width: 320, height: 568)
    public static var screenSizeFor35Inch = CGSize(width: 320, height: 480)
    /// 是否横屏
    public class var isLandscape: Bool{
        return UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)
    }
    /// 设备是否横屏(与app无关)
    public class var isDriverLandscape: Bool{
        return UIDeviceOrientationIsLandscape(UIDevice.current.orientation)
    }
    /// 当前屏幕宽(横竖屏会变)
    public class var screenWidth: CGFloat{
        let size = UIScreen.main.bounds.size
        return isAfteriOS8 ? size.width : isLandscape ? size.height : size.width
    }
    /// 当前屏幕高(横竖屏会变)
    public class var screenHeight: CGFloat{
        let size = UIScreen.main.bounds.size
        return isAfteriOS8 ? size.height : isLandscape ? size.width : size.height
    }
    /// 设备屏幕宽(横竖屏不变)
    public class var deviceWidth: CGFloat{
        let size = UIScreen.main.bounds.size
        return isAfteriOS8 ? isLandscape ? size.height : size.width : size.width
    }    /// 设备屏幕高度
    public class var deviceHeight: CGFloat{
        let size = UIScreen.main.bounds.size
        return isAfteriOS8 ? isLandscape ? size.width: size.height : size.height
    }
    /// 设备iOS版本号
    public class var iosVersion: String{
        return UIDevice.current.systemVersion
    }
    /// iOS8+
    public class var isAfteriOS8: Bool{
        return Float(UIDevice.current.systemVersion)! >= 8.0
    }
    /// Available iOS 10
    public class var availableiOS10: Bool{
        guard #available(iOS 10.0, *) else {
            return false
        }
        return true
    }
    /// 加载Nib
    public class func loadNibNamed(_ name:String,_ owner: Any?,_ option: [AnyHashable : Any]?) -> [Any]?{
        // UINib(nibName: name, bundle: Bundle.main)
        return Bundle.main.loadNibNamed(name, owner: owner, options: option)
    }
    /// 获取可视键盘的高度
    func visibleKeyboardHeight() -> CGFloat{
        var keyboardWindow: UIWindow? = nil
        // 当前所有窗口,获取可能是键盘的Window
        for window in UIApplication.shared.windows{
            // 不是UIWindow的类[可能是子类]
            if !UIWindow.self.isEqual(type(of: window)) {
                keyboardWindow = window
                break
            }
        }
        if let keyboardWindow = keyboardWindow {
            for possibleKeyboard in keyboardWindow.subviews{
                // 非公开类键盘类
                let classUIPeripheralHostView:AnyClass! = NSClassFromString("UIPeripheralHostView")
                let classUIKeyboard:AnyClass! = NSClassFromString("UIKeyboard")
                if classUIPeripheralHostView != nil && possibleKeyboard.isKind(of: classUIPeripheralHostView){
                    return possibleKeyboard.bounds.height
                }
                if classUIKeyboard != nil && possibleKeyboard.isKind(of: classUIKeyboard){
                    return possibleKeyboard.bounds.height
                }
                //
                let classUIInputSetContainerView:AnyClass! = NSClassFromString("UIInputSetContainerView")
                if classUIInputSetContainerView != nil && possibleKeyboard.isKind(of: classUIInputSetContainerView){
                    guard let classUIInputSetHostView:AnyClass = NSClassFromString("UIInputSetHostView") else{
                        break
                    }
                    for possibleKeyboardSubview in possibleKeyboard.subviews{
                        if possibleKeyboardSubview.isKind(of: classUIInputSetHostView) {
                            return possibleKeyboardSubview.bounds.height
                        }
                    }
                }
            }
        }
        return 0
    }
}
