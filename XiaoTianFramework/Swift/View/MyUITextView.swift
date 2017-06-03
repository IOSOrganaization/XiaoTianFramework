//
//  MyUITextView.swift
//  DriftBook
//
//  Created by XiaoTian on 2016/11/10.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
import UIKit

class MyUITextView: UITextView{
    var tabFunction:((_ view:MyUITextView)->())?
    
    // IB 点击事件绑定,eg: onClickAction[无参数], onClickAction:[包含一个参数UIView]
    @IBInspectable var onClickAction: String = ""
    //
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        clickableInit()
    }
    override init(frame: CGRect, textContainer: NSTextContainer?){
        super.init(frame: frame, textContainer:textContainer)
        clickableInit()
    }
    override func awakeFromNib() {
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
    func setOnTabListener(_ onTabListener:@escaping (_ view:MyUITextView)->()){
        clickableExt = true
        self.tabFunction = onTabListener
    }
    // 设置Tabed的背景色
    func setTabedBackground(_ color:UIColor){
        backgroundViewExt.backgroundColor = color
    }
    // Touch Event Listener
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        clickableTouchesBegan(touches, withEvent: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        clickableTouchesEnded(touches, withEvent: event)
        onTabAction()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?){
        clickableTouchesCancelled(touches, withEvent: event)
    }
    // # PlaceHolder
    var placeHolder: String!{
        didSet{
            if placeHolder == oldValue{
                return
            }
            // 超出后面用...省略
            let maxChars = UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone ? 33 : 109 //iPhone,iPad
            if placeHolder.characters.count > maxChars{
                placeHolder = placeHolder.substring(to: placeHolder.index(placeHolder.startIndex, offsetBy: maxChars - 8))
                placeHolder = placeHolder.trimmingCharacters(in: CharacterSet.whitespaces) + "..."
            }
            setNeedsDisplay()
        }
    }
    var placeHolderTextColor: UIColor!{
        didSet{
            if placeHolderTextColor == oldValue{
                return
            }
            setNeedsDisplay()
        }
    }
    var numberOfLinesOfText:Int!{
        return numberOfLinesForMessage(text)
    }
    var maxCharactersPerLine:Int!{
        get{
            return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone ? 33 : 109
        }
    }
    func numberOfLinesForMessage(_ text:String)-> Int{
            return text.characters.count / maxCharactersPerLine + 1
    }
    // # overrides
    
}
// ## Extension UIView Clickable
private var tabDataAssociationKey: UInt8 = 0
private var tabFunctionAssociationKey: UInt8 = 0
private var clickableAssociationKey: UInt8 = 0
private var backgroundViewAssociationKey: UInt8 = 0
private extension MyUITextView {
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
        if backgroundViewExt == nil {
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
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
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
            let delay = 0.1 * Double(NSEC_PER_SEC)
            let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: {
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
