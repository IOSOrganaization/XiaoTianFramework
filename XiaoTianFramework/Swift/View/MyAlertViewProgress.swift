//
//  MyAlertViewProgress.swift
//  XiaoTianFramework
//  加载中弹框(百分比圆环加载,循环渐变圆环加载,加载完成提示中间带图标)
//  Created by guotianrui on 2017/6/24.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
open class MyAlertViewProgress: UIView{
    // 通知事件
    public static let TAG_WILL_APPEAR = "MyAlertViewProgress.TAG_WILL_APPEAR"
    public static let TAG_TOUCH_EVENT = "MyAlertViewProgress.TAG_TOUCH_EVENT"
    public static let TAG_TOUCH_EVENT_DOWN_INSIDE = "MyAlertViewProgress.TAG_TOUCH_EVENT_DOWN_INSIDE"
    public static let TAG_WILL_DISAPPEAR = "MyAlertViewProgress.TAG_WILL_DISAPPEAR"
    public static let TAG_DID_DISAPPEAR = "MyAlertViewProgress.TAG_DID_DISAPPEAR"
    public static let KEY_USER_INFO = "MyAlertViewProgress.KEY_USER_INFO"
    //
    public static let PROGRESS_RING:CGFloat = -1
    public static let MASK_NONE:Int = 0x001;// allow user interactions while HUD is displayed
    public static let MASK_CLEAR:Int = 0x002;//  don't allow user interactions
    public static let MASK_BLACK:Int = 0x003;//  don't allow user interactions
    public static let MASK_GRADIENT:Int = 0x004;//  don't allow user interactions
    // 全局单例模式
    static let shared:MyAlertViewProgress = {
        return MyAlertViewProgress(frame: UIScreen.main.bounds) // 全屏
    }()
    var maskType:Int = MASK_NONE
    var fontText:UIFont!
    var fadeOutTimer: Timer?
    var progress:CGFloat = 0.0
    var activityCount: Int = 0
    var imageInfo, imageSuccess, imageError:UIImage!
    var colorBackground,colorForeground,colorLabelText,colorProgress:UIColor!
    var overlayView: UIControl! {
        get{
            if _overlayView != nil{
                return _overlayView
            }
            _overlayView = UIControl(frame: UIScreen.main.bounds)
            _overlayView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            _overlayView?.backgroundColor = UIColor.clear
            _overlayView?.addTarget(self, action: #selector(overlayViewDidReceiveTouchEvent(_:_:)), for: .touchDown)
            return _overlayView
        }
        set{
            _overlayView = newValue
        }
    }
    var imageView: UIImageView?{
        get{
            if _imageView == nil{
                _imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 28.0, height: 28.0))
            }
            if _imageView?.superview == nil {
                hudView?.addSubview(_imageView!)
            }
            return _imageView
        }
        set{
            _imageView = newValue
        }
    }
    var labelString:UILabel?{
        get{
            if _labelString == nil{
                _labelString = UILabel(frame: CGRect.zero)
                _labelString?.backgroundColor = UIColor.clear
                _labelString?.adjustsFontSizeToFitWidth = true
                _labelString?.textAlignment = .center
                _labelString?.baselineAdjustment = .alignCenters
                _labelString?.numberOfLines = 0
            }
            if _labelString?.superview == nil{
                hudView?.addSubview(_labelString!)
            }
            _labelString?.textColor = colorLabelText
            _labelString?.font = fontText
            return _labelString
        }
        set{
            _labelString = newValue
        }
    }
    var progressView:MyViewRingProgress?{
        get{
            if _progressView != nil{
                return _progressView
            }
            _progressView = MyViewRingProgress(CGPoint(x: 0, y: 0), labelString?.text == nil ? 18 : 24, colorProgress, 7)
            return _progressView
        }
        set{
            _progressView = newValue
        }
    }
    // 进度条
    var ringLayer:CAShapeLayer?{
        get{
            if _ringLayer != nil{
                return _ringLayer
            }
            let center = CGPoint(x: hudView!.frame.width/2, y: hudView!.frame.height/2)
            let radius:CGFloat = progressView!.radius
            let smoothedPath = UIBezierPath(arcCenter: CGPoint(x:radius,y:radius), radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(Double.pi + Double.pi / 2), clockwise: true)
            _ringLayer = CAShapeLayer()
            _ringLayer?.contentsScale = UIScreen.main.scale
            _ringLayer?.frame = CGRect(x: center.x - radius, y: center.y - radius, width: radius*2, height: radius*2)
            _ringLayer?.fillColor = UIColor.clear.cgColor
            _ringLayer?.strokeColor = colorProgress.withAlphaComponent(0.4).cgColor
            _ringLayer?.lineWidth = progressView!.storeThickness
            _ringLayer?.lineCap = kCALineCapRound
            _ringLayer?.lineJoin = kCALineJoinBevel
            _ringLayer?.path = smoothedPath.cgPath
            hudView?.layer.addSublayer(_ringLayer!)
            return _ringLayer
        }
        set{
            _ringLayer = newValue
        }
    }
    // 进度条背景
    var backgroundRingLayer:CAShapeLayer?{
        get{
            if _backgroundRingLayer != nil{
                return _backgroundRingLayer
            }
            let center = CGPoint(x: hudView!.frame.width/2, y: hudView!.frame.height/2)
            let radius:CGFloat = progressView!.radius
            let smoothedPath = UIBezierPath(arcCenter: CGPoint(x:radius,y:radius), radius: radius, startAngle: CGFloat(-Double.pi / 2), endAngle: CGFloat(Double.pi + Double.pi / 2), clockwise: true)
            _backgroundRingLayer = CAShapeLayer()
            _backgroundRingLayer?.contentsScale = UIScreen.main.scale
            _backgroundRingLayer?.frame = CGRect(x: center.x - radius, y: center.y - radius, width: radius*2, height: radius*2)
            _backgroundRingLayer?.fillColor = UIColor.clear.cgColor
            _backgroundRingLayer?.strokeColor = colorProgress.withAlphaComponent(0.4).cgColor
            _backgroundRingLayer?.lineWidth = progressView!.storeThickness
            _backgroundRingLayer?.lineCap = kCALineCapRound
            _backgroundRingLayer?.lineJoin = kCALineJoinBevel
            _backgroundRingLayer?.path = smoothedPath.cgPath
            _backgroundRingLayer?.strokeEnd = 1 // 100%
            hudView?.layer.addSublayer(_backgroundRingLayer!)
            return _backgroundRingLayer
        }
        set{
            _backgroundRingLayer = newValue
        }
    }
    var hudView:UIView?{
        get{
            if _hudView == nil{
                _hudView = UIView(frame: CGRect.zero)
                _hudView?.backgroundColor = colorForeground
                _hudView?.layer.cornerRadius = 14
                _hudView?.layer.masksToBounds = true
                _hudView?.layer.borderWidth = 0.5
                _hudView?.layer.borderColor = colorBackground!.cgColor
                // 固定四周边距,Margin
                _hudView?.autoresizingMask = [.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin,.flexibleLeftMargin]
                // xy 间隔
                let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
                effectX.minimumRelativeValue = 10
                effectX.maximumRelativeValue = 10
                let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
                effectY.minimumRelativeValue = 10
                effectY.maximumRelativeValue = 10
                let effectGroup = UIMotionEffectGroup()
                effectGroup.motionEffects = [effectX, effectY]
                _hudView?.addMotionEffect(effectGroup)
            }
            if _hudView?.superview == nil{
                addSubview(_hudView!)
            }
            return _hudView
        }
        set{
           _hudView = newValue
        }
    }
    var offsetFromCenter:UIOffset = UIOffset.zero
    //
    var _hudView:UIView?
    var _labelString:UILabel?
    var _imageView:UIImageView?
    var _overlayView:UIControl?
    var _ringLayer:CAShapeLayer?
    var _progressView:MyViewRingProgress?
    var _backgroundRingLayer:CAShapeLayer?
    //
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = UIColor.clear
        alpha = 0.0
        activityCount = 0
        colorBackground = UIColor(white: 0.3, alpha: 0.2)
        colorForeground = UIColor.white
        colorLabelText = UIColor.gray
        colorProgress = UIColor.gray
        fontText = UIFont.systemFont(ofSize: 14)
        let bundle = UtilBundle()
        imageInfo = bundle.imageInBundleXiaoTian("info")?.withRenderingMode(.alwaysTemplate)// 图片一直用渲染模式
        imageSuccess = bundle.imageInBundleXiaoTian("success")?.withRenderingMode(.alwaysTemplate)// 图片一直用渲染模式
        imageError = bundle.imageInBundleXiaoTian("error")?.withRenderingMode(.alwaysTemplate)// 图片一直用渲染模式
    }
    /// Static Class Method
    // 进度条
    public class func show(status:String? = nil, progress:CGFloat = PROGRESS_RING, maskType:Int = MASK_BLACK){
        shared.show(progress, status, maskType)
    }
    /// 如果是进度条,则更新进度
    public class func updateProgress(progress:CGFloat){
        if shared.progress > MyAlertViewProgress.PROGRESS_RING{
            UIView.animate(withDuration: 0.5, delay: 0.1, options: [.beginFromCurrentState,.curveLinear], animations: {
                shared.ringLayer?.strokeEnd = progress
            })
        }
    }
    /// 成功
    public class func showSuccess(status:String? = nil,maskType:Int = MASK_CLEAR,tintColor:UIColor = UIColor.green){
        var displayInterval:TimeInterval = 0.5
        if status != nil {
            displayInterval = Double.minimum(Double(status!.characters.count) * 0.06 + 0.5, 5.0)
        }
        shared.show(shared.tintColorImage(shared.imageSuccess, tintColor), status, displayInterval, maskType)
    }
    /// 失败
    public class func showError(status:String? = nil,maskType:Int = MASK_CLEAR,tintColor:UIColor = UIColor.red){
        var displayInterval:TimeInterval = 0.5
        if status != nil {
            displayInterval = Double.minimum(Double(status!.characters.count) * 0.06 + 0.5, 5.0)
        }
        shared.show(shared.tintColorImage(shared.imageError, tintColor), status, displayInterval, maskType)
    }
    /// 提示
    public class func showInfo(status:String? = nil,maskType:Int = MASK_CLEAR,tintColor:UIColor = UIColor.gray){
        var displayInterval:TimeInterval = 0.5
        if status != nil {
            displayInterval = Double.minimum(Double(status!.characters.count) * 0.06 + 0.5, 5.0)
        }
        shared.show(shared.tintColorImage(shared.imageInfo, tintColor), status, displayInterval, maskType)
    }
    /// 隐藏
    public class func hide(){
        if isVisible {
            MyAlertViewProgress.shared.hide()
        }
    }
    /// 已经显示
    public class var isVisible: Bool{
        return MyAlertViewProgress.shared.alpha == 1
    }
    /// Instanc Method
    public func show(_ progress:CGFloat,_ status:String?,_ maskType:Int){
        if self.fadeOutTimer != nil{
            self.fadeOutTimer?.invalidate()
            self.fadeOutTimer = nil
        }
        self.progress = progress
        self.maskType = maskType
        self.labelString?.text = status
        self.imageView?.isHidden = true
        if overlayView.superview == nil {
            // 添加到最上层的Window的View中
            let frontToBackWindows = UIApplication.shared.windows.reversed()
            for window in frontToBackWindows{
                let windowOnMainScreen = window.screen == UIScreen.main
                let windowIsVisible = !window.isHidden && window.alpha > 0
                let windowLevelNormal = window.windowLevel == UIWindowLevelNormal
                if windowOnMainScreen && windowIsVisible && windowLevelNormal{
                    window.addSubview(overlayView)
                    break
                }
            }
        }else{
            // 移到最上层
            overlayView.superview?.bringSubview(toFront: overlayView)
        }
        if superview == nil {
            overlayView.addSubview(self)
        }
        updatePosition()
        if progress != MyAlertViewProgress.PROGRESS_RING {
            self.imageView?.image = nil
            self.imageView?.isHidden = false
            self.progressView?.removeFromSuperview()
            self.ringLayer?.strokeEnd = progress // 0~1(1圈)
            if progress == 0{
                self.activityCount += 1
            }
        }else{
            self.activityCount += 1
            cancelRingLayerAnimation()
            hudView?.addSubview(progressView!)
        }
        overlayView.isHidden = false
        overlayView.backgroundColor = UIColor.clear
        if maskType == MyAlertViewProgress.MASK_NONE{
            overlayView.isUserInteractionEnabled = false
            hudView?.accessibilityLabel = status
            hudView?.isAccessibilityElement = true
        }else{
            // Set UIControl Title
            overlayView.isUserInteractionEnabled = true
            accessibilityLabel = status
            isAccessibilityElement = true
        }
        notifyPositionHUD(nil)
        if alpha != 1 || hudView!.alpha != 1{
            // 第一次显示
            if let text = labelString?.text{
                UtilNotificationDefaultCenter.postNotificationName(MyAlertViewProgress.TAG_WILL_APPEAR, [MyAlertViewProgress.KEY_USER_INFO:text])
            }else{
                UtilNotificationDefaultCenter.postNotificationName(MyAlertViewProgress.TAG_WILL_APPEAR, nil)
            }
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIApplicationDidChangeStatusBarOrientation)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardWillHide)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardDidHide)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardWillShow)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardDidShow)
            hudView!.transform = hudView!.transform.scaledBy(x: 1.3, y: 1.3)
            if isClear(){
                alpha = 1
                hudView?.alpha = 0
            }
            UIView.animate(withDuration: 0.15,delay:0,options:[.allowUserInteraction,.curveEaseOut,.beginFromCurrentState], animations: { [weak self] in
                guard let wSelf = self else{
                    return
                }
                wSelf.hudView!.transform = wSelf.hudView!.transform.scaledBy(x: 1/1.3, y: 1/1.3)
                if wSelf.isClear(){ // handle iOS 7 and 8 UIToolbar which not answers well to hierarchy opacity change
                    wSelf.hudView?.alpha = 1
                }else{
                    wSelf.alpha = 1
                }
            }, completion: { [weak self](finished) in
                if let text = self?.labelString?.text{
                    UtilNotificationDefaultCenter.postNotificationName(MyAlertViewProgress.TAG_WILL_APPEAR, [MyAlertViewProgress.KEY_USER_INFO:text])
                }else{
                    UtilNotificationDefaultCenter.postNotificationName(MyAlertViewProgress.TAG_WILL_APPEAR, nil)
                }
                UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil)
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, status)
            })
        }
        // Draw in rect
        setNeedsDisplay()
    }
    public func show(_ image: UIImage,_ status:String?,_ duration:TimeInterval,_ maskType:Int){
        self.progress = MyAlertViewProgress.PROGRESS_RING
        self.maskType = maskType
        self.labelString?.text = status
        self.imageView?.image = image
        self.imageView?.isHidden = false
        if overlayView.superview == nil {
            // 添加到最上层的Window的View中
            let frontToBackWindows = UIApplication.shared.windows.reversed()
            for window in frontToBackWindows{
                let windowOnMainScreen = window.screen == UIScreen.main
                let windowIsVisible = !window.isHidden && window.alpha > 0
                let windowLevelNormal = window.windowLevel == UIWindowLevelNormal
                if windowOnMainScreen && windowIsVisible && windowLevelNormal{
                    window.addSubview(overlayView)
                    break
                }
            }
        }else{
            // 移到最上层
            overlayView.superview?.bringSubview(toFront: overlayView)
        }
        if superview == nil {
            overlayView.addSubview(self)
        }
        updatePosition()
        progressView?.removeFromSuperview()
        overlayView.isHidden = false
        overlayView.backgroundColor = UIColor.clear
        cancelRingLayerAnimation()
        if maskType == MyAlertViewProgress.MASK_NONE{
            overlayView.isUserInteractionEnabled = false
            hudView?.accessibilityLabel = status
            hudView?.isAccessibilityElement = true
        }else{
            // Set UIControl Title
            overlayView.isUserInteractionEnabled = true
            accessibilityLabel = status
            isAccessibilityElement = true
        }
        notifyPositionHUD(nil)
        if alpha != 1 || hudView!.alpha != 1{
            // 第一次显示
            if let text = labelString?.text{
                UtilNotificationDefaultCenter.postNotificationName(MyAlertViewProgress.TAG_WILL_APPEAR, [MyAlertViewProgress.KEY_USER_INFO:text])
            }else{
                UtilNotificationDefaultCenter.postNotificationName(MyAlertViewProgress.TAG_WILL_APPEAR, nil)
            }
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIApplicationDidChangeStatusBarOrientation)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardWillHide)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardDidHide)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardWillShow)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardDidShow)
            hudView!.transform = hudView!.transform.scaledBy(x: 1.3, y: 1.3)
            if isClear(){
                alpha = 1
                hudView?.alpha = 0
            }
            UIView.animate(withDuration: 0.15,delay:0,options:[.allowUserInteraction,.curveEaseOut,.beginFromCurrentState], animations: { [weak self] in
                guard let wSelf = self else{
                    return
                }
                wSelf.hudView!.transform = wSelf.hudView!.transform.scaledBy(x: 1/1.3, y: 1/1.3)
                if wSelf.isClear(){ // handle iOS 7 and 8 UIToolbar which not answers well to hierarchy opacity change
                    wSelf.hudView?.alpha = 1
                }else{
                    wSelf.alpha = 1
                }
                }, completion: { [weak self](finished) in
                    if let text = self?.labelString?.text{
                        UtilNotificationDefaultCenter.postNotificationName(MyAlertViewProgress.TAG_WILL_APPEAR, [MyAlertViewProgress.KEY_USER_INFO:text])
                    }else{
                        UtilNotificationDefaultCenter.postNotificationName(MyAlertViewProgress.TAG_WILL_APPEAR, nil)
                    }
                    UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil)
                    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, status)
            })
        }
        // Draw in rect
        setNeedsDisplay()
        fadeOutTimer = Timer(timeInterval: duration, target: self, selector: #selector(hide), userInfo: nil, repeats: false)
        RunLoop.main.add(fadeOutTimer!, forMode: .commonModes)
    }
    @objc public func hide(){
        let  userInfo:[String:String]? = labelString!.text == nil ? [:] : [MyAlertViewProgress.KEY_USER_INFO: labelString!.text!]
        UtilNotificationDefaultCenter.postNotificationName(MyAlertViewProgress.TAG_WILL_DISAPPEAR, userInfo)
        activityCount = 0
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut,.allowUserInteraction], animations: {[weak self] in
            guard let wSelf = self else{
                return
            }
            wSelf.hudView?.transform = wSelf.hudView!.transform.scaledBy(x: 0.8, y: 0.8)
            if wSelf.isClear(){
                wSelf.hudView?.alpha = 0.0
            }else{
                wSelf.alpha = 0.0
            }
        }) { [weak self](finished) in
            guard let wSelf = self else{
                return
            }
            if(wSelf.alpha == 0.0 || wSelf.hudView?.alpha == 0.0){
                wSelf.alpha = 0.0
                wSelf.hudView?.alpha = 0.0
                NotificationCenter.default.removeObserver(wSelf)
                wSelf.cancelRingLayerAnimation()
                wSelf.hudView?.removeFromSuperview()
                wSelf.hudView = nil
                wSelf.overlayView.removeFromSuperview()
                wSelf.overlayView = nil
                wSelf.progressView?.removeFromSuperview()
                wSelf.progressView = nil
                UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil)
                NotificationCenter.default.post(name: NSNotification.Name(MyAlertViewProgress.TAG_DID_DISAPPEAR), object: nil, userInfo: userInfo)
                let rootController = UIApplication.shared.keyWindow?.rootViewController
                rootController?.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    @objc public func overlayViewDidReceiveTouchEvent(_ overlayView:UIControl,_ forEvent:UIEvent){
        NotificationCenter.default.post(name: NSNotification.Name(MyAlertViewProgress.TAG_TOUCH_EVENT), object: forEvent)
        if let touch = forEvent.allTouches?.first{
            let touchLocation = touch.location(in: self)
            if hudView!.frame.contains(touchLocation){
                NotificationCenter.default.post(name: NSNotification.Name(MyAlertViewProgress.TAG_TOUCH_EVENT_DOWN_INSIDE), object: forEvent)
            }
        }
    }
    public func updatePosition(){
        // Label,Progress
        var hubWidth:CGFloat = 80
        var hubHeight:CGFloat = 80
        let stringHeightBuffer:CGFloat = 20 //
        let stringAndContentHeightBuffer:CGFloat = 80 // 图标,Progress
        var stringWidth:CGFloat = 0
        var stringHeight:CGFloat = 0
        var labelRect = CGRect.zero
        let isUsedImage = imageView!.image != nil || imageView!.isHidden
        let isUsedProgress = progress > 0.0
        if labelString?.text != nil{
            labelString?.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
            labelString?.sizeToFit()
            let stringRect:CGRect = labelString!.frame
            stringWidth = ceil(stringRect.size.width)
            stringHeight = ceil(stringRect.size.height)
            if isUsedImage || isUsedProgress{
                hubHeight = stringAndContentHeightBuffer + stringHeight
            }else{
                hubHeight = stringHeightBuffer + stringHeight
            }
            if stringWidth > hubWidth{
                hubWidth = stringWidth
            }
            let labelRectY:CGFloat = (isUsedImage || isUsedProgress) ? 68 : 9
            if hubHeight > 100{
                labelRect = CGRect(x: 12.0, y: labelRectY, width: hubWidth, height: stringHeight)
                hubWidth += 24
            }else{
                hubWidth += 24
                labelRect = CGRect(x: 0.0, y: labelRectY, width: hubWidth, height: stringHeight)
            }
        }
        hudView?.bounds = CGRect(x: 0.0, y: 0.0, width: hubWidth, height: hubHeight)
        if labelString?.text != nil{
            imageView?.center = CGPoint(x: hudView!.bounds.width/2, y: 36)
        }else{
            imageView?.center = CGPoint(x: hudView!.bounds.width/2, y: hudView!.bounds.height/2)
        }
        labelString?.isHidden = false
        labelString?.frame = labelRect
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        if labelString?.text != nil{
            if let progressView = progressView{
                let size = progressView.calculateFrameSize()
                progressView.frame = CGRect(x: (hubWidth - size.width)/2, y: 36 - size.height/2, width: size.width, height: size.height)
            }
            if progress > -1{
                backgroundRingLayer?.position = CGPoint(x: hubWidth/2, y: 36)
                ringLayer?.position = CGPoint(x: hubWidth/2, y: 36)
            }
        }else{
            if let progressView = progressView{
                let size = progressView.calculateFrameSize()
                progressView.frame = CGRect(x: (hubWidth - size.width)/2, y: (hubHeight - size.height)/2, width: size.width, height: size.height)
            }
            if (progress > -1){
                backgroundRingLayer?.position = CGPoint(x:hubWidth/2, y:hubHeight/2)
                ringLayer?.position = CGPoint(x:hubWidth/2, y:hubHeight/2)
            }
        }
        CATransaction.commit()
    }
    public func cancelRingLayerAnimation(){
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        hudView?.layer.removeAllAnimations()
        ringLayer?.strokeEnd = 0
        if ringLayer?.superlayer != nil{
            ringLayer?.removeFromSuperlayer()
        }
        ringLayer = nil
        if backgroundRingLayer?.superlayer != nil{
            backgroundRingLayer?.removeFromSuperlayer()
        }
        backgroundRingLayer = nil
        CATransaction.commit()
    }
    @objc public func notifyPositionHUD(_ notification: NSNotification?){ // 根据弹出键盘状态重新计算弹框的位置或旋转
        var keyboardHeight:CGFloat = 0.0
        var animationDuration:TimeInterval? = 0.0
        let screamOrientation = UIApplication.shared.statusBarOrientation
        var ignoreOrientation = false // 8.0+竖横height,width不变
        if #available(iOS 8.0, *){
            ignoreOrientation = true
        }
        frame = UIScreen.main.bounds
        if notification != nil{
            Mylog.log(notification?.name)
            if let userInfo = notification?.userInfo{
                let keyboardFrame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect
                animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval
                if notification!.name == Notification.Name.UIKeyboardWillShow || notification!.name == Notification.Name.UIKeyboardDidShow{
                    if ignoreOrientation || screamOrientation.isPortrait {
                        keyboardHeight = keyboardFrame!.height
                    }else{
                        keyboardHeight = keyboardFrame!.width
                    }
                }
            }
        }else{
            keyboardHeight = visibleKeyboardHeight()
        }
        var orientationFrame = bounds
        var statusBarFrame = UIApplication.shared.statusBarFrame
        if !ignoreOrientation && screamOrientation.isLandscape {
            var temp = orientationFrame.width
            orientationFrame.size.width = orientationFrame.height
            orientationFrame.size.height = temp
            temp = statusBarFrame.width
            statusBarFrame.size.width = statusBarFrame.height
            statusBarFrame.size.height = temp
        }
        var activeHeight = orientationFrame.height
        if keyboardHeight > 0 {
            activeHeight += statusBarFrame.height * 2
        }
        activeHeight -= keyboardHeight
        let posY = floor(activeHeight * 0.45)
        let posX = orientationFrame.width / 2
        var newCenter:CGPoint!
        var rotateAngle:Double!
        if ignoreOrientation{
            rotateAngle = 0
            newCenter = CGPoint(x:posX,y:posY)
        }else{
            switch screamOrientation {
            case .portraitUpsideDown:
                rotateAngle = Double.pi
                newCenter = CGPoint(x: posX, y: orientationFrame.height - posY)
                break
            case .landscapeLeft:
                rotateAngle = -Double.pi / 2.0
                newCenter = CGPoint(x: posY, y: posX)
                break
            case .landscapeRight:
                rotateAngle = Double.pi / 2.0
                newCenter = CGPoint(x: orientationFrame.height - posY, y: posX)
                break
            default:
                rotateAngle = 0.0
                newCenter = CGPoint(x: posX, y: posY)
                break
            }
        }
        func moveToPoint(_ newCenter:CGPoint,_ rotateAngle: Double){
            hudView?.transform = CGAffineTransform(rotationAngle: CGFloat(rotateAngle))
            hudView?.center = CGPoint(x: newCenter.x + offsetFromCenter.horizontal, y: newCenter.y + offsetFromCenter.vertical)
        }
        if notification != nil{
            if let duration = animationDuration{
                UIView.animate(withDuration: duration, delay: 0.0, options: .allowUserInteraction, animations: {[weak self] in
                    guard let wSelf = self else{
                        return
                    }
                    moveToPoint(newCenter,rotateAngle)
                    wSelf.hudView?.setNeedsDisplay()
                })
            }
        }else{
            moveToPoint(newCenter,rotateAngle)
            hudView?.setNeedsDisplay()
        }
    }
    func visibleKeyboardHeight() -> CGFloat{
        var keyboardWindow: UIWindow? = nil
        // 当前所有窗口,获取可能是键盘的Window
        for window in UIApplication.shared.windows{
            // 不是UIWindow的类[键盘输入是它的子类]
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
                        continue
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
    open override func draw(_ rect: CGRect) {
        switch maskType {
        case MyAlertViewProgress.MASK_BLACK:
            let context = UIGraphicsGetCurrentContext()
            if let colors = colorBackground?.cgColor{
                context?.setFillColor(colors)
                context?.fill(bounds)
            }
            break;
        case MyAlertViewProgress.MASK_GRADIENT:
            let context = UIGraphicsGetCurrentContext()
            let location = UnsafeMutablePointer<CGFloat>.allocate(capacity: 2)
            location[0] = CGFloat(0.0)
            location[1] = CGFloat(1.0)
            let colors = UnsafeMutablePointer<CGFloat>.allocate(capacity: 8)
            colors[0] = CGFloat(0.0)
            colors[1] = CGFloat(0.0)
            colors[2] = CGFloat(0.0)
            colors[3] = CGFloat(0.0)
            colors[4] = CGFloat(0.0)
            colors[5] = CGFloat(0.0)
            colors[6] = CGFloat(0.0)
            colors[7] = CGFloat(0.75)
            let gradient = CGGradient(colorSpace: CGColorSpaceCreateDeviceRGB(), colorComponents: colors, locations: location, count: 2)
            let freeHeight:CGFloat = bounds.height - visibleKeyboardHeight()
            let center = CGPoint(x:bounds.width/2, y:freeHeight)
            let radius = CGFloat.minimum(bounds.width, bounds.height)
            context?.drawRadialGradient(gradient!, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: .drawsAfterEndLocation)
            break
        default:
            break
        }
    }
    private func tintColorImage(_ image:UIImage,_ tintColor:UIColor) -> UIImage!{
        let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        image.draw(in: rect)
        context?.setFillColor(tintColor.cgColor)
        context?.setBlendMode(.sourceAtop)
        context?.fill(rect)
        let tintImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintImage
    }
    func isClear() -> Bool{
        return maskType == MyAlertViewProgress.MASK_BLACK || maskType == MyAlertViewProgress.MASK_NONE
    }
}
