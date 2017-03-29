//
//  MyUILabel.swift
//  DriftBook
//  自定义UILabel
//  Created by XiaoTian on 16/7/24.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@IBDesignable
class MyUILabel: UILabel{
    //
    enum Type: String {
        case Normal // 默认
        case Title  // 标题
        case Item   // 列表
        case Label  // 标签
        case Value  // 标签值
        case Button // 按钮
        case Tip    // 提示文本
    }
    enum Color: String {
        case Black  // 黑色
        case White  // 白色
        case Gray   // 灰色
        case Hint   // 提示文本颜色
        case Primary// 主题色
        case Red    // 红色
    }
    /// IB 配置 Type类型,声明[字体+大小+颜色]类型
    @IBInspectable var type: String = "" {
        didSet{ // Setting
        }
    }
    /// IB 配置 Text颜色类型[获取UtilColor配置中的常用颜色],声明颜色类型
    @IBInspectable var colorType: String = "" {
        didSet { // Setting 后侦听器
        }
    }
    // IB 点击事件绑定,eg: onClickAction[无参数], onClickAction:[包含一个参数UIView]
    @IBInspectable var onClickAction: String = ""
    @IBInspectable var onClickColor: UIColor = UIColor(colorLiteralRed: 208/255.0, green: 208/255.0, blue: 208/255.0, alpha: 1)
    // IB 支持的类型: Int CGFloat Double String Bool CGPoint CGSize CGRect UIColor UIImage
    
    //
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Nib 初始加载完成
    override func awakeFromNib() {
        // IB 配置样式,颜色
        var color: UIColor! { // 颜色
            get{
                if let colorType = Color(rawValue: self.colorType){
                    switch colorType {
                    case .Black: return utilShared.color.textBlack
                    case .White: return utilShared.color.textWhite
                    case .Gray: return utilShared.color.textGray
                    case .Hint: return utilShared.color.textHint
                    case .Primary: return utilShared.color.primaryColor
                    case .Red: return utilShared.color.textRed
                    }
                }
                return nil
            }
        }
        if let type = Type(rawValue: self.type){ // 类型
            switch type {
            case .Normal:
                self.font = utilShared.font.textNormal
                self.textColor = color != nil ? color : utilShared.color.textBlack
                break
            case .Item:
                self.font = utilShared.font.textItem
                self.textColor = color != nil ? color : utilShared.color.textBlack
                break
            case .Label:
                self.font = utilShared.font.textLabel
                self.textColor = color != nil ? color : utilShared.color.textBlack
                break
            case .Value:
                self.font = utilShared.font.textLabel
                self.textColor = color != nil ? color : utilShared.color.textBlack
                break
            case .Title:
                self.font = utilShared.font.textTitle
                self.textColor = color != nil ? color : utilShared.color.textBlack
                break
            case .Button:
                self.margin = 10
                self.layer.cornerRadius = 3
                self.layer.masksToBounds = true
                self.font = utilShared.font.textButton
                self.backgroundColor = utilShared.color.primaryColor
                self.textColor = color != nil ? color : utilShared.color.textWhite
                break
            case .Tip:
                self.font = utilShared.font.textNewTip
                self.textColor = color != nil ? color : utilShared.color.textRed
                break
            }
        }
        // 配置的点击事件
        if onClickAction != "" {
            // 获取当前 Responder 链中包含该Selector的第一个Responder
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
                    // 执行绑定的 OnClickAction [最多传递一个参数]
                    wResponder.performSelector(Selector(wSelf.onClickAction), withObject: wSelf)
                }
            }
        }
    }
    
    // Clickable 点击事件控制
    var tabFunction:((view:MyUILabel)->())?
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
    func setOnTabListener(onTabListener:(view:MyUILabel)->()){
        clickableInit()
        clickableExt = true
        self.tabFunction = onTabListener
    }
    // 设置Tabed的背景色
    func setTabedBackground(color:UIColor){
        clickableInit()
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
        onTabAction()
    }
    
    /// 背景色是否可以改变[控制点击时不Tint改变背景色]
    var changableBackground = true
    var touchAble = false
    override internal var backgroundColor: UIColor? { //覆盖背景颜色属性
        didSet {
            // 如果背景取消改变,则不执行改变
            super.backgroundColor = changableBackground ? backgroundColor : oldValue
        }
    }
    
    // UIButton.contentEdgeInsets : 在内容插入边界[Margin]
    var marginLeft, marginTop, marginRight, marginBottom: CGFloat!
    var margin: CGFloat!{
        willSet{
            marginLeft = newValue
            marginTop = newValue
            marginRight = newValue
            marginBottom = newValue
        }
    }
    
    override func drawTextInRect(rect:CGRect){
        if marginLeft != nil && marginTop != nil && marginRight != nil && marginBottom != nil{
            let insets = UIEdgeInsets(top: marginTop, left: marginLeft, bottom: marginBottom, right: marginRight)
            super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
        } else {
            super.drawTextInRect(rect)
        }
    }
    
    func setMargin(marginLeft:CGFloat!, marginTop:CGFloat!, marginRight:CGFloat!, marginBottom:CGFloat!){
        self.marginLeft = marginLeft
        self.marginTop = marginTop
        self.marginRight = marginRight
        self.marginTop = marginTop
    }
}
// ## Extension UIView Clickable
private var tabDataAssociationKey: UInt8 = 0
private var tabFunctionAssociationKey: UInt8 = 0
private var clickableAssociationKey: UInt8 = 0
private var backgroundViewAssociationKey: UInt8 = 0
private extension MyUILabel {
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
        if backgroundViewExt == nil {
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