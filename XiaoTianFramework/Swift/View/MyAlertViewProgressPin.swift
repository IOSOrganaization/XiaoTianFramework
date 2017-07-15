//
//  MyAlertViewProgressPin.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/7/15.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
public struct MyAlertViewProgressPin{
    private static let window: Window = Window()
    fileprivate(set) var content:Content
    fileprivate var hudView: HudView?
    
    public init(_ mode:Mode){
        self.content = Content(mode)
    }
    public static func show(_ content:Content){
        self.window.show(content)
    }
    public static func updateProgress(_ percentage: CGFloat){
        self.window.updateProgress(percentage)
    }
    public static func dismiss(_ duration:TimeInterval,_ delay:TimeInterval,_ text:String? = nil,_ completion:((Void)->Void)? = nil) {
        self.window.dismiss(duration,delay,text,completion)
    }
    public enum Mode{
        case loop(TimeInterval),duration(TimeInterval, dimissDelay:TimeInterval),percentComplete
        public static func ==(lhs:Mode,rhs:Mode) -> Bool{
            // 两个变量的switch
            switch (lhs, rhs) {
            case (.loop(_), .loop(_)):
                return true
            case (.duration(_), .duration(_)):
                return true
            case (.percentComplete, .percentComplete):
                return true
            default:
                return false
            }
        }
    }
    public enum Shape{
        case round,circle,custom((UIView) -> Void)
    }
    public enum Style{
        case light,dark,blur(UIBlurEffectStyle)
    }
    public enum Background{
        case none,color(UIColor),blur(UIBlurEffectStyle)
    }
    open class Content{
        public var mode: Mode
        public var shape:Shape
        public var style:Style
        public var background:Background
        //
        public var textLoading:String?
        public var textCompletion:String?
        public var isUserInteractionEnable = false
        public var fontLabel:UIFont?
        public var colorLineDefault:UIColor?
        public var colorLineElapse:UIColor?
        //
        public init(_ mode:Mode,_ shape:Shape? = nil,_ theme:Style? = nil,_ background:Background? = nil) {
            self.mode = mode
            self.shape = shape ?? .circle
            self.style = theme ?? .blur(.light)
            self.background = background ?? .none
        }
    }
    final class Window: UIWindow{
        private var hudView: HudView?
        
        convenience init(){
            self.init(frame: UIScreen.main.bounds)
            rootViewController = ViewController()
            windowLevel = UIWindowLevelNormal + 500
            backgroundColor = UIColor.clear
            rootViewController?.view.backgroundColor = UIColor.clear
            isHidden = true
        }
        public func show(_ content:Content){
            finish()
            isUserInteractionEnabled = content.isUserInteractionEnable
            hudView = HudView(self)
            hudView?.setContent(content)
            hudView?.dismiddHandler = { [weak self] in
                self?.finish()
            }
            makeKeyAndVisible()
            isHidden = false
            alpha = 1
        }
        public func updateProgress(_ percentage: CGFloat){
            hudView?.updateProgress(percentage)
            hudView?.updateProgressText(percentage)
        }
        public func dismiss(_ duration:TimeInterval,_ delay:TimeInterval,_ text:String? = nil,_ completion:((Void)->Void)? = nil) {
            hudView?.dismiss(duration, delay, text, completion)
        }
        func finish(){
            hudView = nil
            UIApplication.shared.delegate?.window??.makeKeyAndVisible()
            isHidden = true
            isUserInteractionEnabled = false
        }
    }
    final class ViewController: UIViewController{
        
    }
    final class HudView: UIView{
        static let size = CGSize(width: 180, height: 180)
        var dismiddHandler: ((Void)->Void)?
        static let fontLabel: UIFont = UIFont(name: "HelveticaNeue-Thin", size: 26)!
        static let insetLabel:CGFloat = 44
        let label = UILabel()
        let viewProgress = Progress()
        var viewBlur:UIVisualEffectView?
        var linkProgress: DisplayLink?
        var linkDismiss: DisplayLink?
        private(set) var content: Content?
        
