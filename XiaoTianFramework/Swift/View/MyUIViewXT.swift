//
//  MyUIView.swift
//  DriftBook
//
//  Created by 郭天蕊 on 2016/11/2.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
@objc(MyUIViewXT)
public class MyUIViewXT: UIView{
    var tabFunction:((_ view:MyUIViewXT)->())?
    
    // IB 点击事件绑定,eg: onClickAction[无参数], onClickAction:[包含一个参数UIView],也可以通过KVC模式设置
    @IBInspectable public var onClickAction: String = ""
    //
    public required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        clickableInit()
    }
    public override init(frame: CGRect){
        super.init(frame: frame)
        clickableInit()
    }
    public override func awakeFromNib() {
        if onClickAction == "" {
            return
        }
        // 获取当前 Responder 链中包含该Selector的第一个Responder
        if let responder: AnyObject? = self.target(forAction: Selector(onClickAction), withSender: self) as AnyObject {
            setOnTabListener() {
                [weak self, responder] params in
                guard let wSelf = self else {
                    return
                }
                guard let wResponder = responder else {
                    return
                }
                // 执行绑定的 OnClickAction [最多传递一个参数]
                wResponder.perform(Selector(wSelf.onClickAction), with: wSelf)
            }
        }
        
    }
    // Clickable
    func setClickable(_ clickable:Bool?){
        if clickable == nil{
            return
        }
        clickableExt = clickable!
    }
    // Tab 事件
    func onTabAction(){
        if tabFunction != nil{
            tabFunction!(self)
        }
    }
    // 设置Tab 事件侦听器
    func setOnTabListener(_ onTabListener:@escaping (_ view:MyUIViewXT)->()){
        clickableExt = true
        self.tabFunction = onTabListener
    }
    // 设置Tabed的背景色
    func setTabedBackground(_ color:UIColor){
        backgroundViewExt.backgroundColor = color
    }
    // Touch Event Listener
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        clickableTouchesBegan(touches, withEvent: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        clickableTouchesEnded(touches, withEvent: event)
        onTabAction()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?){
        clickableTouchesCancelled(touches, withEvent: event)
    }
    
}
// ## Extension UIView Clickable
private var tabDataAssociationKey: UInt8 = 0
private var tabFunctionAssociationKey: UInt8 = 0
private var clickableAssociationKey: UInt8 = 0
private var backgroundViewAssociationKey: UInt8 = 0
private extension MyUIViewXT {
    var tabDateExt : TimeInterval {
        get {
            var value = objc_getAssociatedObject(self, &tabDataAssociationKey)
            if value == nil{
                value = Date().timeIntervalSince1970
            }
            return value as! TimeInterval
        }
        set (newValue) {
            objc_setAssociatedObject(self, &tabDataAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    var clickableExt: Bool {
        get {
            let value = objc_getAssociatedObject(self, &clickableAssociationKey)
            return value == nil ? false : value as! Bool
        }
        set (newValue) {
            objc_setAssociatedObject(self, &clickableAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    var backgroundViewExt: UIView! {
        get {
            return objc_getAssociatedObject(self, &backgroundViewAssociationKey) as? UIView
        }
        set (newValue) {
            objc_setAssociatedObject(self, &backgroundViewAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        
    }
    
    // #ClickAble Method
    func clickableInit() {
        isUserInteractionEnabled = true //开启用户交互事件
        if backgroundViewExt == nil{
            backgroundViewExt = UIView(frame: self.bounds)
            backgroundViewExt.alpha = 0.3
            backgroundViewExt.isHidden = true
            backgroundViewExt.backgroundColor = UIColor.gray
            self.insertSubview(backgroundViewExt, at: 0)
        }
    }
    func clickableTouchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !clickableExt {
            return
        }
        if Date().timeIntervalSince1970 - tabDateExt < 0.1 {
            // 点击太快(小于0.1s,背景还没显示),延时隐藏背景,等待背景显示
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                self.backgroundViewExt.isHidden = true
            })
        } else {
            // 点击正常
            backgroundViewExt.isHidden = true
        }
    }
    func clickableTouchesCancelled(_ touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if !clickableExt {
            return
        }
        if Date().timeIntervalSince1970 - tabDateExt < 0.2 {
            // 点击太快(小于0.1s,背景还没显示),延时隐藏背景,等待背景显示
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                self.backgroundViewExt.isHidden = true
            })
        } else {
            // 点击正常
            backgroundViewExt.isHidden = true
        }
        
    }
    func clickableTouchesBegan(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !clickableExt {
            return
        }
        tabDateExt = Date().timeIntervalSince1970
        backgroundViewExt.frame = self.bounds
        backgroundViewExt.isHidden = false
    }
}
