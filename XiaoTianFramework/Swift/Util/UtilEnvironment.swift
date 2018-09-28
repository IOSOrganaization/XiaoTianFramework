//
//  UtilEnvironment.swift
//  DriftBook
//  App 环境工具
//  Created by 郭天蕊 on 2016/10/26.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//
import UIKit
import StoreKit
import Foundation
import MessageUI
import SystemConfiguration

@objc(UtilEnvironmentXT)
open class UtilEnvironment : NSObject{
    /// App Version
    public class var appVersion:String{
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
    /// App Build Version
    public class var appBuildVersion:String{
        return Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
    }
    /// System Version eg: 7.0,8.0,9.0,11.0.2
    public class var systemVersion:String{
        return UIDevice.current.systemVersion
    }
    // System Version eg:7.0,11.0020
    public class var systemVersionFloat:CGFloat{
        let systemVersion = UIDevice.current.systemVersion
        let systemVersionComponents = systemVersion.split(separator: ".")
        let sv0:Int = systemVersionComponents.count < 1 ? 0 : Int(systemVersionComponents[0])!
        let sv1:Int = systemVersionComponents.count < 2 ? 0 : Int(systemVersionComponents[1])!
        let sv2:Int = systemVersionComponents.count < 3 ? 0 : Int(systemVersionComponents[2])!
        let version = String(format: "%02d.%02d%02d", sv0, sv1, sv2)
        if let d = Double(version){
            return CGFloat(d)
        }
        return 0.0
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
            var bundleName:String = bundleInfo!["CFBundleName"] as! String
            bundleName = bundleName.replacingOccurrences(of: " ", with: "")
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.com/app/\(bundleName)")!)
        } else {
            UIApplication.shared.openURL(URL(string: "itms-apps://itunes.com/app/\(bundleName)")!)
        }
    }
    /// 打开AppStore 中的 App,根据APP上线分发的APPID[Appirater:自动评价APP弹框]
    public class func openAppStoreByAppID(_ appID: String){
        var appStoreURL:String!
        let systemVersion = UtilEnvironment.systemVersionFloat
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
    /// 弹框AppStore评分
    public class func alertGradeAppStore(){
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
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
    public class func systemVersionAfter(_ version:CGFloat) -> Bool{
        return UtilEnvironment.systemVersionFloat > version
    }
    /// 打开系统邮件
    class func openEmail(_ viewController:UIViewController,_ toEmail:String,_ subject:String,_ message:String,_ delegate:MFMailComposeViewControllerDelegate?){
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = delegate
        mailComposerVC.setToRecipients([toEmail])
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody(message, isHTML: false)

        if MFMailComposeViewController.canSendMail() {
            viewController.present(mailComposerVC, animated: true, completion: nil)
        }else{
            Mylog.log("打开系统邮件失败, 系统不支持发送.")
        }
    }
    /// 设置导航栏颜色(viewDidload后系统可能会改变tint渲染,所以要在viewDidAppear中修改)
    open func setNavigationBarColor(_ navigationBar:UINavigationBar?,_ colorTintBar:UIColor,_ colorTintText:UIColor){
        navigationBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: colorTintText] // 标题文本颜色
        navigationBar?.barTintColor = colorTintBar // bar背景色
        navigationBar?.tintColor = colorTintText // 左右文本颜色
        // 如果有背景图,则颜色不会渲染
        navigationBar?.setBackgroundImage(nil, for: .default)
    }
    /// 设置导航栏图片,阴影线
    open func setNavigationBarColor(_ navigationBar:UINavigationBar?,imageBar:UIImage? = nil,imageShadow:UIImage? = nil,colorTintBar:UIColor! = UIColor.white,colorTintText:UIColor! =
        UIColor.black, colorShadow:UIColor! = UIColor.gray){
        navigationBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: colorTintText]
        // 设置阴影线/图,必须要设置背景图,否则
        navigationBar?.setBackgroundImage(imageBar ?? utilShared.image.genImageFromColor(colorTintBar, CGSize(width:1, height:1)), for: .default)
        // 阴影图,导航栏下部分的分割线图
        navigationBar?.shadowImage = imageShadow ?? utilShared.image.genImageFromColor(colorShadow, CGSize(width:1, height:1))
    }
    /// 设置搜索栏的颜色
    open func setSearchBarColor(_ searchBar:UISearchBar?,_ colorTintBar:UIColor,_ colorTint:UIColor,_ colorBackground:UIColor){
        searchBar?.barTintColor = colorTintBar
        searchBar?.tintColor = colorTint
        searchBar?.backgroundColor = colorBackground
        // 如果有背景,背景色无效
        searchBar?.backgroundImage = nil
        searchBar?.searchBarStyle = .default // Text Field Style
        //searchBar?.setSearchFieldBackgroundImage(nil, for: .normal) //Text Field Background
    }
    /// 是否是模拟器
    public class func isSimulator() -> Bool{
        return TARGET_OS_SIMULATOR != 0 // Use this line in Xcode 7 or newer
        //return TARGET_IPHONE_SIMULATOR != 0 // Use this line in Xcode 6
    }
    /// 是否是 Iphone
    public class func isIphone() -> Bool{
        return TARGET_OS_IPHONE != 0
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
    /// 是否已经联网
    public class func isConnectedToNetwork() -> Bool{
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
    /// 屏幕大小point
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
    }
    /// 设备屏幕高度
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
        return Float(UIDevice.current.systemVersion.split(separator: ".")[0])! >= 8.0
    }
    /// Available iOS 10
    public class var availableiOS10: Bool{
        guard #available(iOS 10.0, *) else {
            return false
        }
        return true
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
    /// 设备信息
    public class var driverInformation:String{
        return String(format: "%@ %@ %@%@", UIDevice.current.name,UIDevice.current.model,UIDevice.current.systemName,UIDevice.current.systemVersion)
    }
}
