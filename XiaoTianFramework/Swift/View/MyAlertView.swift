//
//  MyAlertView.swift
//  Vegetables
//  无内容弹框(进入动画)
//  Created by guotianrui on 2017/10/11.
//  Copyright © 2017年 hexinglong. All rights reserved.
//

import UIKit
import Foundation

/// Alert View
open class MyAlertView: UIViewController{
    var viewColor: UIColor = UIColor()
    var duration:TimeInterval!
    var durationTimer:Timer!
    var dismissBlock:(() -> Void)?
    var contentViewColor = UIColor.white
    var keyboardHasBeenShown:Bool = false
    var hideWhenBackgroundViewIsTapped:Bool=true
    var kDefaultShadowOpacity:CGFloat = 0.3
    var contentViewCornerRadius:CGFloat = 10
    var contentViewBorderColor = UIColor.lightGray
    var tmpContentViewFrameOrigin:CGPoint?
    // UIViewController当前的引用,当前弹框只用到了VC里的View,所以当view显示完毕,VC实体会被系统回收,所以要引用VC保持绑定和通知接收
    var selfReference:MyAlertView?
    // UI
    var baseView = UIView()
    var contentView = UIView()
    
    // init
    public init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        viewWillLayoutSubviewsAlert()
    }
    // Customer Setup View
    open func setupView(){
        // main view
        view.frame = UIScreen.main.bounds
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: kDefaultShadowOpacity)
        view.addSubview(baseView)
        // base view
        baseView.frame = view.frame
        baseView.addSubview(contentView)
        // content view
        contentView.layer.cornerRadius = contentViewCornerRadius
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        // color
        contentView.backgroundColor = contentViewColor
        contentView.layer.borderColor = contentViewBorderColor.cgColor
        // tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapBackgroundView(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
    }
    // Customer Layer
    open func viewWillLayoutSubviewsAlert(){
        let rv = UIApplication.shared.keyWindow!
        let sz = rv.frame.size
        // background frame
        view.frame.size = sz
        contentView.frame = CGRect(x: 50, y: 50, width: sz.width-100, height: sz.height-100)
        contentView.layer.cornerRadius = contentViewCornerRadius
    }
    // 显示弹框
    @discardableResult
    open func show(duration:TimeInterval?, animation:Animation) -> Responder{
        selfReference = self
        view.alpha = 0
        let rv = UIApplication.shared.keyWindow!
        rv.addSubview(view)
        view.frame = rv.bounds
        baseView.frame = rv.bounds
        if duration ?? 0 > 0 {
            self.duration = duration
            durationTimer?.invalidate()
            durationTimer = Timer.scheduledTimer(timeInterval: self.duration, target: self, selector: #selector(hideView), userInfo: nil, repeats: false)
        }
        showAnimation(animation)
        return Responder(self)
    }
    // 背景点击事件
    @objc
    private func onTapBackgroundView(_ tapGesture:UITapGestureRecognizer){
        view.endEditing(true)
        if let tappedView = tapGesture.view , tappedView.hitTest(tapGesture.location(in: tappedView), with: nil) == baseView && hideWhenBackgroundViewIsTapped{
            hideView()
        }
    }
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if event?.touches(for: view)?.count ?? 0 > 0 {
            view.endEditing(true)
        }
    }
    @objc
    private func keyboardWillShow(_ notification:Notification){
        keyboardHasBeenShown = true
        guard let userInfo = notification.userInfo else{
            return
        }
        guard let endKeyBoardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.minY else{
            return
        }
        if tmpContentViewFrameOrigin == nil{
            tmpContentViewFrameOrigin = contentView.frame.origin
        }
        var newContentViewFrameY = self.contentView.frame.maxY - endKeyBoardFrame
        if newContentViewFrameY < 0{
            newContentViewFrameY = 0
        }
    }
    
    @objc
    func keyboardWillHide(_ notification:Notification){
        if keyboardHasBeenShown{
            if tmpContentViewFrameOrigin != nil{
                contentView.frame.origin.y = tmpContentViewFrameOrigin!.y
                tmpContentViewFrameOrigin = nil
            }
            keyboardHasBeenShown = false
        }
    }
    
    @objc
    open func hideView(){
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 0
        }) { (finished) in
            self.selfReference = nil
            self.durationTimer?.invalidate()
            self.dismissBlock?()
            self.view.removeFromSuperview()
        }
    }

    func showAnimation(_ animationType:Animation = .topToBottom, animationStartOffset:CGFloat = -400, boundingAnimationOffset:CGFloat = 15,animationDuration:TimeInterval = 0.2){
        //1. 设置当前View开始原点
        //2. 计算最终移动到的位置中点(移动中点的方法平移动态)
        let rv = UIApplication.shared.keyWindow!
        var animationStartOrigin = baseView.frame.origin
        var animationCenter:CGPoint = rv.center
        switch animationType {
        case .noAnimation:
            view.alpha = 1.0
            return
        case .topToBottom: // Top To Bottom In
            animationStartOrigin = CGPoint(x: animationStartOrigin.x, y: baseView.frame.origin.y + animationStartOffset)
            animationCenter = CGPoint(x: animationCenter.x, y: animationCenter.y + boundingAnimationOffset)
        case .bottomToTop:
            animationStartOrigin = CGPoint(x: animationStartOrigin.x, y: baseView.frame.origin.y - animationStartOffset)
            animationCenter = CGPoint(x: animationCenter.x, y: animationCenter.y - boundingAnimationOffset)
        case .leftToRight:
            animationStartOrigin = CGPoint(x: baseView.frame.origin.x + animationStartOffset, y: animationStartOrigin.y)
            animationCenter = CGPoint(x: animationCenter.x + boundingAnimationOffset, y: animationCenter.y)
        case .rightToLeft:
            animationStartOrigin = CGPoint(x: baseView.frame.origin.x - animationStartOffset, y: animationStartOrigin.y)
            animationCenter = CGPoint(x: animationCenter.x - boundingAnimationOffset, y: animationCenter.y)
        }
        baseView.frame.origin = animationStartOrigin
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.alpha = 1.0
            self.baseView.center = animationCenter
        }) { (finished) in
            UIView.animate(withDuration: animationDuration, animations: {
                self.view.alpha = 1.0
                self.baseView.center = rv.center
            })
        }
    }
    
    public enum Animation{
        case noAnimation,topToBottom,bottomToTop,leftToRight,rightToLeft
    }
    
    open class Responder{
        var alert: MyAlertView
        
        fileprivate init(_ alert: MyAlertView) {
            self.alert = alert
        }
        open func hide(){
            self.alert.hideView()
        }
        open func setDismissBlock(_ dismissBlock:@escaping () -> Void){
            self.alert.dismissBlock = dismissBlock
        }
    }
}

