//
//  ClickableUIView.swift
//  DriftBook
//  可以点击的 View 集合
//  Created by XiaoTian on 16/7/10.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
// 可点击的 UIView
@IBDesignable
class MyClickableUIView: UIView{
    var tabFunction:((view:MyClickableUIView)->())?
    
    // IB 点击事件绑定,eg: onClickAction[无参数], onClickAction:[包含一个参数UIView]
    @IBInspectable var onClickAction: String = ""
    //
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        clickableInit()
    }
    override init(frame: CGRect){
        super.init(frame: frame)
        clickableInit()
    }
    override func awakeFromNib() {
        if onClickAction == "" {
            return
        }
        // 获取当前 Responder 链中包含该Selector的第一个Responder
        if let responder: AnyObject? = self.targetForAction(Selector(onClickAction), withSender: self) {
            setOnTabListener() {
                [weak self, responder] params in
                guard let wSelf = self else {
                    return
                }
                guard let wResponder = responder else {
                    return
                }
                // 执行绑定的 OnClickAction [最多传递一个参数]
                wResponder.performSelector(Selector(wSelf.onClickAction), withObject: wSelf)
            }
        }
    }
    // Clickable
    func setClickable(clickable:Bool?){
        if clickable == nil{
            return
        }
        clickableExt = clickable!
    }
    // Tab 事件
    func onTabAction(){
        if tabFunction != nil{
            tabFunction!(view:self)
        }
    }
    // 设置Tab 事件侦听器
    func setOnTabListener(onTabListener:(view:MyClickableUIView)->()){
        clickableExt = true
        self.tabFunction = onTabListener
    }
    // 设置Tabed的背景色
    func setTabedBackground(color:UIColor){
        backgroundViewExt.backgroundColor = color
    }
    // Touch Event Listener
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        clickableTouchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        clickableTouchesEnded(touches, withEvent: event)
        onTabAction()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?){
        clickableTouchesCancelled(touches, withEvent: event)
    }
    
}
// 可点击的 UILabel
@IBDesignable
class MyClickableUILabel: UILabel{
    var tabFunction:((view:MyClickableUILabel)->())?
    @IBInspectable var onClickAction: String = ""
    //
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        clickableInit()
    }
    override init(frame: CGRect){
        super.init(frame: frame)
        clickableInit()
    }
    override func awakeFromNib() {
        if onClickAction == "" {
            return
        }
        if let responder: AnyObject? = self.targetForAction(Selector(onClickAction), withSender: self) {
            setOnTabListener() {
                [weak self, responder] params in
                guard let wSelf = self else {
                    return
                }
                guard let wResponder = responder else {
                    return
                }
                wResponder.performSelector(Selector(wSelf.onClickAction), withObject: wSelf)
            }
        }
    }
    // Clickable
    func setClickable(clickable:Bool?){
        if clickable == nil{
            return
        }
        clickableExt = clickable!
    }
    // Tab 事件
    func onTabAction(){
        if tabFunction != nil{
            tabFunction!(view:self)
        }
    }
    // 设置Tab 事件侦听器
    func setOnTabListener(onTabListener:(view:MyClickableUILabel)->()){
        clickableExt = true
        self.tabFunction = onTabListener
    }
    // 设置Tabed的背景色
    func setTabedBackground(color:UIColor){
        backgroundViewExt.backgroundColor = color
    }
    // Touch Event Listener
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        clickableTouchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        clickableTouchesEnded(touches, withEvent: event)
        onTabAction()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?){
        clickableTouchesCancelled(touches, withEvent: event)
    }
}
// 可点击的 UIImageView
@IBDesignable
class MyUIImageView: UIImageView{
    var tabFunction:((view:UIView)->())?
    //
    @IBInspectable var onClickAction: String = ""
    @IBInspectable var onClickColor: UIColor = UIColor(colorLiteralRed: 208/255.0, green: 208/255.0, blue: 208/255.0, alpha: 1)
    //
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        clickableInit()
    }
    override init(frame: CGRect){
        super.init(frame: frame)
        clickableInit()
    }
    override func awakeFromNib() {
        if onClickAction == "" {
            return
        }
        if let responder: AnyObject? = self.targetForAction(Selector(onClickAction), withSender: self) {
            setTabedBackground(onClickColor)
            setOnTabListener() {
                [weak self, responder] params in
                guard let wSelf = self else {
                    return
                }
                guard let wResponder = responder else {
                    return
                }
                wResponder.performSelector(Selector(wSelf.onClickAction), withObject: wSelf)
            }
        }
    }
    // Clickable
    func setClickable(clickable:Bool?){
        if clickable == nil{
            return
        }
        clickableExt = clickable!
    }
    // Tab 事件
    func onTabAction(){
        if tabFunction != nil{
            tabFunction!(view:self)
        }
    }
    // 设置Tab 事件侦听器
    func setOnTabListener(onTabListener:(view:UIView)->()){
        clickableExt = true
        self.tabFunction = onTabListener
    }
    // 设置Tabed的背景色
    func setTabedBackground(color:UIColor){
        backgroundViewExt.backgroundColor = color
    }
    // Touch Event Listener
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        clickableTouchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?){
        clickableTouchesEnded(touches, withEvent: event)
        onTabAction()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?){
        clickableTouchesCancelled(touches, withEvent: event)
    }
}

