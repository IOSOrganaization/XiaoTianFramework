//
//  MyAlertViewControl.swift
//  XiaoTianFramework
//  弹框提示
//  Created by guotianrui on 2017/7/11.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
// Global Params
let kCircleHeightBackground: CGFloat = 62.0
public typealias DismissBlock = () -> Void
/// Alert View
open class MyAlertViewControl: UIViewController{
    var appearance:Appearance
    var viewColor: UIColor = UIColor()
    var iconTintColor: UIColor?
    var customSubview: UIView?
    var duration:TimeInterval!
    var durationStatusTimer:Timer!
    var durationTimer:Timer!
    var dismissBlock:DismissBlock?
    var keyboardHasBeenShown:Bool = false
    var tmpContentViewFrameOrigin:CGPoint?
    var tmpCircleViewFrameOrigin:CGPoint?
    // UIViewController当前的引用,当前弹框只用到了VC里的View,所以当view显示完毕,VC实体会被系统回收,所以要引用VC保持绑定和通知接收
    var selfReference:MyAlertViewControl?
    // UI
    var baseView = UIView()
    var circleView = UIView()
    var circleIconView:UIView?
    var contentView = UIView()
    var labelTitle = UILabel()
    var viewText = UITextView()
    var circleBG = UIView(frame: CGRect(x: 0, y: 0, width: kCircleHeightBackground, height: kCircleHeightBackground))
    private var inputs = [UITextField]()
    private var input = [UITextView]()
    private var buttons = [MyButton]()
    // init
    public init(_ appearance:Appearance = Appearance()) {
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        // main view
        view.frame = UIScreen.main.bounds
        view.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: appearance.kDefaultShadowOpacity)
        view.addSubview(baseView)
        // base view
        baseView.frame = view.frame
        baseView.addSubview(contentView)
        // content view
        contentView.layer.cornerRadius = appearance.contentViewCornerRadius
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 0.5
        contentView.addSubview(labelTitle)
        contentView.addSubview(viewText)
        // circle view
        circleBG.backgroundColor = UIColor.white
        circleBG.layer.cornerRadius = circleBG.frame.size.height / 2
        baseView.addSubview(circleBG)
        circleBG.addSubview(circleView)
        let x = (kCircleHeightBackground - appearance.kCircleHeight) / 2
        circleView.frame = CGRect(x: x, y: x, width: appearance.kCircleHeight, height: appearance.kCircleHeight)
        circleView.layer.cornerRadius = circleView.frame.size.height / 2
        // Title
        labelTitle.numberOfLines = 1
        labelTitle.textAlignment = .center
        labelTitle.font = appearance.kTitleFont
        labelTitle.frame = CGRect(x: 12, y: appearance.kTitleTop, width: appearance.kWindowWidth - 24, height: appearance.kTitleHeight)
        // view text
        viewText.isEditable = false
        viewText.textAlignment = .center
        viewText.textContainerInset = UIEdgeInsets.zero
        viewText.textContainer.lineFragmentPadding = 0
        viewText.font = appearance.kTextFont
        // color
        contentView.backgroundColor = appearance.contentViewColor
        viewText.backgroundColor = appearance.contentViewColor
        labelTitle.textColor = appearance.titleColor
        viewText.textColor = appearance.titleColor
        contentView.layer.borderColor = appearance.contentViewBorderColor.cgColor
        // tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapBackgroundView(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
    }
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let rv = UIApplication.shared.keyWindow!
        let sz = rv.frame.size
        // background frame
        view.frame.size = sz
        // computing the right size to use for the textview
        let maxHeight = sz.height - 100
        var consumedHeight:CGFloat = 0
        consumedHeight += appearance.kTitleTop + appearance.kTitleHeight
        consumedHeight += 14
        consumedHeight += appearance.kButtonHeight * CGFloat(buttons.count)
        consumedHeight += appearance.kTextFieldHeight * CGFloat(inputs.count)
        consumedHeight += appearance.kTextViewHeight * CGFloat(input.count)
        let maxViewTextHeight = maxHeight - consumedHeight
        let viewTextWidth = appearance.kWindowWidth - 24
        var viewTextHeight = appearance.kTextHeight
        if let customSubview = customSubview { // Add To Text View Place Holder
            viewTextHeight = CGFloat.minimum(customSubview.frame.height, maxViewTextHeight)
            viewText.text = ""
            viewText.addSubview(customSubview)
        }else{
            let suggestedViewTextSize = viewText.sizeThatFits(CGSize(width: viewTextWidth, height: CGFloat.greatestFiniteMagnitude))
            viewTextHeight = min(suggestedViewTextSize.height, maxViewTextHeight)
            if suggestedViewTextSize.height > maxViewTextHeight{
                viewText.isScrollEnabled = true
            }else{
                viewText.isScrollEnabled = false
            }
        }
        let windowHeight = consumedHeight + viewTextHeight
        // set frames
        var x = (sz.width - appearance.kWindowWidth) / 2
        var y = (sz.height - windowHeight - (appearance.kCircleHeight / 8)) / 2
        contentView.frame = CGRect(x: x, y: y, width: appearance.kWindowWidth, height: windowHeight)
        contentView.layer.cornerRadius = appearance.contentViewCornerRadius
        y -= kCircleHeightBackground * 0.6
        x = (sz.width - kCircleHeightBackground) / 2
        circleBG.frame = CGRect(x: x, y: y + 6, width: kCircleHeightBackground, height: kCircleHeightBackground)
        //
        let titleOffset:CGFloat = appearance.showCircularIcon ? 0 : -12
        labelTitle.frame = labelTitle.frame.offsetBy(dx: 0, dy: titleOffset)
        //
        y = appearance.kTitleTop + appearance.kTitleHeight + titleOffset
        viewText.frame = CGRect(x: 12, y: y, width: viewTextWidth, height: viewTextHeight)
        //
        y += viewTextHeight + 14
        for text in inputs{
            text.frame = CGRect(x: 12, y: y, width: appearance.kWindowWidth - 24, height: 30)
            text.layer.cornerRadius = appearance.fieldCornerRadius
            y += appearance.kTextFieldHeight
        }
        for text in input{
            text.frame = CGRect(x: 12, y: y, width: appearance.kWindowWidth - 24, height: 70)
            y += appearance.kTextViewHeight
        }
        for btn in buttons{
            btn.frame = CGRect(x: 12, y: y, width: appearance.kWindowWidth - 24, height: 35)
            btn.layer.cornerRadius = appearance.buttonCornerRadius
            y += appearance.kButtonHeight
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
    // 背景点击事件
    @objc
    private func onTapBackgroundView(_ tapGesture:UITapGestureRecognizer){
        view.endEditing(true)
        if let tappedView = tapGesture.view , tappedView.hitTest(tapGesture.location(in: tappedView), with: nil) == baseView && appearance.hideWhenBackgroundViewIsTapped{
            hideView()
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
        if tmpCircleViewFrameOrigin == nil{
            tmpCircleViewFrameOrigin = circleBG.frame.origin
        }
        var newContentViewFrameY = self.contentView.frame.maxY - endKeyBoardFrame
        if newContentViewFrameY < 0{
            newContentViewFrameY = 0
        }
        let newBallViewFrameY = circleBG.frame.origin.y - newContentViewFrameY
        contentView.frame.origin.y -= newContentViewFrameY
        circleBG.frame.origin.y = newBallViewFrameY
    }
    func keyboardWillHide(_ notification:Notification){
        if keyboardHasBeenShown{
            if tmpContentViewFrameOrigin != nil{
                contentView.frame.origin.y = tmpContentViewFrameOrigin!.y
                tmpContentViewFrameOrigin = nil
            }
            if tmpCircleViewFrameOrigin != nil{
                circleBG.frame.origin.y = tmpCircleViewFrameOrigin!.y
                tmpCircleViewFrameOrigin = nil
            }
            keyboardHasBeenShown = false
        }
    }
    open func hideView(){
        UIView.animate(withDuration: 0.2, animations: { 
            self.view.alpha = 0
        }) { (finished) in
            self.selfReference = nil
            self.durationTimer?.invalidate()
            self.durationStatusTimer?.invalidate()
            self.dismissBlock?()
            for button in self.buttons{
                button.action = nil
                button.selector = nil
                button.selectorTarget = nil
            }
            self.view.removeFromSuperview()
        }
    }
    open func addTextField(_ title:String? = nil) -> UITextField{
        appearance.setkWindowHeight(appearance.kWindowHeight + appearance.kTextFieldHeight)
        let text = UITextField()
        text.borderStyle = .roundedRect
        text.font = appearance.kTextFont
        text.autocapitalizationType = .words
        text.clearButtonMode = .whileEditing
        text.layer.masksToBounds = true
        text.layer.borderWidth = 0.5
        text.placeholder = title ?? ""
        contentView.addSubview(text)
        inputs.append(text)
        return text
    }
    open func addTextView() -> UITextView{
        appearance.setkWindowHeight(appearance.kWindowHeight + appearance.kTextViewHeight)
        let text = UITextView()
        text.font = appearance.kTextFont
        text.layer.masksToBounds = true
        text.layer.borderWidth = 0.5
        contentView.addSubview(text)
        input.append(text)
        return text
    }
    open func addButton(_ title:String,backgroundColor:UIColor? = nil,textColor:UIColor? = nil, showDurationStatus:Bool=false,action:@escaping ()->()) -> MyButton{
        let btn = addButton(title,backgroundColor:backgroundColor,textColor:textColor,showDurationStatus:showDurationStatus)
        btn.actionType = .closure
        btn.action = action
        btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        btn.addTarget(self, action: #selector(buttonTapDown(_:)), for: [.touchDown,.touchDragEnter])
        btn.addTarget(self, action: #selector(buttonRelease(_:)), for: [.touchUpInside,.touchUpOutside,.touchCancel,.touchDragOutside])
        return btn
    }
    open func addButton(_ title:String,backgroundColor:UIColor? = nil,textColor:UIColor? = nil, showDurationStatus:Bool=false,target:AnyObject,selector:Selector) -> MyButton{
        let btn = addButton(title,backgroundColor:backgroundColor,textColor:textColor,showDurationStatus:showDurationStatus)
        btn.actionType = .selector
        btn.selector = selector
        btn.selectorTarget = target
        btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        btn.addTarget(self, action: #selector(buttonTapDown(_:)), for: [.touchDown,.touchDragEnter])
        btn.addTarget(self, action: #selector(buttonRelease(_:)), for: [.touchUpInside,.touchUpOutside,.touchCancel,.touchDragOutside])
        return btn
    }
    open func addButton(_ title:String,backgroundColor:UIColor? = nil,textColor:UIColor? = nil, showDurationStatus:Bool=false)  -> MyButton{
        appearance.setkWindowHeight(appearance.kWindowHeight + appearance.kButtonHeight)
        let btn = MyButton()
        btn.layer.masksToBounds = true
        btn.setTitle(title, for: UIControlState())
        btn.titleLabel?.font = appearance.kButtonFont
        btn.customBackgroundColor = backgroundColor
        btn.customTextColor = textColor
        btn.initialTitle = title
        btn.showDurationStatus = showDurationStatus
        contentView.addSubview(btn)
        buttons.append(btn)
        return btn
    }
    func buttonTapped(_ btn:MyButton){
        if btn.actionType == .closure{
            btn.action?()
        }else if btn.actionType == .selector{
            let ctrl = UIControl()
            ctrl.sendAction(btn.selector, to: btn.selectorTarget, for: nil)
        }else{
            print("Unknow action type for button")
        }
        if view.alpha != 0 && appearance.shouldAutoDismiss{
            hideView()
        }
    }
    func buttonTapDown(_ btn:MyButton){
        var hue:CGFloat = 0
        var staturation:CGFloat = 0
        var brightness:CGFloat = 0
        var alpha:CGFloat = 0
        let pressBrightnessFactor:CGFloat = 0.85
        btn.backgroundColor?.getHue(&hue, saturation: &staturation, brightness: &brightness, alpha: &alpha)
        brightness = brightness * pressBrightnessFactor
        btn.backgroundColor = UIColor(hue: hue, saturation: staturation, brightness: brightness, alpha: alpha)
    }
    func buttonRelease(_ btn:MyButton){
        btn.backgroundColor = btn.customBackgroundColor ?? viewColor
    }
    // Show Alert
    @discardableResult
    open func showSuccess(_ title:String,subTitle:String) -> Responder{
        return show(title, subTitle: subTitle, closeButton: nil, duration: 0, style: .success, color: Style.success.defaultColor, colorTextButton: UIColor.white, imageIcon: nil, animation: .topToBottom)
    }
    @discardableResult
    open func showError(_ title:String,subTitle:String) -> Responder{
        return show(title, subTitle: subTitle, closeButton: nil, duration: 0, style: .error, color: Style.error.defaultColor, colorTextButton: UIColor.white, imageIcon: nil, animation: .topToBottom)
    }
    @discardableResult
    open func showNotice(_ title:String,subTitle:String) -> Responder{
        return show(title, subTitle: subTitle, closeButton: nil, duration: 0, style: .notice, color: Style.notice.defaultColor, colorTextButton: UIColor.white, imageIcon: nil, animation: .topToBottom)
    }
    @discardableResult
    open func showWarning(_ title:String,subTitle:String) -> Responder{
        return show(title, subTitle: subTitle, closeButton: nil, duration: 0, style: .warning, color: Style.warning.defaultColor, colorTextButton: UIColor.white, imageIcon: nil, animation: .topToBottom)
    }
    @discardableResult
    open func showInfo(_ title:String,subTitle:String) -> Responder{
        return show(title, subTitle: subTitle, closeButton: nil, duration: 0, style: .info, color: Style.info.defaultColor, colorTextButton: UIColor.white, imageIcon: nil, animation: .topToBottom)
    }
    @discardableResult
    open func showWait(_ title:String,subTitle:String) -> Responder{
        return show(title, subTitle: subTitle, closeButton: nil, duration: 0, style: .wait, color: Style.wait.defaultColor, colorTextButton: UIColor.white, imageIcon: nil, animation: .topToBottom)
    }
    @discardableResult
    open func showEdit(_ title:String,subTitle:String) -> Responder{
        return show(title, subTitle: subTitle, closeButton: nil, duration: 0, style: .edit, color: Style.edit.defaultColor, colorTextButton: UIColor.white, imageIcon: nil, animation: .topToBottom)
    }
    // 显示弹框
    @discardableResult
    open func show(_ title:String, subTitle:String, closeButton:String?, duration:TimeInterval?, style:Style, color:UIColor?, colorTextButton:UIColor?, imageIcon:UIImage?, animation:Animation) -> Responder{
        selfReference = self
        view.alpha = 0
        let rv = UIApplication.shared.keyWindow!
        rv.addSubview(view)
        view.frame = rv.bounds
        baseView.frame = rv.bounds
        viewColor = color ?? style.defaultColor
        if !title.isEmpty{
            labelTitle.text = title
        }
        if !subTitle.isEmpty{
            viewText.text = subTitle
            let str = subTitle as NSString
            let attr = [NSFontAttributeName:viewText.font ?? UIFont()]
            let sz = CGSize(width: appearance.kWindowWidth - 24, height: 90)
            let r = str.boundingRect(with: sz, options: .usesLineFragmentOrigin, attributes: attr, context: nil)
            let ht = ceil(r.size.height)
            if ht < appearance.kTextHeight{
                appearance.kWindowHeight -= (appearance.kTextHeight - ht)
                appearance.setkTextHeight(ht)
            }
        }
        if appearance.showCloseButton{
            _ = addButton(closeButton ?? "确定", target: self,selector: #selector(hideView))
        }
        circleBG.isHidden = !appearance.showCircularIcon
        circleView.isHidden = circleBG.isHidden
        circleView.backgroundColor = viewColor
        if style == .wait{
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
            indicator.startAnimating()
            circleIconView = indicator
        }else{
            if let iconTintColor = iconTintColor{
                circleIconView = UIImageView(image: Images.getCircleImageIcon(style: style, defaultImage: imageIcon)?.withRenderingMode(.alwaysTemplate))
                circleIconView?.tintColor = iconTintColor
            }else{
                circleIconView = UIImageView(image: Images.getCircleImageIcon(style: style, defaultImage: imageIcon))
            }
        }
        circleView.addSubview(circleIconView!)
        let x = (appearance.kCircleHeight - appearance.kCircleIconHeight) / 2
        circleIconView?.frame = CGRect(x: x, y: x, width: appearance.kCircleIconHeight, height: appearance.kCircleIconHeight)
        circleIconView?.layer.cornerRadius = circleIconView!.bounds.height / 2
        circleIconView?.layer.masksToBounds = true
        for text in inputs {
            text.layer.borderColor = viewColor.cgColor
        }
        for text in input {
            text.layer.borderColor = viewColor.cgColor
        }
        for btn in buttons {
            btn.backgroundColor = btn.customBackgroundColor ?? viewColor
            btn.setTitleColor(btn.customTextColor ?? colorTextButton ?? UIColor.white, for: UIControlState())
        }
        if duration ?? 0 > 0 {
            self.duration = duration
            durationTimer?.invalidate()
            durationTimer = Timer.scheduledTimer(timeInterval: self.duration, target: self, selector: #selector(hideView), userInfo: nil, repeats: false)
            durationStatusTimer?.invalidate()
            durationStatusTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDurationStatus), userInfo: nil, repeats: true)
        }
        showAnimation(animation)
        return Responder(self)
    }
    @objc
    private func updateDurationStatus(){
        duration = duration.advanced(by: -1)// advanced:增加
        for btn in buttons.filter({ $0.showDurationStatus }) {
            let text = "\(btn.initialTitle ?? "") (\(Int(duration ?? 0)))"
            btn.setTitle(text, for: UIControlState())
        }
    }
    private func showAnimation(_ animationType:Animation = .topToBottom, animationStartOffset:CGFloat = -400, boundingAnimationOffset:CGFloat = 15,animationDuration:TimeInterval = 0.2){
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
    // file private method
    fileprivate static func color(_ rgb:Int) -> UIColor{
        let r = (rgb & 0xFF0000) >> 16
        let g = (rgb & 0xFF00) >> 8
        let b = rgb & 0xFF
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: 1)
    }
    public struct Appearance{
        let kDefaultShadowOpacity:CGFloat
        let kCircleTopPosition:CGFloat
        let kCircleBackgroundTopPosition:CGFloat
        let kCircleHeight:CGFloat
        let kCircleIconHeight:CGFloat
        let kTitleTop:CGFloat
        let kTitleHeight:CGFloat
        let kWindowWidth:CGFloat
        var kWindowHeight:CGFloat
        var kTextHeight:CGFloat
        let kTextFieldHeight:CGFloat
        let kTextViewHeight:CGFloat
        let kButtonHeight:CGFloat
        let contentViewColor:UIColor
        let contentViewBorderColor:UIColor
        let titleColor:UIColor
        let kTitleFont:UIFont
        let kTextFont:UIFont
        let kButtonFont:UIFont
        var showCloseButton:Bool
        var showCircularIcon:Bool
        var shouldAutoDismiss:Bool
        var contentViewCornerRadius:CGFloat
        var fieldCornerRadius:CGFloat
        var buttonCornerRadius:CGFloat
        var hideWhenBackgroundViewIsTapped:Bool
        //
        public init(kDefaultShadowOpacity:CGFloat = 0.7,
                    kCircleTopPosition:CGFloat = -12,
                    kCircleBackgroundTopPosition:CGFloat = -15,
                    kCircleHeight:CGFloat = 56,
                    kCircleIconHeight:CGFloat = 20,
                    kTitleTop:CGFloat = 30,
                    kTitleHeight:CGFloat = 25,
                    kWindowWidth:CGFloat = 240,
                    kWindowHeight:CGFloat = 178,
                    kTextHeight:CGFloat = 90,
                    kTextFieldHeight:CGFloat = 45,
                    kTextViewHeight:CGFloat = 80,
                    kButtonHeight:CGFloat = 45,
                    contentViewColor:UIColor = MyAlertViewControl.color(0xFFFFFF),
                    contentViewBorderColor:UIColor = MyAlertViewControl.color(0xCCCCCC),
                    titleColor:UIColor = MyAlertViewControl.color(0x4D4D4D),
                    kTitleFont:UIFont = UIFont.systemFont(ofSize: 20),
                    kTextFont:UIFont = UIFont.systemFont(ofSize: 14),
                    kButtonFont:UIFont = UIFont.systemFont(ofSize: 14),
                    showCloseButton:Bool = true,
                    showCircularIcon:Bool = true,
                    shouldAutoDismiss:Bool = true,
                    contentViewCornerRadius:CGFloat = 5,
                    fieldCornerRadius:CGFloat = 3,
                    buttonCornerRadius:CGFloat = 3,
                    hideWhenBackgroundViewIsTapped:Bool = false) {
            //
            self.kDefaultShadowOpacity = kDefaultShadowOpacity
            self.kCircleTopPosition = kCircleTopPosition
            self.kCircleBackgroundTopPosition = kCircleBackgroundTopPosition
            self.kCircleHeight = kCircleHeight
            self.kCircleIconHeight = kCircleIconHeight
            self.kTitleTop = kTitleTop
            self.kTitleHeight = kTitleHeight
            self.kWindowWidth = kWindowWidth
            self.kWindowHeight = kWindowHeight
            self.kTextHeight = kTextHeight
            self.kTextFieldHeight = kTextFieldHeight
            self.kTextViewHeight = kTextViewHeight
            self.kButtonHeight = kButtonHeight
            self.contentViewColor = contentViewColor
            self.contentViewBorderColor = contentViewBorderColor
            self.titleColor = titleColor
            self.kTitleFont = kTitleFont
            self.kTextFont = kTextFont
            self.kButtonFont = kButtonFont
            self.showCloseButton = showCloseButton
            self.showCircularIcon = showCircularIcon
            self.shouldAutoDismiss = shouldAutoDismiss
            self.contentViewCornerRadius = contentViewCornerRadius
            self.fieldCornerRadius = fieldCornerRadius
            self.buttonCornerRadius = buttonCornerRadius
            self.hideWhenBackgroundViewIsTapped = hideWhenBackgroundViewIsTapped
        }
        mutating func setkWindowHeight(_ kWindowHeight:CGFloat){
            self.kWindowHeight = kWindowHeight
        }
        mutating func setkTextHeight(_ kTextHeight:CGFloat){
            self.kTextHeight = kTextHeight
        }
    }
    
    // Style
    public enum Style{
        case success,error,notice,warning,info,edit,wait
        
        public var defaultColor:UIColor{
            switch self {
            case .success:
                return MyAlertViewControl.color(0x22B573)
            case .error:
                return MyAlertViewControl.color(0xC1272D)
            case .notice:
                return MyAlertViewControl.color(0x727375)
            case .warning:
                return MyAlertViewControl.color(0xFFD110)
            case .info:
                return MyAlertViewControl.color(0x2866BF)
            case .edit:
                return MyAlertViewControl.color(0xA429FF)
            case .wait:
                return MyAlertViewControl.color(0xD62DA5)
            }
        }
    }
    public enum Animation{
        case noAnimation,topToBottom,bottomToTop,leftToRight,rightToLeft
    }
    public enum Action{
        case none,selector,closure
    }
    // Inner Class
    open class Images{
        // 全局单例
        struct Cache{
            static var checkmark:UIImage?
            static var checkmarkTargets:[AnyObject]?
            static var cross:UIImage?
            static var crossTargets:[AnyObject]?
            static var notice:UIImage?
            static var noticeTargets:[AnyObject]?
            static var warning:UIImage?
            static var warningTargets:[AnyObject]?
            static var info:UIImage?
            static var infoTargets:[AnyObject]?
            static var edit:UIImage?
            static var editTargets:[AnyObject]?
        }
        class var checkmark: UIImage{
            if Cache.checkmark != nil{
                return Cache.checkmark!
            }
            func drawShape(){
                let checkmarkShapePath = UIBezierPath()
                checkmarkShapePath.move(to: CGPoint(x: 73.25, y: 14.05))
                checkmarkShapePath.addCurve(to: CGPoint(x: 64.51, y: 13.86), controlPoint1: CGPoint(x: 70.98, y: 11.44), controlPoint2: CGPoint(x: 66.78, y: 11.26))
                checkmarkShapePath.addLine(to: CGPoint(x: 27.46, y: 52))
                checkmarkShapePath.addLine(to: CGPoint(x: 15.75, y: 39.54))
                checkmarkShapePath.addCurve(to: CGPoint(x: 6.84, y: 39.54), controlPoint1: CGPoint(x: 13.48, y: 36.93), controlPoint2: CGPoint(x: 9.28, y: 36.93))
                checkmarkShapePath.addCurve(to: CGPoint(x: 6.84, y: 49.02), controlPoint1: CGPoint(x: 4.39, y: 42.14), controlPoint2: CGPoint(x: 4.39, y: 46.42))
                checkmarkShapePath.addLine(to: CGPoint(x: 22.91, y: 66.14))
                checkmarkShapePath.addCurve(to: CGPoint(x: 27.28, y: 68), controlPoint1: CGPoint(x: 24.14, y: 67.44), controlPoint2: CGPoint(x: 25.71, y: 68))
                checkmarkShapePath.addCurve(to: CGPoint(x: 31.65, y: 66.14), controlPoint1: CGPoint(x: 28.86, y: 68), controlPoint2: CGPoint(x: 30.43, y: 67.26))
                checkmarkShapePath.addLine(to: CGPoint(x: 73.08, y: 23.35))
                checkmarkShapePath.addCurve(to: CGPoint(x: 73.25, y: 14.05), controlPoint1: CGPoint(x: 75.52, y: 20.75), controlPoint2: CGPoint(x: 75.7, y: 16.65))
                checkmarkShapePath.close()
                checkmarkShapePath.miterLimit = 4;
                UIColor.white.setFill()
                checkmarkShapePath.fill()
            }
            // Draw Checkmark
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 80, height: 80), false, 0)
            drawShape()
            Cache.checkmark = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return Cache.checkmark!
        }
        class var cross: UIImage{
            if Cache.cross != nil{
                return Cache.cross!
            }
            func drawShape(){
                // Cross Shape Drawing
                let crossShapePath = UIBezierPath()
                crossShapePath.move(to: CGPoint(x: 10, y: 70))
                crossShapePath.addLine(to: CGPoint(x: 70, y: 10))
                crossShapePath.move(to: CGPoint(x: 10, y: 10))
                crossShapePath.addLine(to: CGPoint(x: 70, y: 70))
                crossShapePath.lineCapStyle = CGLineCap.round;
                crossShapePath.lineJoinStyle = CGLineJoin.round;
                UIColor.white.setStroke()
                crossShapePath.lineWidth = 14
                crossShapePath.stroke()
            }
            UIGraphicsBeginImageContextWithOptions(CGSize(width:80, height:80), false, 0)
            drawShape()
            Cache.cross = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return Cache.cross!
        }
        class var notice: UIImage{
            if Cache.notice != nil{
                return Cache.notice!
            }
            func drawShape(){
                // Notice Shape Drawing
                let noticeShapePath = UIBezierPath()
                noticeShapePath.move(to: CGPoint(x: 72, y: 48.54))
                noticeShapePath.addLine(to: CGPoint(x: 72, y: 39.9))
                noticeShapePath.addCurve(to: CGPoint(x: 66.38, y: 34.01), controlPoint1: CGPoint(x: 72, y: 36.76), controlPoint2: CGPoint(x: 69.48, y: 34.01))
                noticeShapePath.addCurve(to: CGPoint(x: 61.53, y: 35.97), controlPoint1: CGPoint(x: 64.82, y: 34.01), controlPoint2: CGPoint(x: 62.69, y: 34.8))
                noticeShapePath.addCurve(to: CGPoint(x: 60.36, y: 35.78), controlPoint1: CGPoint(x: 61.33, y: 35.97), controlPoint2: CGPoint(x: 62.3, y: 35.78))
                noticeShapePath.addLine(to: CGPoint(x: 60.36, y: 33.22))
                noticeShapePath.addCurve(to: CGPoint(x: 54.16, y: 26.16), controlPoint1: CGPoint(x: 60.36, y: 29.3), controlPoint2: CGPoint(x: 57.65, y: 26.16))
                noticeShapePath.addCurve(to: CGPoint(x: 48.73, y: 29.89), controlPoint1: CGPoint(x: 51.64, y: 26.16), controlPoint2: CGPoint(x: 50.67, y: 27.73))
                noticeShapePath.addLine(to: CGPoint(x: 48.73, y: 28.71))
                noticeShapePath.addCurve(to: CGPoint(x: 43.49, y: 21.64), controlPoint1: CGPoint(x: 48.73, y: 24.78), controlPoint2: CGPoint(x: 46.98, y: 21.64))
                noticeShapePath.addCurve(to: CGPoint(x: 39.03, y: 25.37), controlPoint1: CGPoint(x: 40.97, y: 21.64), controlPoint2: CGPoint(x: 39.03, y: 23.01))
                noticeShapePath.addLine(to: CGPoint(x: 39.03, y: 9.07))
                noticeShapePath.addCurve(to: CGPoint(x: 32.24, y: 2), controlPoint1: CGPoint(x: 39.03, y: 5.14), controlPoint2: CGPoint(x: 35.73, y: 2))
                noticeShapePath.addCurve(to: CGPoint(x: 25.45, y: 9.07), controlPoint1: CGPoint(x: 28.56, y: 2), controlPoint2: CGPoint(x: 25.45, y: 5.14))
                noticeShapePath.addLine(to: CGPoint(x: 25.45, y: 41.47))
                noticeShapePath.addCurve(to: CGPoint(x: 24.29, y: 43.44), controlPoint1: CGPoint(x: 25.45, y: 42.45), controlPoint2: CGPoint(x: 24.68, y: 43.04))
                noticeShapePath.addCurve(to: CGPoint(x: 9.55, y: 43.04), controlPoint1: CGPoint(x: 16.73, y: 40.88), controlPoint2: CGPoint(x: 11.88, y: 40.69))
                noticeShapePath.addCurve(to: CGPoint(x: 8, y: 46.58), controlPoint1: CGPoint(x: 8.58, y: 43.83), controlPoint2: CGPoint(x: 8, y: 45.2))
                noticeShapePath.addCurve(to: CGPoint(x: 14.4, y: 55.81), controlPoint1: CGPoint(x: 8.19, y: 50.31), controlPoint2: CGPoint(x: 12.07, y: 53.84))
                noticeShapePath.addLine(to: CGPoint(x: 27.2, y: 69.56))
                noticeShapePath.addCurve(to: CGPoint(x: 42.91, y: 77.8), controlPoint1: CGPoint(x: 30.5, y: 74.47), controlPoint2: CGPoint(x: 35.73, y: 77.21))
                noticeShapePath.addCurve(to: CGPoint(x: 43.88, y: 77.8), controlPoint1: CGPoint(x: 43.3, y: 77.8), controlPoint2: CGPoint(x: 43.68, y: 77.8))
                noticeShapePath.addCurve(to: CGPoint(x: 47.18, y: 78), controlPoint1: CGPoint(x: 45.04, y: 77.8), controlPoint2: CGPoint(x: 46.01, y: 78))
                noticeShapePath.addLine(to: CGPoint(x: 48.34, y: 78))
                noticeShapePath.addLine(to: CGPoint(x: 48.34, y: 78))
                noticeShapePath.addCurve(to: CGPoint(x: 71.61, y: 52.08), controlPoint1: CGPoint(x: 56.48, y: 78), controlPoint2: CGPoint(x: 69.87, y: 75.05))
                noticeShapePath.addCurve(to: CGPoint(x: 72, y: 48.54), controlPoint1: CGPoint(x: 71.81, y: 51.29), controlPoint2: CGPoint(x: 72, y: 49.72))
                noticeShapePath.close()
                noticeShapePath.miterLimit = 4;
                
                UIColor.white.setFill()
                noticeShapePath.fill()
            }
            UIGraphicsBeginImageContextWithOptions(CGSize(width:80, height:80), false, 0)
            drawShape()
            Cache.notice = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return Cache.notice!
        }
        class var warning: UIImage{
            if Cache.warning != nil{
                return Cache.warning!
            }
            func drawShape(){
                // Color Declarations
                let greyColor = UIColor(red: 0.236, green: 0.236, blue: 0.236, alpha: 1.000)
                // Warning Group
                // Warning Circle Drawing
                let warningCirclePath = UIBezierPath()
                warningCirclePath.move(to: CGPoint(x: 40.94, y: 63.39))
                warningCirclePath.addCurve(to: CGPoint(x: 36.03, y: 65.55), controlPoint1: CGPoint(x: 39.06, y: 63.39), controlPoint2: CGPoint(x: 37.36, y: 64.18))
                warningCirclePath.addCurve(to: CGPoint(x: 34.14, y: 70.45), controlPoint1: CGPoint(x: 34.9, y: 66.92), controlPoint2: CGPoint(x: 34.14, y: 68.49))
                warningCirclePath.addCurve(to: CGPoint(x: 36.22, y: 75.54), controlPoint1: CGPoint(x: 34.14, y: 72.41), controlPoint2: CGPoint(x: 34.9, y: 74.17))
                warningCirclePath.addCurve(to: CGPoint(x: 40.94, y: 77.5), controlPoint1: CGPoint(x: 37.54, y: 76.91), controlPoint2: CGPoint(x: 39.06, y: 77.5))
                warningCirclePath.addCurve(to: CGPoint(x: 45.86, y: 75.35), controlPoint1: CGPoint(x: 42.83, y: 77.5), controlPoint2: CGPoint(x: 44.53, y: 76.72))
                warningCirclePath.addCurve(to: CGPoint(x: 47.93, y: 70.45), controlPoint1: CGPoint(x: 47.18, y: 74.17), controlPoint2: CGPoint(x: 47.93, y: 72.41))
                warningCirclePath.addCurve(to: CGPoint(x: 45.86, y: 65.35), controlPoint1: CGPoint(x: 47.93, y: 68.49), controlPoint2: CGPoint(x: 47.18, y: 66.72))
                warningCirclePath.addCurve(to: CGPoint(x: 40.94, y: 63.39), controlPoint1: CGPoint(x: 44.53, y: 64.18), controlPoint2: CGPoint(x: 42.83, y: 63.39))
                warningCirclePath.close()
                warningCirclePath.miterLimit = 4;
                greyColor.setFill()
                warningCirclePath.fill()
                // Warning Shape Drawing
                let warningShapePath = UIBezierPath()
                warningShapePath.move(to: CGPoint(x: 46.23, y: 4.26))
                warningShapePath.addCurve(to: CGPoint(x: 40.94, y: 2.5), controlPoint1: CGPoint(x: 44.91, y: 3.09), controlPoint2: CGPoint(x: 43.02, y: 2.5))
                warningShapePath.addCurve(to: CGPoint(x: 34.71, y: 4.26), controlPoint1: CGPoint(x: 38.68, y: 2.5), controlPoint2: CGPoint(x: 36.03, y: 3.09))
                warningShapePath.addCurve(to: CGPoint(x: 31.5, y: 8.77), controlPoint1: CGPoint(x: 33.01, y: 5.44), controlPoint2: CGPoint(x: 31.5, y: 7.01))
                warningShapePath.addLine(to: CGPoint(x: 31.5, y: 19.36))
                warningShapePath.addLine(to: CGPoint(x: 34.71, y: 54.44))
                warningShapePath.addCurve(to: CGPoint(x: 40.38, y: 58.16), controlPoint1: CGPoint(x: 34.9, y: 56.2), controlPoint2: CGPoint(x: 36.41, y: 58.16))
                warningShapePath.addCurve(to: CGPoint(x: 45.67, y: 54.44), controlPoint1: CGPoint(x: 44.34, y: 58.16), controlPoint2: CGPoint(x: 45.67, y: 56.01))
                warningShapePath.addLine(to: CGPoint(x: 48.5, y: 19.36))
                warningShapePath.addLine(to: CGPoint(x: 48.5, y: 8.77))
                warningShapePath.addCurve(to: CGPoint(x: 46.23, y: 4.26), controlPoint1: CGPoint(x: 48.5, y: 7.01), controlPoint2: CGPoint(x: 47.74, y: 5.44))
                warningShapePath.close()
                warningShapePath.miterLimit = 4;
                greyColor.setFill()
                warningShapePath.fill()
            }
            UIGraphicsBeginImageContextWithOptions(CGSize(width:80, height:80), false, 0)
            drawShape()
            Cache.warning = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return Cache.warning!
        }
        class var info: UIImage{
            if Cache.info != nil{
                return Cache.info!
            }
            func drawShape(){
                // Color Declarations
                let color0 = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
                // Info Shape Drawing
                let infoShapePath = UIBezierPath()
                infoShapePath.move(to: CGPoint(x: 45.66, y: 15.96))
                infoShapePath.addCurve(to: CGPoint(x: 45.66, y: 5.22), controlPoint1: CGPoint(x: 48.78, y: 12.99), controlPoint2: CGPoint(x: 48.78, y: 8.19))
                infoShapePath.addCurve(to: CGPoint(x: 34.34, y: 5.22), controlPoint1: CGPoint(x: 42.53, y: 2.26), controlPoint2: CGPoint(x: 37.47, y: 2.26))
                infoShapePath.addCurve(to: CGPoint(x: 34.34, y: 15.96), controlPoint1: CGPoint(x: 31.22, y: 8.19), controlPoint2: CGPoint(x: 31.22, y: 12.99))
                infoShapePath.addCurve(to: CGPoint(x: 45.66, y: 15.96), controlPoint1: CGPoint(x: 37.47, y: 18.92), controlPoint2: CGPoint(x: 42.53, y: 18.92))
                infoShapePath.close()
                infoShapePath.move(to: CGPoint(x: 48, y: 69.41))
                infoShapePath.addCurve(to: CGPoint(x: 40, y: 77), controlPoint1: CGPoint(x: 48, y: 73.58), controlPoint2: CGPoint(x: 44.4, y: 77))
                infoShapePath.addLine(to: CGPoint(x: 40, y: 77))
                infoShapePath.addCurve(to: CGPoint(x: 32, y: 69.41), controlPoint1: CGPoint(x: 35.6, y: 77), controlPoint2: CGPoint(x: 32, y: 73.58))
                infoShapePath.addLine(to: CGPoint(x: 32, y: 35.26))
                infoShapePath.addCurve(to: CGPoint(x: 40, y: 27.67), controlPoint1: CGPoint(x: 32, y: 31.08), controlPoint2: CGPoint(x: 35.6, y: 27.67))
                infoShapePath.addLine(to: CGPoint(x: 40, y: 27.67))
                infoShapePath.addCurve(to: CGPoint(x: 48, y: 35.26), controlPoint1: CGPoint(x: 44.4, y: 27.67), controlPoint2: CGPoint(x: 48, y: 31.08))
                infoShapePath.addLine(to: CGPoint(x: 48, y: 69.41))
                infoShapePath.close()
                color0.setFill()
                infoShapePath.fill()
            }
            UIGraphicsBeginImageContextWithOptions(CGSize(width:80, height:80), false, 0)
            drawShape()
            Cache.info = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return Cache.info!
        }
        class var edit: UIImage{
            if Cache.edit != nil{
                return Cache.edit!
            }
            func drawShape(){
                // Color Declarations
                let color = UIColor(red:1.0, green:1.0, blue:1.0, alpha:1.0)
                // Edit shape Drawing
                let editPathPath = UIBezierPath()
                editPathPath.move(to: CGPoint(x: 71, y: 2.7))
                editPathPath.addCurve(to: CGPoint(x: 71.9, y: 15.2), controlPoint1: CGPoint(x: 74.7, y: 5.9), controlPoint2: CGPoint(x: 75.1, y: 11.6))
                editPathPath.addLine(to: CGPoint(x: 64.5, y: 23.7))
                editPathPath.addLine(to: CGPoint(x: 49.9, y: 11.1))
                editPathPath.addLine(to: CGPoint(x: 57.3, y: 2.6))
                editPathPath.addCurve(to: CGPoint(x: 69.7, y: 1.7), controlPoint1: CGPoint(x: 60.4, y: -1.1), controlPoint2: CGPoint(x: 66.1, y: -1.5))
                editPathPath.addLine(to: CGPoint(x: 71, y: 2.7))
                editPathPath.addLine(to: CGPoint(x: 71, y: 2.7))
                editPathPath.close()
                editPathPath.move(to: CGPoint(x: 47.8, y: 13.5))
                editPathPath.addLine(to: CGPoint(x: 13.4, y: 53.1))
                editPathPath.addLine(to: CGPoint(x: 15.7, y: 55.1))
                editPathPath.addLine(to: CGPoint(x: 50.1, y: 15.5))
                editPathPath.addLine(to: CGPoint(x: 47.8, y: 13.5))
                editPathPath.addLine(to: CGPoint(x: 47.8, y: 13.5))
                editPathPath.close()
                editPathPath.move(to: CGPoint(x: 17.7, y: 56.7))
                editPathPath.addLine(to: CGPoint(x: 23.8, y: 62.2))
                editPathPath.addLine(to: CGPoint(x: 58.2, y: 22.6))
                editPathPath.addLine(to: CGPoint(x: 52, y: 17.1))
                editPathPath.addLine(to: CGPoint(x: 17.7, y: 56.7))
                editPathPath.addLine(to: CGPoint(x: 17.7, y: 56.7))
                editPathPath.close()
                editPathPath.move(to: CGPoint(x: 25.8, y: 63.8))
                editPathPath.addLine(to: CGPoint(x: 60.1, y: 24.2))
                editPathPath.addLine(to: CGPoint(x: 62.3, y: 26.1))
                editPathPath.addLine(to: CGPoint(x: 28.1, y: 65.7))
                editPathPath.addLine(to: CGPoint(x: 25.8, y: 63.8))
                editPathPath.addLine(to: CGPoint(x: 25.8, y: 63.8))
                editPathPath.close()
                editPathPath.move(to: CGPoint(x: 25.9, y: 68.1))
                editPathPath.addLine(to: CGPoint(x: 4.2, y: 79.5))
                editPathPath.addLine(to: CGPoint(x: 11.3, y: 55.5))
                editPathPath.addLine(to: CGPoint(x: 25.9, y: 68.1))
                editPathPath.close()
                editPathPath.miterLimit = 4;
                editPathPath.usesEvenOddFillRule = true;
                color.setFill()
                editPathPath.fill()
            }
            UIGraphicsBeginImageContextWithOptions(CGSize(width:80, height:80), false, 0)
            drawShape()
            Cache.edit = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return Cache.edit!
        }
        class func getCircleImageIcon(style:Style,defaultImage:UIImage?) -> UIImage?{
            switch style {
            case .success:
                return defaultImage ?? Images.checkmark
            case .error:
                return defaultImage ?? Images.cross
            case .notice:
                return defaultImage ?? Images.notice
            case .warning:
                return defaultImage ?? Images.warning
            case .info:
                return defaultImage ?? Images.info
            case .edit:
                return defaultImage ?? Images.edit
            case .wait:
                return defaultImage ?? nil
            }
        }
    }

    open class MyButton: UIButton{
        var actionType = MyAlertViewControl.Action.none
        var selectorTarget:AnyObject!
        var selector:Selector!
        var action:(()->())!
        var customBackgroundColor:UIColor!
        var customTextColor:UIColor!
        var initialTitle:String!
        var showDurationStatus = false
    }
    open class Responder{
        var alert: MyAlertViewControl
        
        fileprivate init(_ alert: MyAlertViewControl) {
            self.alert = alert
        }
        // Handler Aler Responder
        open func setTitle(_ title:String?){
            self.alert.labelTitle.text = title
        }
        open func setSubTitle(_ subTitle:String){
            self.alert.viewText.text = subTitle
        }
        open func hide(){
            self.alert.hideView()
        }
        open func setDismissBlock(_ dismissBlock:@escaping DismissBlock){
            self.alert.dismissBlock = dismissBlock
        }
    }
}


