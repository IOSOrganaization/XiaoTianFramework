//
//  MyViewProgressAlert.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/6/24.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
open class MyViewProgressAlert: UIView{
    public static let TAG_WILL_APPEAR = "MyViewProgressAlert.TAG_WILL_APPEAR"
    public static let KEY_USER_INFO = "MyViewProgressAlert.KEY_USER_INFO"
    // 单例
    static let shared:MyViewProgressAlert = {
        return MyViewProgressAlert(frame: UIScreen.main.bounds) // 全屏
    }()
    var maskType:String = "None" //None,Clear,Black,Gradient
    var activityCount: Int = 0
    var colorBackground,colorForeground,colorImageRendering:UIColor?
    var fontText:UIFont?
    var imageInfo, imageSuccess, imageError:UIImage?
    var overlayView: UIControl = {
        let view = UIControl(frame: UIScreen.main.bounds)
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.clear
        view.addTarget(self, action: #selector(overlayViewDidReceiveTouchEvent(_:_:)), for: .touchDown)
        return view
    }()
    var fadeOutTimer: Timer?
    var imageView: UIImageView?
    var progress:CGFloat = 0.0
    var labelString:UILabel?
    var progressView:MyViewRingProgress?
    var ringLayer:CAShapeLayer?
    var backgroundRingLayer:CAShapeLayer?
    var hubView:UIView?
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
        colorBackground = UIColor.white
        colorForeground = UIColor.black
        colorImageRendering = UIColor.gray
        fontText = UIFont.preferredFont(forTextStyle: .subheadline)
        if let image = UtilBundle.imageInBundleXiaoTian("info"){
            imageInfo = image.withRenderingMode(.alwaysTemplate) // 图片一直用渲染模式
        }
        if let image = UtilBundle.imageInBundleXiaoTian("success"){
            imageSuccess = image.withRenderingMode(.alwaysTemplate)
        }
        if let image = UtilBundle.imageInBundleXiaoTian("error"){
            imageError = image.withRenderingMode(.alwaysTemplate)
        }
    }
    
