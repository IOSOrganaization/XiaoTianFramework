//
//  MyToast.swift
//  XiaoTianFramework
//  Toast弹框,支持靠下,居中,靠上弹出模式
//  Created by guotianrui on 2017/7/27.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
public class MyToast:NSObject{
    public enum Gravity{ case center, top, bottom } //弹出位置中,上,下
    private let springDamping:CGFloat = 0.6 //回弹系数
    private let animationTime:TimeInterval = 0.5 //动画时间
    private let springInitialVelocity:CGFloat = 2.0 //初始化重力系数
    private var toastView:ToastView?
    //
    var message:String
    var textFont = UIFont.systemFont(ofSize: 14)
    var textColor = UIColor.white
    var gravity = Gravity.bottom
    var cornerRadius:CGFloat = 10
    var marginOffset:CGFloat = 120
    var toastDuration:TimeInterval = 2
    var backgroundColor = UIColor(white: 0.25, alpha: 0.8)
    var contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    init(_ message:String) {
        self.message = message
    }
    /// 显示
    public static func show(_ message:String?){
        if let message = message{
            Manager.share.show(message)
        }
    }
    /// 隐藏全部
    public static func unShowOtherToast(){
        Manager.share.hideToastAll()
    }
    public static var isShowing:Bool{
        return !Manager.share.notifications.isEmpty
    }
    // 控制在弹框窗口上
    private class Manager:NSObject{
        // 单例 manager
        static let share = Manager()
        // 全局显示的 window
        private var isHideToastAll = false
        private var window:UIWindow
        private var toastView:ToastView?
        fileprivate var notifications:[MyToast] = []
        