        convenience init(_ view:UIView){
            self.init(frame: view.bounds)
            view.addSubview(self)
            view.allPin(withView: self)
            //
            viewProgress.clipsToBounds = true
            addSubview(viewProgress)
            setCenterLayoutConstraint(viewProgress)
            //
            label.textAlignment = .center
            label.backgroundColor = UIColor.clear
            label.adjustsFontSizeToFitWidth = true
            label.font = HudView.fontLabel
            viewProgress.addSubview(label)
            _ = addPin(withView: label, attribute:.top, toView:viewProgress, constant:HudView.insetLabel)
            _ = addPin(withView: label, attribute:.left, toView:viewProgress, constant:HudView.insetLabel)
            _ = addPin(withView: label, attribute:.right, toView:viewProgress, constant:HudView.insetLabel)
            _ = addPin(withView: label, attribute:.bottom, toView:viewProgress, constant:HudView.insetLabel)
        }
        func setContent(_ content:Content){
            self.content = content
            switch content.mode {
            case .loop(let interval):
                linkProgress = DisplayLink(interval)
                linkProgress?.needLoop = true
            case .duration(let duration,let dimissDelay):
                linkProgress = DisplayLink(duration)
                linkProgress?.completion = {[weak self] in
                    self?.dismiss(0.5, dimissDelay)
                }
            case .percentComplete:
                break
            }
            switch content.shape {
            case .round:
                viewProgress.layer.cornerRadius = 8
            case .circle:
                viewProgress.layer.cornerRadius = HudView.size.width * 0.5
            case .custom(let closure):
                closure(viewProgress)
            }
            switch content.style {
            case .dark:
                viewProgress.backgroundColor = UIColor.black
                label.textColor = UIColor.white
                viewProgress.colorDefault = content.colorLineDefault ?? UIColor.darkGray
                viewProgress.colorElapsed = content.colorLineElapse ?? UIColor.white
            case .light:
                viewProgress.backgroundColor = UIColor.white
                label.textColor = UIColor.black
                viewProgress.colorDefault = content.colorLineDefault ?? UIColor.lightGray
                viewProgress.colorElapsed = content.colorLineElapse ?? UIColor.darkGray
            case .blur(let effecType):
                label.textColor = UIColor.white
                viewProgress.colorDefault = content.colorLineDefault ?? UIColor.darkGray
                viewProgress.colorElapsed = content.colorLineElapse ?? UIColor.white
                let viewBlur = UIVisualEffectView(effect: UIBlurEffect(style: effecType))
                viewBlur.clipsToBounds = true
                addSubview(viewBlur)
                sendSubview(toBack: viewBlur)
                viewBlur.layer.cornerRadius = viewProgress.layer.cornerRadius
                setCenterLayoutConstraint(viewBlur)
                self.viewBlur = viewBlur
            }
            switch content.background {
            case .none:
                backgroundColor = UIColor.clear
            case .color(let color):
                backgroundColor = color
            case .blur(let effecType):
                backgroundColor = UIColor.clear
                let viewBlur = UIVisualEffectView(effect: UIBlurEffect(style: effecType))
                addSubview(viewBlur)
                sendSubview(toBack: viewBlur)
                allPin(withView: viewBlur)
            }
            label.font = content.fontLabel ?? HudView.fontLabel
            viewProgress.mode = content.mode
            label.text = content.textLoading
            let needShowProgressText = content.mode == .percentComplete
            linkProgress?.updateDurationCallback = { [weak self] percantage in
                self?.updateProgress(percantage)
                if needShowProgressText{
                    self?.updateProgressText(percantage)
                }
            }
            linkProgress?.start()
        }
        func updateProgress(_ percentage:CGFloat){
            viewProgress.percentComplete = percentage < 0 ? 0 : percentage > 1 ? 1 : percentage
        }
        func updateProgressText(_ percentage:CGFloat){
            label.text = Int(percentage < 0 ? 0 : percentage > 1 ? 1 : percentage).description + "%"
        }
        public func dismiss(_ duration:TimeInterval,_ delay:TimeInterval? = nil,_ text:String? = nil,_ completion:((Void)->Void)? = nil) {
            if linkDismiss != nil{
                return
            }
            linkProgress?.reset()
            label.text = text ?? content?.textCompletion
            if let delay = delay{
                linkDismiss = DisplayLink(delay)
                linkDismiss?.updateDurationCallback = {[weak self] percentComplete in
                    self?.finishAllIfNeed()
                }
                linkDismiss?.completion = {[weak self] in
                    self?.linkDismiss = nil
                    self?.dismiss(duration, nil, text, completion)
                }
                linkDismiss?.start()
            }else{
                linkDismiss = DisplayLink(duration)
                linkDismiss?.updateDurationCallback = {[weak self] percentComplete in
                    self?.alpha = CGFloat(1.0 - percentComplete)
                }
                linkDismiss?.completion = {[weak self] in
                    self?.dismiddHandler?()
                    self?.finish()
                    completion?()
                }
                linkDismiss?.start()
            }
        }
        func setCenterLayoutConstraint(_ view:UIView){
            pinCenter(subView: view)
            _ = view.addWidthConstraint(view: view, constant: HudView.size.width)
            _ = view.addWidthConstraint(view: view, constant: HudView.size.height)
        }
        func finishAllIfNeed(){
            viewProgress.outsideMargin -= 0.14
        }
        func finish(){
            viewBlur?.removeFromSuperview()
            backgroundColor = UIColor.clear
            viewProgress.backgroundColor = UIColor.clear
            viewProgress.finish()
            label.text = ""
            removeFromSuperview()
        }
    }
    final class Progress: UIView{
        static let startAngle:Double = 90
        static let endAngle:Double = 270
        var mode: Mode?
        var colorDefault = UIColor.gray
        var colorElapsed = UIColor.black
        var percentComplete:CGFloat = 0
        var outsideMargin:CGFloat = 0
        var lineWidth:CGFloat = 30{
            didSet{ setNeedsDisplay() }
        }
        var lineLineWidth:CGFloat = 25{
            didSet{ setNeedsDisplay() }
        }
        