// ## Extension UIView Clickable
private var tabDataAssociationKey: UInt8 = 0
private var tabFunctionAssociationKey: UInt8 = 0
private var clickableAssociationKey: UInt8 = 0
private var backgroundViewAssociationKey: UInt8 = 0
private extension UIView {
    private var tabDateExt : NSTimeInterval {
        get {
            var value = objc_getAssociatedObject(self, &tabDataAssociationKey)
            if value == nil{
                value = NSDate().timeIntervalSince1970
            }
            return value as! NSTimeInterval
        }
        set (newValue) {
            objc_setAssociatedObject(self, &tabDataAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    private var clickableExt: Bool {
        get {
            let value = objc_getAssociatedObject(self, &clickableAssociationKey)
            return value == nil ? false : value as! Bool
        }
        set (newValue) {
            objc_setAssociatedObject(self, &clickableAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    private var backgroundViewExt: UIView! {
        get {
            return objc_getAssociatedObject(self, &backgroundViewAssociationKey) as? UIView
        }
        set (newValue) {
            objc_setAssociatedObject(self, &backgroundViewAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        
    }
    
    // #ClickAble Method
    private func clickableInit() {
        userInteractionEnabled = true //开启用户交互事件
        if backgroundViewExt == nil{
            backgroundViewExt = UIView(frame: self.bounds)
            backgroundViewExt.alpha = 0.3
            backgroundViewExt.hidden = true
            backgroundViewExt.backgroundColor = UIColor.grayColor()
            self.insertSubview(backgroundViewExt, atIndex: 0)
        }
    }
    private func clickableTouchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !clickableExt {
            return
        }
        if NSDate().timeIntervalSince1970 - tabDateExt < 0.1 {
            // 点击太快(小于0.1s,背景还没显示),延时隐藏背景,等待背景显示
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                self.backgroundViewExt.hidden = true
            })
        } else {
            // 点击正常
            backgroundViewExt.hidden = true
        }
    }
    private func clickableTouchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if !clickableExt {
            return
        }
        if NSDate().timeIntervalSince1970 - tabDateExt < 0.2 {
            // 点击太快(小于0.1s,背景还没显示),延时隐藏背景,等待背景显示
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
            dispatch_after(time, dispatch_get_main_queue(), {
                self.backgroundViewExt.hidden = true
            })
        } else {
            // 点击正常
            backgroundViewExt.hidden = true
        }
        
    }
    private func clickableTouchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !clickableExt {
            return
        }
        tabDateExt = NSDate().timeIntervalSince1970
        backgroundViewExt.frame = self.bounds
        backgroundViewExt.hidden = false
    }
}