        override init() {
            window = Window(frame: UIScreen.main.bounds)
            window.backgroundColor = UIColor.clear
            window.windowLevel = UIWindow.Level.statusBar + 1
            window.autoresizingMask = [.flexibleWidth,.flexibleHeight]
            window.rootViewController = Controller()
            window.rootViewController?.view.clipsToBounds = true
        }
        func show(_ message:String){
            let isUnshowing = notifications.isEmpty
            let toast = MyToast(message)
            notifications.append(toast)
            if isUnshowing{
                displayToast(toast)
            }
        }
        func displayToast(_ toast:MyToast){
            window.isHidden = false
            isHideToastAll = false
            toastView = ToastView(toast)
            let controller = window.rootViewController as! Controller
            controller.toast = toast
            controller.view.addSubview(toastView!)
            for subView in controller.view.subviews{
                subView.isUserInteractionEnabled = false
            }
            let toastViewFrame = toastView!.frame
            self.toastView!.alpha = 0
            self.toastView!.status = .entering
            self.toastView!.frame = CGRect(x: toastViewFrame.origin.x, y: toastViewFrame.origin.y + 2*toastViewFrame.height, width: toastViewFrame.width, height: 0)
            // 重力弹出
            UIView.animate(withDuration: toast.animationTime, delay: 0.0, usingSpringWithDamping: toast.springDamping,
                           initialSpringVelocity: toast.springInitialVelocity, options: [], animations: {   [weak self] in
                guard let wSelf = self else {
                    return
                }
                guard let toastView = wSelf.toastView else {
                    return
                }
                toastView.alpha = 1
                toastView.frame = toastViewFrame
                }, completion: {[weak self] finished in
                    // 定时关闭
                    if self?.toastView?.status ?? .completed != .entering{
                        return
                    }
                    self?.toastView!.status = .displaying
                    UtilDispatch.afterMainQueueDispatch(toast.toastDuration, task: {[weak self] in
                        if self?.toastView?.status ?? .completed != .displaying{
                            return
                        }
                        self?.toastView?.status = .exiting
                        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {[weak self] in
                            guard let wSelf = self else {
                                return
                            }
                            guard let firstToast = wSelf.notifications.first else {
                                return
                            }
                            firstToast.toastView?.alpha = 0
                            }, completion: { [weak self] finished in
                                guard let wSelf = self else{
                                    return
                                }
                                guard let firstToast = wSelf.notifications.first else{
                                    return
                                }
                                firstToast.toastView?.status = .completed
                                wSelf.notifications.remove(at: wSelf.notifications.firstIndex(of: firstToast)!)
                                firstToast.toastView?.removeFromSuperview()
                                // 释放
                                firstToast.toastView?.toast = nil
                                firstToast.toastView = nil
                                wSelf.toastView = nil
                                if wSelf.isHideToastAll{
                                    wSelf.notifications.removeAll()
                                }
                                // 如果集合中还有则继续弹框
                                if !wSelf.notifications.isEmpty{
                                    if let next = wSelf.notifications.first{
                                        wSelf.displayToast(next)
                                    }
                                }else{
                                    wSelf.window.isHidden = true
                                }
                        })
                    })
            })
        }
        func hideToastAll(){
            isHideToastAll = true
        }
    }
    private class ToastView: UIView{
        enum Status{ case waiting, entering, displaying, exiting, completed}
        var status:Status = .waiting
        var label = UILabel()
        var toast:MyToast?
        
        convenience init(_ toast:MyToast) {
            self.init(frame:CGRect.zero)
            self.toast = toast
            self.toast?.toastView = self
            backgroundColor = toast.backgroundColor
            layer.cornerRadius = toast.cornerRadius
            alpha = 0
            //
            label.lineBreakMode = .byWordWrapping
            label.textColor = toast.textColor
            label.textAlignment = .center
            label.font = toast.textFont
            label.numberOfLines = 0
            label.text = toast.message
            //
            let messageSize = textSizeToFit
            self.frame = MyToast.getToastViewFrameByGravity(toast.gravity, toast.contentInset, toast.marginOffset, messageSize)
            label.frame = CGRect(x: toast.contentInset.left, y: toast.contentInset.top, width: messageSize.width, height: messageSize.height)
            addSubview(label)
        }
        var textSizeToFit:CGSize{
            let screenWidth = MyToast.getScreenWidthForOrientation()
            label.frame = CGRect(x: 0, y: 0, width: screenWidth - layoutMargins.left - layoutMargins.right, height: CGFloat.greatestFiniteMagnitude)
            label.sizeToFit()
            return label.bounds.size
        }
        deinit {
            //Mylog.log("ToastView deinit")
        }
    }
    private class Controller:UIViewController{
        var toast:MyToast?
        
        override var shouldAutorotate: Bool{
            return true
        }
        override var prefersStatusBarHidden: Bool{
            return UIApplication.shared.isStatusBarHidden
        }
        override var preferredStatusBarStyle: UIStatusBarStyle{
            return UIStatusBarStyle.default
        }
        // 屏幕旋转,重新计算位置
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            if let toast = toast{
                guard let toastView = toast.toastView else{
                    return
                }
                toastView.frame = MyToast.getToastViewFrameByGravity(toast.gravity, toast.contentInset, toast.marginOffset, toastView.label.frame.size)
            }
        }
    }
    private class Window:UIWindow{
        // 不拦截点击事件
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return false
        }
    }
    private static func getToastViewFrameByGravity(_ gravity:Gravity,_ contentInset:UIEdgeInsets,_ marginOffset:CGFloat,_ messageSize:CGSize)-> CGRect{
        let screenWidth = MyToast.getScreenWidthForOrientation()
        let screenHeight = MyToast.getScreenHeightForOrientation()
        let width = messageSize.width + contentInset.left + contentInset.right
        let height = messageSize.height + contentInset.top + contentInset.bottom
        switch gravity {
        case .top:
            return CGRect(x: (screenWidth - messageSize.width) / 2, y: marginOffset, width: width, height: height)
        case .bottom:
            return CGRect(x: (screenWidth - messageSize.width) / 2, y: screenHeight - marginOffset, width: width, height: height)
        case .center:
            return CGRect(x: (screenWidth - messageSize.width) / 2, y: screenHeight / 2 + marginOffset, width: width, height: height)
        }
    }
    private static func getScreenWidthForOrientation()-> CGFloat{
        let screenBounds = UIScreen.main.bounds
        if MyToast.frameAutoAdjustedForOrientation(){
            return screenBounds.width
        }
        return getDeviceOrientation().isPortrait ? screenBounds.width : screenBounds.height
    }
    private static func getScreenHeightForOrientation()-> CGFloat{
        let screenBounds = UIScreen.main.bounds
        if MyToast.frameAutoAdjustedForOrientation(){
            return screenBounds.height
        }
        return getDeviceOrientation().isPortrait ? screenBounds.height : screenBounds.width
    }
    private static func getDeviceOrientation()-> UIInterfaceOrientation{
        return UIApplication.shared.statusBarOrientation
    }
    private static func frameAutoAdjustedForOrientation()-> Bool{
        if #available(iOS 8.0, *){
            return UIScreen.main.responds(to: #selector(getter: UIScreen.traitCollection))
        }else{
            return false
        }
    }
}