        convenience init(){
            self.init(frame: CGRect.zero)
        }
        func finish(){
            
        }
    }
    final class DisplayLink{
        var needLoop = false
        var completion: ((Void)->Void)?
        var updateDurationCallback:((CGFloat) ->())?
        let duration:TimeInterval
        private(set) var currentDuration:TimeInterval = 0
        private(set) var percentComplete:CGFloat = 0
        private var displayLink: CADisplayLink? // 显示执行链
        
        init(_ duration:TimeInterval) {
            self.duration = duration
        }
        func start(){
            reset()
            updateDurationCallback?(0)
            startLink()
        }
        func startLink(){
            displayLink = CADisplayLink(target: self, selector: #selector(updateDuration(_:)))
            displayLink?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
        }
        @objc
        func updateDuration(_ displayLink:CADisplayLink) { //执行更新
            if currentDuration <= 0{
                return
            }
            currentDuration -= displayLink.duration
            let percentage = (duration - currentDuration) / duration
            let c = CGFloat(floor(percentage * 100.0)/100.0)
            if c != percentComplete {
                percentComplete = max(0, c)
                updateDurationCallback?(percentComplete)
            }
            if currentDuration <= 0{
                completion?()
                if needLoop{
                    start()
                }else{
                    reset()
                }
            }
        }
        func reset(){
            closeLink()
            percentComplete = 0
            currentDuration = duration
        }
        func closeLink(){
            displayLink?.invalidate()
            displayLink = nil
        }
        deinit {
           closeLink()
        }
    }
}
// 简单自动约束布局
fileprivate extension UIView{
    func checkTranslatesAutoresizing(withView: UIView?, toView:UIView?){
        if withView?.translatesAutoresizingMaskIntoConstraints == true{
            withView?.translatesAutoresizingMaskIntoConstraints = false
        }
        if toView?.translatesAutoresizingMaskIntoConstraints == true{
            toView?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    func addPin(withView: UIView,attribute:NSLayoutAttribute,toView:UIView?, constant:CGFloat = 0){
        checkTranslatesAutoresizing(withView: withView, toView: nil)
        _=addPinConstraint(addView: self, withItem: withView, toItem: toView, attribute: attribute, constant: constant)
    }
    func allPin(withView: UIView,_ constant:CGFloat = 0){
        checkTranslatesAutoresizing(withView: withView, toView: nil)
        _=addPinConstraint(addView: self, withItem: withView, toItem: self, attribute: .top, constant: constant)
        _=addPinConstraint(addView: self, withItem: withView, toItem: self, attribute: .bottom, constant: constant)
        _=addPinConstraint(addView: self, withItem: withView, toItem: self, attribute: .left, constant: constant)
        _=addPinConstraint(addView: self, withItem: withView, toItem: self, attribute: .right, constant: constant)
    }
    
    func pinCenter(subView:UIView,_ constantX:CGFloat = 0,_ constantY:CGFloat = 0){
        checkTranslatesAutoresizing(withView: subView, toView: nil)
        _=addPinConstraint(addView: self, withItem: subView, toItem: self, attribute: .centerX, constant: constantX)
        _=addPinConstraint(addView: self, withItem: subView, toItem: self, attribute: .centerY, constant: constantY)
    }
    @discardableResult
    func addPinConstraint(addView:UIView,withItem:UIView,toItem:UIView?,attribute:NSLayoutAttribute,constant:CGFloat) -> NSLayoutConstraint{
        return addConstraint(addView: addView, relation: .equal, withItem: withItem, withAttribute: attribute, toItem: toItem, toAttribute: attribute, constant: constant)
    }
    @discardableResult
    func addWidthConstraint(view:UIView,constant:CGFloat) -> NSLayoutConstraint{
        return addConstraint(addView: view, relation: .equal, withItem: view, withAttribute: .width, toItem: nil, toAttribute: .width, constant: constant)
    }
    @discardableResult
    func addHeightConstraint(view:UIView,constant:CGFloat) -> NSLayoutConstraint{
        return addConstraint(addView: view, relation: .equal, withItem: view, withAttribute: .height, toItem: nil, toAttribute: .height, constant: constant)
    }
    @discardableResult
    func addConstraint(addView: UIView,relation:NSLayoutRelation,withItem:UIView,withAttribute:NSLayoutAttribute,toItem:UIView?,toAttribute:NSLayoutAttribute,constant:CGFloat) ->NSLayoutConstraint{
        //
        let constraint = NSLayoutConstraint(item: withItem, attribute: withAttribute, relatedBy: relation, toItem: toItem, attribute: toAttribute, multiplier: 1, constant: constant)
        addView.addConstraint(constraint)
        return constraint
    }
}
