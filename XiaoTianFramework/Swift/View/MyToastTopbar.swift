//
//  MyToastTopbar.swift
//  XiaoTianFramework
//  状态栏,导航栏,自定义高度Toast弹出提示,支持阻尼回弹,重力回弹效果
//  Created by guotianrui on 2017/7/19.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

public class MyToastTopbar: NSObject{
    /// 显示高度,状态栏位置,导航栏位置,自定义
    public enum ToastType{ case statusBar, navigationBar, custom }
    /// 图片,指示器位置(let:靠左,左=弹框高/2+padding,right:靠右,右=弹框高/2+padding)
    public enum Alignment{ case left, center, right }
    /// Toast显示状态
    public enum State{ case waiting, entering, displaying, exiting, completed }
    /// 背景动画(背景:覆盖,推动)
    public enum Presentation{ case cover, push }
    /// 动画方向
    public enum Direction{ case top,bottom, left, right }
    /// 动画样式
    public enum AnimationType{ case linear, spring, gravity }
    //
    var preferedHeight: CGFloat = 48 // custom样式时的高度
    var type:ToastType = .navigationBar
    //
    var appearance:(() -> Void)? // CallBack Func
    var completion:(() -> Void)?
    //
    var title, subTitle:String?
    var fontTitle = UIFont.systemFont(ofSize: 12)
    var fontSubTitle = UIFont.systemFont(ofSize: 12)
    var image:UIImage?
    var imageTintColor:UIColor?
    var imageTextPadding:CGFloat = 10
    var imageAligment: Alignment = .right
    var showActivityIndicator = false
    var indicatorAligment: Alignment = .right
    var backgroundView:UIView?
    var backgroundColor = UIColor.lightGray
    //
    var autorotate = true
    var shouldKeepNavigationBarBorder = true //显示导航栏下面的边界线
    var statusBarStyle = UIStatusBarStyle.default
    var gestureRecognizers:[UIGestureRecognizer] = []
    var displayUnderStatusBar = false //显示在状态栏下一层
    //
    var animationDuration = 2.0 //显示持续时间(-1:不主动隐藏)
    var animationDurationIn = 0.25 //动画显示时间
    var animationDurationOut = 0.25 //动画消失时间
    //
    var presentationType = Presentation.push //背景呈现样式
    var directionIn = Direction.top
    var directionOut = Direction.top
    var inAnimationType = AnimationType.gravity
    var outAnimationType = AnimationType.linear
    //
    var springDamping: CGFloat = 0.6 //回弹阻尼
    var springInitialVelocity: CGFloat = 1.0 //回弹开始速度
    var gravityMagnitude: CGFloat = 6.0 //重力系数大小
    var collisionTweak:CGFloat = 0.2// 重力动画距离微调(.push:设置为0.0,.cover:设置为0.5)
    //
    private var uuid = UUID()
    private var state = State.waiting
    private var animator: UIDynamicAnimator?
    private var snapshotWindow = true //显示背景快照
    var forceUserInteraction = false
    var identifier:String?
    //UI
    private var mStatusBarViewm:UIView?
    private var mNotificationView:Controller.ToastView?
    var statusBarView:UIView{
        get{
            if mStatusBarViewm != nil{
                return mStatusBarViewm!
            }
            mStatusBarViewm = UIView(frame: statusBarViewAnimationFrame1())
            if snapshotWindow{ //显示快照
                mStatusBarViewm?.addSubview(getScreenSnapshotView(displayUnderStatusBar))
            }
            mStatusBarViewm?.clipsToBounds = true //剪掉边界外部分
            return mStatusBarViewm!
        }
    }
    private var notificationView:Controller.ToastView{
        get{
            if mNotificationView != nil{
                return mNotificationView!
            }
            mNotificationView = createNotificationView()
            return mNotificationView!
        }
    }
    //
    public init(_ title:String,_ message:String?,_ appearance:(()->Void)? = nil, _ completion:(()->Void)? = nil){
        self.title = title
        self.subTitle = message
        self.appearance = appearance
        self.completion = completion
        //self.image = UIImage(named: "bt_tab_im_none")
        //self.imageTintColor = UIColor.blue
        //self.backgroundView = UIImageView(image: UIImage(named: "ic_printer_gray"))
    }
    func initiateAnimator(_ view:UIView){
        animator = UIDynamicAnimator(referenceView: view)
    }
    // 创建弹出视图
    private func createNotificationView()-> Controller.ToastView{
        let size = notificationViewSize(type, preferedHeight)
        let toastView = Controller.ToastView(frame: CGRect(origin: CGPoint.zero, size: size))
        toastView.toast = self
        //
        toastView.label.textColor = UIColor.gray
        toastView.label.shadowOffset = CGSize(width: 0.1, height: 0.1)
        toastView.label.shadowColor = UIColor.black
        toastView.labelSub.textColor = UIColor.gray
        toastView.labelSub.shadowOffset = CGSize(width: 0.1, height: 0.1)
        toastView.labelSub.shadowColor = UIColor.black
        //
        return toastView
    }
    // 重力的方向
    func inGravityDirection()-> CGVector{
        let x:CGFloat = isVerticalAnimation(directionIn) ? 0 : directionIn == .left ? 1 : -1
        let y:CGFloat = x != 0 ? 0 : directionIn == .top ? 1 : -1
        return CGVector(dx: x, dy: y)
    }
    func outGravityDirection()-> CGVector{
        let x = isVerticalAnimation(directionOut) ? 0 : directionOut != .left ? 1 : -1
        let y = x != 0 ? 0 : directionOut != .top ? 1 : -1
        return CGVector(dx: x, dy: y)
    }
    // 重力碰撞触发边界
    func inCollisionPoint1()-> CGPoint{
        var x,y:CGFloat!
        let push = presentationType == .push
        let frame = notificationViewAnimationFrame1()
        let factor:CGFloat = presentationType == .cover ? 1 : 2
        switch directionIn {
        case .top:
            x = 0
            y = factor * (frame.height + (push ? -4*collisionTweak : collisionTweak))
        case .left:
            x = factor * (frame.width + (push ? -5*collisionTweak : 2*collisionTweak))
            y = frame.height
        case .bottom:
            x = frame.width
            y = -((factor - 1)*frame.height) - (push ? -5*collisionTweak : collisionTweak)
        case .right:
            x = -((factor - 1)*frame.width) - (push ? -5*collisionTweak : 2*collisionTweak)
            y = 0
        }
        return CGPoint(x: x, y: y)
    }
    func inCollisionPoint2()-> CGPoint{
        var x,y:CGFloat!
        let push = presentationType == .push
        let frame = notificationViewAnimationFrame1()
        let factor:CGFloat = presentationType == .cover ? 1 : 2
        switch directionIn {
        case .top:
            x = frame.width
            y = factor * (frame.height + (push ? -4*collisionTweak : collisionTweak))
        case .left:
            x = factor * (frame.width + (push ? -5*collisionTweak : 2*collisionTweak))
            y = 0
        case .bottom:
            x = 0
            y = -((factor - 1)*frame.height) - (push ? -5*collisionTweak : collisionTweak)
        case .right:
            x = -((factor - 1)*frame.width) - (push ? -5*collisionTweak : 2*collisionTweak)
            y = frame.height
        }
        return CGPoint(x: x, y: y)
    }
    func outCollisionPoint1()-> CGPoint{
        var x,y:CGFloat!
        let frame = notificationViewAnimationFrame1()
        switch directionOut {
        case .top:
            x = frame.width
            y = -frame.height - collisionTweak
        case .left:
            x = -frame.width - collisionTweak
            y = 0
        case .bottom:
            x = 0
            y = 2*frame.height + collisionTweak
        case .right:
            x = 2*frame.width + 2*collisionTweak
            y = frame.height
        }
        return CGPoint(x: x, y: y)
    }
    func outCollisionPoint2()-> CGPoint{
        var x,y:CGFloat!
        let frame = notificationViewAnimationFrame1()
        switch directionOut {
        case .top:
            x = 0
            y = -frame.height - collisionTweak
        case .left:
            x = -frame.width - collisionTweak
            y = frame.height
        case .bottom:
            x = frame.width
            y = 2*frame.height + collisionTweak
        case .right:
            x = 2*frame.width + 2*collisionTweak
            y = 0
        }
        return CGPoint(x: x, y: y)
    }
    // 竖向/上下动画
    func isVerticalAnimation(_ direction:Direction)-> Bool{
        return direction == .top || direction == .bottom
    }
    // 状态栏的位置大小
    func statusBarViewAnimationFrame1()-> CGRect{
        return getStatusBarViewFrame(type, directionIn, preferedHeight)
    }
    func statusBarViewAnimationFrame2()-> CGRect{
        return getStatusBarViewFrame(type, directionOut, preferedHeight)
    }
    func getStatusBarViewFrame(_ type:ToastType,_ direction:Direction,_ preferredHeight:CGFloat)-> CGRect{
        switch direction {
        case .top:
            return getNotificationViewFrame(type, .bottom, preferredHeight)
        case .bottom:
            return getNotificationViewFrame(type, .top, preferredHeight)
        case .left:
            return getNotificationViewFrame(type, .right, preferredHeight)
        case .right:
            return getNotificationViewFrame(type, .left, preferredHeight)
        }
    }
    // 进入初始化位置
    func notificationViewAnimationFrame1()-> CGRect{
        return getNotificationViewFrame(type, directionIn, preferedHeight)
    }
    // 退出初始化位置
    func notificationViewAnimationFrame2()-> CGRect{
        return getNotificationViewFrame(type, directionOut, preferedHeight)
    }
    func getNotificationViewFrame(_ type:ToastType,_ direction:Direction,_ preferredHeight:CGFloat)-> CGRect{
        let x = direction == .left ? -getStatusBarWidth() : direction == .right ? getStatusBarWidth() : 0
        let y = direction == .top ? -notificationViewHeight(type, preferredHeight) : direction == .bottom ? notificationViewHeight(type, preferredHeight) : 0
        return CGRect(x: x, y:y, width: getStatusBarWidth(), height: notificationViewHeight(type, preferredHeight))
    }
    /// 获取屏幕快照
    func getScreenSnapshotView(_ underStatusBar:Bool)-> UIView{
        if Double(UIDevice.current.systemVersion) ?? 0 >= 8.0{
            // VC不包含状态栏(包含导航栏), UIScreen包含状态栏
            return underStatusBar ? UIApplication.shared.keyWindow?.rootViewController?.view.snapshotView(afterScreenUpdates: true) ?? UIView() : UIScreen.main.snapshotView(afterScreenUpdates: true)
        }else{
            return underStatusBar ? UIApplication.shared.keyWindow?.rootViewController?.view.snapshotView(afterScreenUpdates: false) ?? UIView() : UIScreen.main.snapshotView(afterScreenUpdates: false)
        }
    }
    /// 显示提示
    public static func show(_ title:String, _ message: String? = nil,_ appearance:(()->Void)? = nil, _ completion:(()->Void)? = nil){
        Manager.share.addNotification(MyToastTopbar(title, message, appearance, completion))
    }
    /// 显示自定义配置的提示
    public static func show(toast:MyToastTopbar){
        Manager.share.addNotification(toast)
    }
    /// 隐藏显示(动态,全部,id号)
    public static func dismiss(animated:Bool,dismissAll:Bool? = nil,identifier:String? = nil){
        if Manager.share.notifications.isEmpty{
            return
        }
        func dismissFirstToast(){
            if let toast = Manager.share.notifications.first{
                if animated && (toast.state == .entering || toast.state == .displaying){
                    Manager.toastOutwardAnimationsSetupFunc(Manager.share)()
                }else{
                    Manager.toastOutwardAnimationsCompletionFunc(Manager.share)(true)
                }
            }
        }
        if dismissAll ?? false{
            dismissFirstToast()
            Manager.share.notifications.removeAll()
            return
        }
        var dismissToast:MyToastTopbar?
        if let identifier = identifier{
            for (_,toast) in Manager.share.notifications.enumerated(){
                if toast.identifier ?? "" == identifier{
                    dismissToast = toast
                    break
                }
            }
        }
        if let dismissToast = dismissToast{
            Manager.share.notifications.removeAll()
            Manager.share.notifications.append(dismissToast)
        }
        dismissFirstToast()
    }
    /// 是否显示中
    public static func isShowingNotification()-> Bool{
        return Manager.share.isShowing
    }
    /// 弹框管理
    class Manager:NSObject, UICollisionBehaviorDelegate{
        static let toastManagerCollistionBoundryIdentifier:NSString = "ToastManagerCollisionBoundryIdentifier"
        static let share = Manager()
        // Func 别名
        typealias AnimationFunc = ()->()
        typealias CompletionFunc = (Bool)->()
        private var window:Window
        var notifications:[MyToastTopbar] = []
        var isShowing:Bool{
            return !notifications.isEmpty
        }
        var notification:MyToastTopbar?{
            return notifications.first
        }
        var gravityAnimationCompletionFunc:CompletionFunc?
        //UI
        private var statusBarView:UIView!
        private var notificationView:Controller.ToastView!
        //
        private override init() {
            // 全屏窗口初始化
            window = Window(frame: UIScreen.main.bounds)
            window.backgroundColor = UIColor.clear
            window.windowLevel = UIWindow.Level.statusBar
            window.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.rootViewController = Controller()
            window.rootViewController?.view.clipsToBounds = true
        }
        //
        func addNotification(_ toast: MyToastTopbar){
            let currentIsShowing = self.isShowing
            notifications.append(toast) // 加到Array最后
            if currentIsShowing == false{
                displayNotification(toast)
            }
        }
        func displayNotification(_ toast:MyToastTopbar){
            toast.appearance?()
            window.isHidden = false
            var notificationSize = notificationViewSize(toast.type, toast.preferedHeight)
            //Mylog.log("notificationSize:\(notificationSize)")
            if toast.shouldKeepNavigationBarBorder{
                notificationSize.height -= 1.0
            }
            let rootVC = window.rootViewController as! Controller
            rootVC.statusBarStyle = toast.statusBarStyle
            rootVC.autorotate = toast.autorotate
            rootVC.toast = toast
            // 窗口,VC大小
            window.windowLevel = toast.displayUnderStatusBar ? UIWindow.Level.normal + 1 : UIWindow.Level.statusBar // 窗口级别[在其他窗口上/状态栏级别(覆盖状态栏)]
            window.rootViewController?.view.frame = getNotificationContainerFrame(getDeviceOrientation(), notificationSize)
            // 背景(被推效果)
            statusBarView = toast.statusBarView
            //statusBarView.backgroundColor = utilShared.color.randomColor
            statusBarView.isHidden = toast.presentationType == .cover
            statusBarView.frame = window.rootViewController!.view.bounds
            window.rootViewController?.view.addSubview(statusBarView)
            // 提示
            notificationView = toast.notificationView
            //notificationView.backgroundColor = utilShared.color.randomColor
            notificationView.frame = toast.notificationViewAnimationFrame1()
            window.rootViewController?.view.addSubview(notificationView)
            //
            for subView in window.rootViewController!.view.subviews{
                subView.isUserInteractionEnabled = false
            }
            window.rootViewController?.view.isUserInteractionEnabled = true
            window.rootViewController?.view.gestureRecognizers = toast.gestureRecognizers
            let inFunc = Manager.toastInwardAnimationsFunc(self, toast)
            let inCompleteFun = Manager.toastInwardAnimationsCompletionFunc(self, toast, toast.uuid.uuidString)
            toast.state = .entering
            showNotification(toast, inFunc, inCompleteFun)
            if toast.title?.count ?? 0 > 0 || toast.subTitle?.count ?? 0 > 0 {
                UtilDispatch.afterMainQueueDispatch(0.5, task: {
                    //Mylog.log("UIAccessibilityPostNotification")
                    UIAccessibility.post(notification: UIAccessibility.Notification.announcement, argument: ["Alert: \(toast.title ?? ""), \(toast.subTitle ?? "")"])
                })
            }
        }
        func showNotification(_ toast:MyToastTopbar,_ animations:@escaping AnimationFunc,_ completion:@escaping CompletionFunc){
            switch toast.inAnimationType {
            case .linear:
                UIView.animate(withDuration: toast.animationDurationIn, animations: animations, completion: completion)
            case .spring:
                UIView.animate(withDuration: toast.animationDurationIn, delay: 0.0, usingSpringWithDamping: toast.springDamping, initialSpringVelocity: toast.springInitialVelocity, options: [], animations: animations, completion: completion)
            case .gravity:
                let notificationView:UIView = self.notificationView
                let statusBarView:UIView = self.statusBarView
                toast.initiateAnimator(window.rootViewController!.view)
                // 重力
                let gravity = UIGravityBehavior(items: [notificationView, statusBarView])
                gravity.gravityDirection = toast.inGravityDirection()
                gravity.magnitude = toast.gravityMagnitude
                var collisionItems:[UIView] = [notificationView]
                if toast.presentationType == .push{
                    collisionItems.append(statusBarView)
                }
                // 碰撞
                let collision = UICollisionBehavior(items: collisionItems)
                collision.collisionDelegate = self
                //Mylog.log("In: \(toast.inGravityDirection()), \(toast.inCollisionPoint1())->\(toast.inCollisionPoint2())")
                // 碰撞边界
                collision.addBoundary(withIdentifier: Manager.toastManagerCollistionBoundryIdentifier, from: toast.inCollisionPoint1(), to: toast.inCollisionPoint2())
                // 取消Behavior循环
                let rotationLock = UIDynamicItemBehavior(items: collisionItems)
                rotationLock.allowsRotation = false
                toast.animator?.addBehavior(gravity)
                toast.animator?.addBehavior(collision)
                toast.animator?.addBehavior(rotationLock)
                gravityAnimationCompletionFunc = completion
            }
        }
        // Create Func As Param
        // 进入动画
        static func toastInwardAnimationsFunc(_ manager:Manager,_ toast:MyToastTopbar)-> AnimationFunc{
            return {
                manager.notificationView.frame = manager.window.rootViewController!.view.bounds
                manager.statusBarView.frame = toast.statusBarViewAnimationFrame1()
            }
        }
        // 进入完成
        static func toastInwardAnimationsCompletionFunc(_ manager:Manager,_ toast:MyToastTopbar,_ uuid:String)-> CompletionFunc{
            return{ finished in
                // 延时隐藏
                if toast.animationDuration > 0 && toast.state == .entering{
                    toast.state = .displaying
                    if !toast.forceUserInteraction {
                        UtilDispatch.afterMainQueueDispatch(TimeInterval(toast.animationDuration), task: {
                            if let firstToast = manager.notifications.first{
                                if firstToast.state == .displaying && firstToast.uuid.uuidString == uuid{
                                    manager.gravityAnimationCompletionFunc = nil
                                    Manager.toastOutwardAnimationsSetupFunc(manager)()
                                }
                            }
                        })
                    }
                }
            }
        }
        // 退出动画设置
        static func toastOutwardAnimationsSetupFunc(_ manager:Manager)-> AnimationFunc{
            return {
                guard let firstToast = manager.notifications.first else {
                    return
                }
                firstToast.state = .exiting
                manager.statusBarView.frame = firstToast.notificationViewAnimationFrame2()
                _ = manager.window.rootViewController?.view.gestureRecognizers?.enumerated().map({ (index,gesture) -> Int in
                    gesture.isEnabled = false
                    return 0
                })
                switch firstToast.outAnimationType{
                case .linear:
                    UIView.animate(withDuration: firstToast.animationDurationOut, delay: 0, options: [], animations: Manager.toastOutwardAnimationsFunc(manager), completion: Manager.toastOutwardAnimationsCompletionFunc(manager))
                case .spring:
                    UIView.animate(withDuration: firstToast.animationDurationOut, delay: 0, usingSpringWithDamping: firstToast.springDamping, initialSpringVelocity: firstToast.springInitialVelocity, options: [], animations: Manager.toastOutwardAnimationsFunc(manager), completion: Manager.toastOutwardAnimationsCompletionFunc(manager))
                case .gravity:
                    if firstToast.animator == nil{
                        firstToast.initiateAnimator(manager.window.rootViewController!.view)
                    }
                    firstToast.animator?.removeAllBehaviors()
                    let notificationView:UIView = manager.notificationView
                    let statusBarView:UIView = manager.statusBarView
                    // 重力
                    let gravity = UIGravityBehavior(items: [notificationView,statusBarView])
                    gravity.gravityDirection = firstToast.outGravityDirection()
                    gravity.magnitude = firstToast.gravityMagnitude
                    var collisionItems:[UIView] = [notificationView]
                    if firstToast.presentationType == .push{
                        // 背景一起执行动画
                        collisionItems.append(statusBarView)
                    }
                    // 碰撞
                    let collision = UICollisionBehavior(items: collisionItems)
                    collision.collisionDelegate = manager
                    //Mylog.log("Out: \(firstToast.outGravityDirection()) \(firstToast.outCollisionPoint1())->\(firstToast.outCollisionPoint2())")
                    let out1 = firstToast.outCollisionPoint1()
                    let out2 = firstToast.outCollisionPoint2()
                    //collision.addBoundary(withIdentifier: Manager.toastManagerCollistionBoundryIdentifier, from: firstToast.outCollisionPoint1(), to: firstToast.outCollisionPoint2())
                    collision.addBoundary(withIdentifier: Manager.toastManagerCollistionBoundryIdentifier, from: CGPoint(x:out2.x, y:out1.y/2), to: CGPoint(x:out1.x, y:out2.y/2))
                    let rotationLock = UIDynamicItemBehavior(items: collisionItems)
                    rotationLock.allowsRotation = false
                    firstToast.animator?.addBehavior(gravity)
                    firstToast.animator?.addBehavior(collision)
                    firstToast.animator?.addBehavior(rotationLock)
                    manager.gravityAnimationCompletionFunc = Manager.toastOutwardAnimationsCompletionFunc(manager)
                }
            }
        }
        // 退出动画完成
        static func toastOutwardAnimationsCompletionFunc(_ manager:Manager)-> CompletionFunc{
            return {finished in
                guard let firstToast:MyToastTopbar = manager.notifications.first else {
                    return
                }
                if firstToast.showActivityIndicator{
                    manager.notificationView.activityIndicator.stopAnimating()
                }
                manager.window.rootViewController?.view.gestureRecognizers = nil
                firstToast.state = .completed
                firstToast.completion?()
                manager.notifications.remove(at: manager.notifications.firstIndex(of: firstToast)!)
                manager.notificationView.removeFromSuperview()
                manager.statusBarView.removeFromSuperview()
                manager.gravityAnimationCompletionFunc = nil
                manager.notificationView = nil
                manager.statusBarView = nil
                // 释放相互引用,防止内存崩溃泄漏
                firstToast.notificationView.toast = nil
                firstToast.mNotificationView = nil
                if manager.notifications.count > 0{
                    // 显示下一条
                    if let next = manager.notifications.first{
                        manager.displayNotification(next)
                    }
                }else{
                    manager.window.isHidden = true
                }
            }
        }
        // 退出动画
        static func toastOutwardAnimationsFunc(_ manager:Manager)-> AnimationFunc{
            return {
                guard let firstToast = manager.notifications.first else {
                    return
                }
                firstToast.state = .exiting
                firstToast.animator?.removeAllBehaviors()
                manager.notificationView.frame = firstToast.notificationViewAnimationFrame2()
                if let frame = manager.window.rootViewController?.view.bounds{
                    manager.statusBarView.frame = frame
                }
            }
        }
        // UICollisionBehaviorDelegate
        func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?) {
            //Mylog.log("endedContactFor")
            gravityAnimationCompletionFunc?(true)
        }
        func collisionBehavior(_ behavior: UICollisionBehavior, endedContactFor item1: UIDynamicItem, with item2: UIDynamicItem) {
            //Mylog.log("endedContactFor:with")
            gravityAnimationCompletionFunc?(true)
            gravityAnimationCompletionFunc = nil
        }
    }
    //
    private class Controller: UIViewController{
        var toast:MyToastTopbar?
        var autorotate:Bool
        
        var statusBarStyle:UIStatusBarStyle?{
            didSet{
                // 更新StatusBar外观
                setNeedsStatusBarAppearanceUpdate()
            }
        }
        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            autorotate = true
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        // 是否自动旋转
        override var shouldAutorotate: Bool{
            return autorotate
        }
        // 默认是否隐藏状态栏
        override var prefersStatusBarHidden: Bool{
            return UIApplication.shared.isStatusBarHidden
        }
        // 默认状态栏样式
        override var preferredStatusBarStyle: UIStatusBarStyle{
            return statusBarStyle ?? UIStatusBarStyle.default
        }
        // This is where subclasses should create their custom view hierarchy if they aren't using a nib. Should never be called directly.
        override func loadView() {
            view = ContainerView()
        }
        // VC 旋转触发,在旋转前触发
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            if let toast = toast{
                let notificationSize = getNotificationViewSizeForOrientation(toast.type, toast.preferedHeight, getDeviceOrientation())
                toast.notificationView.frame = CGRect(origin: CGPoint.zero, size: notificationSize)
            }
        }
        class ContainerView: UIView{
            
        }
        class ToastView: UIView{
            private let contentInsetLeft:CGFloat = 10
            private let contentInsetRight:CGFloat = 10
            private let underStatusBarYOffset:CGFloat =  -5
            //
            var label = UILabel()
            var labelSub = UILabel()
            var imageView = UIImageView()
            var backgroundView:UIView?
            var activityIndicator = UIActivityIndicatorView(style: .white)
            var toast:MyToastTopbar!{
                didSet{
                    if toast != nil{
                        updateToastData()
                    }
                }
            }
            override init(frame: CGRect) {
                super.init(frame: frame)
                isUserInteractionEnabled = true
                autoresizingMask = [.flexibleWidth]
                imageView.contentMode = .center
                addSubview(label)
                addSubview(labelSub)
                addSubview(imageView)
                addSubview(activityIndicator)
                isAccessibilityElement = true
                accessibilityLabel = NSStringFromClass(self.classForCoder)
            }
            required init?(coder aDecoder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            func updateToastData(){
                label.text = toast.title
                label.font = toast.fontTitle
                label.textAlignment = .center
                label.textColor = UIColor.black
                label.numberOfLines = 0
                label.backgroundColor = UIColor.clear
                if let subTitle = toast.subTitle{
                    labelSub.text = subTitle
                    labelSub.font = toast.fontSubTitle
                    labelSub.textAlignment = .center
                    labelSub.textColor = UIColor.black
                    labelSub.numberOfLines = 0
                    labelSub.backgroundColor = UIColor.clear
                }
                if let tint = toast.imageTintColor{
                    imageView.image = toast.image?.withRenderingMode(.alwaysTemplate)
                    imageView.tintColor = tint
                }else{
                    imageView.image = toast.image
                }
                imageView.contentMode = .center
                backgroundColor = toast.backgroundColor
                activityIndicator.style = .white
                if let backgroundView = toast.backgroundView{
                    self.backgroundView = backgroundView
                    if self.backgroundView!.superview == nil{
                        self.insertSubview(self.backgroundView!, at: 0)
                    }
                }
            }
            // 布局子View
            override func layoutSubviews() {
                super.layoutSubviews()
                var contentFrame = bounds
                let imageSize = imageView.image?.size
                let statusBarYOffset = toast.displayUnderStatusBar ? getStatusBarHeight() + underStatusBarYOffset : 0
                contentFrame.size.height = contentFrame.size.height - statusBarYOffset
                backgroundView?.frame = bounds
                let imageXOffset = imageXOffsetForAlignment(toast.imageAligment, toast.imageTextPadding, contentFrame.size)
                var imageWidth = imageSize?.width ?? 0 == 0 ? 0 : contentFrame.height // 图片的大小
                let imageHeight = imageSize?.height ?? 0 == 0 ? 0 : contentFrame.height
                imageView.frame = CGRect(x: imageXOffset, y: statusBarYOffset, width: imageWidth, height: imageHeight)
                imageWidth = imageSize?.width ?? 0 == 0 ? 0 : imageView.frame.maxX
                var x = contentXOffsetForAlignmentAndWidth(toast.imageAligment, imageXOffset, imageWidth, toast.imageTextPadding)
                //
                if toast.showActivityIndicator{
                    let centerX = centerXForActivityIndicatorWithAligment(toast.indicatorAligment, contentFrame.height, contentFrame.width, toast.imageTextPadding)
                    activityIndicator.center = CGPoint(x: centerX, y: contentFrame.midY + statusBarYOffset)
                    activityIndicator.startAnimating()
                    bringSubviewToFront(activityIndicator)
                    x = max(contentXOffsetForAlignmentAndWidth(toast.indicatorAligment, imageXOffset, contentFrame.height, toast.imageTextPadding), x)
                }
                let isShowImage = imageSize?.width ?? 0 > 0
                let width = contentWidthForAccessoryViewsWithAlignment(contentFrame.width, contentFrame.height, toast.imageTextPadding, isShowImage, toast.imageAligment, toast.showActivityIndicator, toast.indicatorAligment)
                //
                if toast.subTitle == nil{
                    label.frame = CGRect(x: x, y: statusBarYOffset, width: width, height: contentFrame.height)
                }else{
                    let titleRect = calculateTextSize(toast.title! as NSString, toast.fontTitle, CGSize(width:width, height:CGFloat.greatestFiniteMagnitude))
                    let height = min(titleRect!.size.height, contentFrame.height)
                    var subHeight = calculateTextSize(toast.subTitle! as NSString, toast.fontSubTitle, CGSize(width:width, height:CGFloat.greatestFiniteMagnitude))!.size.height
                    if contentFrame.height - (height + subHeight) < 5{
                        subHeight = contentFrame.height - height - 10
                    }
                    let offset = (contentFrame.height - (height + subHeight)) / 2
                    label.frame = CGRect(x: x, y: offset + statusBarYOffset, width: contentFrame.width - x - contentInsetRight, height: height)
                    labelSub.frame = CGRect(x: x, y: height + offset + statusBarYOffset, width: contentFrame.width - x - contentInsetRight, height: subHeight)
                }
                //
                if (isShowImage || toast.showActivityIndicator) && (toast.indicatorAligment == .center || toast.imageAligment == .center){
                    //重新计算宽度,赋值宽度
                    let labelHeight = label.frame.height
                    label.sizeToFit()
                    label.center = CGPoint(x: frame.midX, y: label.center.y) // midX:X中点
                    label.frame = CGRect(x: label.frame.minX, y: label.frame.minY, width: label.frame.width, height: labelHeight)
                    let subLebelHeight = labelSub.frame.height
                    labelSub.sizeToFit()
                    labelSub.center = CGPoint(x: frame.midX, y: labelSub.center.y)
                    labelSub.frame = CGRect(x: labelSub.frame.minX, y: labelSub.frame.minY, width: labelSub.frame.width, height: subLebelHeight)// minX:X最小值
                    if label.frame.width == 0 && labelSub.frame.width == 0{
                        return
                    }
                    //x的最小值,防止文字,图片重叠
                    let smallestXView = min(label.frame.minX, labelSub.frame.minX)
                    if isShowImage && toast.imageAligment == .center{
                        imageView.frame = CGRect(origin: CGPoint(x: smallestXView - imageView.frame.width - toast.imageTextPadding, y:imageView.frame.origin.y), size: imageView.frame.size)
                    }
                    if toast.showActivityIndicator && toast.indicatorAligment == .center{
                        activityIndicator.frame = CGRect(origin: CGPoint(x:smallestXView - activityIndicator.frame.width - toast.imageTextPadding, y:activityIndicator.frame.origin.y), size: activityIndicator.frame.size)
                    }
                }
                
            }
            func imageXOffsetForAlignment(_ alignment:Alignment,_ padding:CGFloat,_ contentSize:CGSize) -> CGFloat{
                switch alignment {
                case .left:
                    return padding
                case .center:
                    return (contentSize.width / 2) - (contentSize.height / 2)
                case .right:
                    return contentSize.width - padding - contentSize.height
                }
            }
            func contentXOffsetForAlignmentAndWidth(_ alignment:Alignment,_ imageXOffset:CGFloat,_ imageWidth:CGFloat,_ padding:CGFloat) -> CGFloat{
                return (imageWidth == 0 || alignment != .left) ? contentInsetLeft + padding : imageXOffset + imageWidth
            }
            func centerXForActivityIndicatorWithAligment(_ alignment:Alignment,_ viewWidth:CGFloat,_ contentWidth:CGFloat,_ padding:CGFloat) -> CGFloat{
                let offset = viewWidth / 2 + padding
                switch alignment {
                case .left:
                    return offset
                case .center:
                    return contentWidth / 2
                case .right:
                    return contentWidth - offset
                }
            }
            func contentWidthForAccessoryViewsWithAlignment(_ contentWidth:CGFloat,_ contentHeight:CGFloat,_ padding:CGFloat,_ showImage:Bool,_ alignmentImage:Alignment,_ showIndicator:Bool,_ alignmentIndicator:Alignment) -> CGFloat{
                if showImage && showIndicator && alignmentImage == alignmentIndicator{
                    return contentWidth
                }
                var width = contentWidth
                width -= toastWidthOfViewWithAlignment(contentHeight, showImage, alignmentImage, padding)
                width -= toastWidthOfViewWithAlignment(contentHeight, showIndicator, alignmentIndicator, padding)
                if !showImage && !showIndicator {
                    width -= (contentInsetLeft + contentInsetRight)
                    width -= (padding + padding)
                }
                return width
            }
            func toastWidthOfViewWithAlignment(_ height:CGFloat,_ show:Bool,_ alignment:Alignment,_ padding:CGFloat) -> CGFloat{
                return (!show || alignment == .center) ? 0 : padding + height + padding
            }
            public func calculateTextSize(_ text:NSString,_ font:UIFont,_ maxConstraintSize:CGSize) -> CGRect?{
                return text.boundingRect(with: maxConstraintSize, options: [.truncatesLastVisibleLine,.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedString.Key.font:font], context: nil)
            }
        }
    }
    private class Window: UIWindow{
        // 触发的事件是否在其View中
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            for subView in subviews{
                // point is in the receiver's coordinate system
                if subView .hitTest(self.convert(point, to: subView), with: event) != nil{
                    return true
                }
            }
            return false
        }
    }
}
fileprivate func getDeviceOrientation() -> UIInterfaceOrientation{
    return UIApplication.shared.statusBarOrientation
}
fileprivate func getStatusBarHeight() -> CGFloat{
    return getStatusBarHeightForOrientation(getDeviceOrientation())
}
fileprivate func getStatusBarWidth() -> CGFloat{
    return getStatusBarWidthForOrientation(getDeviceOrientation())
}
fileprivate func getNotificationViewSizeForOrientation(_ type:MyToastTopbar.ToastType,_ preferredHeight:CGFloat,_ orientation:UIInterfaceOrientation) -> CGSize{
    return CGSize(width: getStatusBarWidthForOrientation(orientation), height: getNotificationViewHeightForOrientation(type, preferredHeight, orientation))
}
fileprivate func getNotificationViewHeightForOrientation(_ type:MyToastTopbar.ToastType,_ preferredHeight:CGFloat,_ orientation:UIInterfaceOrientation) -> CGFloat{
    switch type {
    case .statusBar:
        return getStatusBarHeightForOrientation(orientation)
    case .navigationBar:
        return getStatusBarHeightForOrientation(orientation) + getNavigatioinBarHeigthForOrientation(orientation)
    case .custom:
        return preferredHeight
    }
}
fileprivate func getNotificationContainerFrame(_ orientation:UIInterfaceOrientation,_ size:CGSize) -> CGRect{
    if frameAutoAdjustedForOrientation(){
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
    switch orientation {
    case .landscapeLeft:
        return CGRect(x: 0, y: 0, width: size.height, height: size.width)
    case .landscapeRight:
        return CGRect(x: UIScreen.main.bounds.width - size.height, y: 0, width: size.height, height: size.width)
    case .portraitUpsideDown:
        return CGRect(x: UIScreen.main.bounds.height - size.height, y: 0, width: size.width, height: size.height)
    default:
        return CGRect(x: 0, y: 0, width: size.width, height: size.height)
    }
}
// 根据屏幕方向获取状态栏宽度
fileprivate func getStatusBarWidthForOrientation(_ orientation:UIInterfaceOrientation) -> CGFloat{
    let screenBounds = UIScreen.main.bounds
    if frameAutoAdjustedForOrientation(){
        return screenBounds.width
    }
    return orientation.isPortrait ? screenBounds.width : screenBounds.height
}
// 根据屏幕方向获取状态栏高度
fileprivate func getStatusBarHeightForOrientation(_ orientation:UIInterfaceOrientation) -> CGFloat{
    let statusBarFrame = UIApplication.shared.statusBarFrame
    if frameAutoAdjustedForOrientation(){
        return statusBarFrame.height
    }
    return orientation.isLandscape ? statusBarFrame.width : statusBarFrame.height
}
fileprivate func notificationViewHeight(_ type:MyToastTopbar.ToastType,_ preferredHeight:CGFloat) -> CGFloat{
    return getNotificationViewHeightForOrientation(type, preferredHeight, getDeviceOrientation())
}
// 根据屏幕方向获取导航栏栏高度
fileprivate func getNavigatioinBarHeigthForOrientation(_ orientation:UIInterfaceOrientation)-> CGFloat{
    var regularHorizontalSizeClass = false
    if isUserSizeClass(){
        regularHorizontalSizeClass = isHorizontalSizeClassRegular()
    }
    if (orientation.isPortrait || UI_USER_INTERFACE_IDIOM() == .pad || regularHorizontalSizeClass){
        // 其他,导航栏高度
        return 45
    }else{
        // ipad 横屏,导航栏高度
        return 33
    }
}
// 根据显示类型,屏幕方向获取弹框视图大小
fileprivate func notificationViewSize(_ type:MyToastTopbar.ToastType,_ preferredHeight:CGFloat) -> CGSize{
    return CGSize(width: getStatusBarWidth(), height: notificationViewHeight(type, preferredHeight))
}
fileprivate func isHorizontalSizeClassRegular()-> Bool{
    if isUserSizeClass(){
        if #available(iOS 8.0, *){
            return UIScreen.main.traitCollection.horizontalSizeClass == .regular
        }
    }
    return false
}
fileprivate func isUserSizeClass()-> Bool{
    if #available(iOS 8.0, *){
        return UIScreen.main.responds(to: #selector(getter: UIScreen.traitCollection))
    }else{
        return false
    }
}
fileprivate func frameAutoAdjustedForOrientation()-> Bool{
    if #available(iOS 8.0, *){
        return UIScreen.main.responds(to: #selector(getter: UIScreen.traitCollection))
    }else{
        return false
    }
}