    public class func show(){
        shared.show(-1, nil, shared.maskType)
    }
    public func show(_ progress:CGFloat,_ status:String?,_ maskType:String){
        self.fadeOutTimer = nil
        self.imageView?.isHidden = true
        self.progress = progress
        self.maskType = maskType
        self.labelString?.text = status
        if overlayView.superview == nil{
            // 添加到最上层的Window
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
            overlayView.superview?.bringSubview(toFront: self.overlayView)
        }
        if superview == nil{
            overlayView.addSubview(self)
        }
        updatePosition()
        if progress >= 0{
            self.imageView?.image = nil
            self.imageView?.isHidden = false
            self.progressView?.removeFromSuperview()
            self.ringLayer?.strokeEnd = progress
            if progress == 0{
                self.activityCount += 1
            }
        }else{
            self.activityCount += 1
            cancelRingLayerAnimation()
            if let progressView = progressView{
                hubView?.addSubview(progressView)
            }
        }
        if maskType != "None"{
            // Set UIControl Title
            overlayView.isUserInteractionEnabled = true
            accessibilityLabel = status
            isAccessibilityElement = true
        }else{
            overlayView.isUserInteractionEnabled = false
            hubView?.accessibilityLabel = status
            hubView?.isAccessibilityElement = true
        }
        overlayView.isHidden = false
        overlayView.backgroundColor = UIColor.clear
        notifyPositionHUD(nil)
        if alpha != 1 || self.hubView!.alpha != 1{
            UtilNotificationDefaultCenter.postNotificationName(MyViewProgressAlert.TAG_WILL_APPEAR, getUserInfo())
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIApplicationDidChangeStatusBarOrientation)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardWillHide)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardDidHide)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardWillShow)
            UtilNotificationDefaultCenter.addObserver(self, #selector(notifyPositionHUD(_:)), NSNotification.Name.UIKeyboardDidShow)
            hubView!.transform = hubView!.transform.scaledBy(x: 1.3, y: 1.3)
            if isClear(){
                alpha = 1
                hubView?.alpha = 0
            }
            UIView.animate(withDuration: 0.15,delay:0,options:[.allowUserInteraction,.curveEaseOut,.beginFromCurrentState], animations: { [weak self] in
                if let hubView = self?.hubView{
                    hubView.transform = hubView.transform.scaledBy(x: 1/1.3, y: 1/1.3)
                }
                if let isClear = self?.isClear(){
                    if isClear{
                        self?.hubView?.alpha = 1
                    }else{
                        self?.alpha = 1
                    }
                }
            }, completion: { [weak self](finished) in
                UtilNotificationDefaultCenter.postNotificationName(MyViewProgressAlert.TAG_WILL_APPEAR, self?.getUserInfo())
                UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil)
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, status)
            })
            self.setNeedsDisplay()
        }
    }
    public class func hide(){
        
    }
    public func overlayViewDidReceiveTouchEvent(_ overlayView:UIControl,_ forEvent:UIControlEvents){
    
    }
    public func updatePosition(){
        var hubWidth:CGFloat = 100
        var hubHeight:CGFloat = 100
        var stringHeightBuffer:CGFloat = 20
        var stringAndContentHeightBuffer:CGFloat = 80
        var stringWidth:CGFloat = 0
        var stringHeight:CGFloat = 0
        var labelRect = CGRect.zero
        let string = labelString?.text
        let isUsedImage = imageView!.image != nil || imageView!.isHidden
        let isUsedProgress = progress > 0.0
        if let string = string as NSString?{
            let constraintSize = CGSize(width: 200, height: 200)
            let stringRect:CGRect = string.boundingRect(with: constraintSize, options: [.truncatesLastVisibleLine,.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSFontAttributeName:labelString!.font], context: nil)
            stringWidth = stringRect.size.width
            stringHeight = ceil(stringRect.size.height)
            if isUsedImage || isUsedProgress{
                hubHeight = stringAndContentHeightBuffer + stringHeight
            }else{
                hubHeight = stringHeightBuffer + stringHeight
            }
            if stringWidth > hubHeight{
                hubWidth = ceil(stringWidth / 2) * 2
            }
            let labelRectY:CGFloat = (isUsedImage || isUsedProgress) ? 68.0 : 9.0
            if hubHeight > 100{
                labelRect = CGRect(x: 12.0, y: labelRectY, width: hubWidth, height: stringHeight)
                hubWidth += 24
            }else{
                hubWidth += 24
                labelRect = CGRect(x: 0.0, y: labelRectY, width: hubWidth, height: stringHeight)
            }
        }
        hubView?.bounds = CGRect(x: 0.0, y: 0.0, width: hubWidth, height: hubHeight)
        if string != nil{
            imageView?.center = CGPoint(x: hubView!.bounds.width/2, y: 36.0)
        }else{
            imageView?.center = CGPoint(x: hubView!.bounds.width/2, y: hubView!.bounds.height/2)
        }
        labelString?.isHidden = false
        labelString?.frame = labelRect
        let transition = CATransition()
        transition.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        if string != nil{
            let center = CGPoint(x: hubView!.bounds.width/2, y: 36)
            progressView?.center = center
            if progress > -1{
                backgroundRingLayer?.position = CGPoint(x: hubView!.bounds.width/2, y: 36)
                ringLayer?.position = CGPoint(x: hubView!.bounds.width/2, y: 36)
            }
        }else{
            let center = CGPoint(x: hubView!.bounds.width/2, y: hubView!.bounds.height/2)
            progressView?.center = center
            if (progress > -1){
                
            }
        }
    }
    public func cancelRingLayerAnimation(){
        
    }
    public func notifyPositionHUD(_ notification: NSNotification?){
        
    }
    func getUserInfo() -> [String: Any]?{
        if let text = labelString?.text{
            return [MyViewProgressAlert.KEY_USER_INFO:text]
        }
        return nil
    }
    func isClear() -> Bool{
        return maskType == "Clear" || maskType == "None"
    }
}
