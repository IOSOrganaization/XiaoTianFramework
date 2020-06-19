//
//  HRToast + UIView.swift
//  ToastDemo
//
//  Created by Rannie on 14/7/6.
//  Copyright (c) 2014年 Rannie. All rights reserved.
//  https://github.com/Rannie/Toast-Swift
//

import UIKit

/*
 *  Infix overload method
 */
func /(lhs: CGFloat, rhs: Int) -> CGFloat {
    return lhs / CGFloat(rhs)
}

/*
 *  Toast Config
 */
let HRToastDefaultDuration  =   2.0//显示持续时间
let HRToastFadeDuration     =   0.2//渐变持续时间
let HRToastHorizontalMargin : CGFloat  =   10.0//横向边距
let HRToastVerticalMargin   : CGFloat  =   10.0//纵向边距

let HRToastPositionDefault  =   "bottom"
let HRToastPositionTop      =   "top"
let HRToastPositionCenter   =   "center"

// activity
let HRToastActivityWidth  :  CGFloat  = 100.0//加载中页面Toast的宽度
let HRToastActivityHeight :  CGFloat  = 100.0
let HRToastActivityPositionDefault    = "center"//加载中页面位置

// image size
let HRToastImageViewWidth :  CGFloat  = 80.0//图片宽度
let HRToastImageViewHeight:  CGFloat  = 80.0

// label setting
let HRToastMaxWidth       :  CGFloat  = 0.8;//最大宽度 80% of parent view width
let HRToastMaxHeight      :  CGFloat  = 0.8;//最大高度
let HRToastFontSize       :  CGFloat  = 16.0//字体大小
let HRToastMaxTitleLines              = 0//最大行数
let HRToastMaxMessageLines            = 0//最大行数

// shadow appearance
let HRToastShadowOpacity  : CGFloat   = 0.2 //阴影透明度
let HRToastShadowRadius   : CGFloat   = 6.0 //阴影圆角半径
let HRToastShadowOffset   : CGSize    = CGSize(width: CGFloat(3.0), height: CGFloat(3.0)) //阴影偏移

let HRToastOpacity        : CGFloat   = 0.4 //背景色透明度
let HRToastCornerRadius   : CGFloat   = 10.0 //背景圆角半径

var HRToastActivityView: UnsafePointer<UIView>?    =   nil
var HRToastTimer: UnsafePointer<Timer>?          =   nil
var HRToastView: UnsafePointer<UIView>?            =   nil
var HRToastThemeColor : UnsafePointer<UIColor>?    =   nil
var HRToastTitleFontName: UnsafePointer<String>?   =   nil
var HRToastFontName: UnsafePointer<String>?        =   nil
var HRToastFontColor: UnsafePointer<UIColor>?      =   nil

/*
 *  Custom Config
 */
let HRToastHidesOnTap       =   true
let HRToastDisplayShadow    =   true

@objc(UtilToastXT)
open class UtilToast : NSObject{
    var rootView:UIView?
    
    override init() {
        fatalError("UtilToast错误: 不能调用无参构造器进行初始化.")
    }
    // 构造器
    init(rootView:UIView?){
        self.rootView = rootView
    }
    
    convenience init(viewController:UIViewController?){
        self.init(rootView:viewController?.view)
    }
    
    class func toast(_ message:String){
        
    }
    // Toast Message
    func toast(_ message:String){
        self.rootView?.makeToast(message: message)
    }
    
    // Toast Loading
    func toastActivity(){
        self.rootView?.makeToastActivity()
    }
    // hide Loading
    func hideActivity(){
        self.rootView?.hideToastActivity()
    }
}

//HRToast (UIView + Toast using Swift)
extension UIView {
    
    /*
     *  public methods
     */
    class func hr_setToastThemeColor(color: UIColor) {
        objc_setAssociatedObject(self, &HRToastThemeColor, color, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func hr_toastThemeColor() -> UIColor {
        var color = objc_getAssociatedObject(self, &HRToastThemeColor) as! UIColor?
        if color == nil {
            color = UIColor.black
            UIView.hr_setToastThemeColor(color: color!)
        }
        return color!
    }
    
    class func hr_setToastTitleFontName(fontName: String) {
        objc_setAssociatedObject(self, &HRToastTitleFontName, fontName, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func hr_toastTitleFontName() -> String {
        var name = objc_getAssociatedObject(self, &HRToastTitleFontName) as! String?
        if name == nil {
            let font = UIFont.systemFont(ofSize: 12.0)
            name = font.fontName
            UIView.hr_setToastTitleFontName(fontName: name!)
        }
        
        return name!
    }
    
    class func hr_setToastFontName(fontName: String) {
        objc_setAssociatedObject(self, &HRToastFontName, fontName, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func hr_toastFontName() -> String {
        var name = objc_getAssociatedObject(self, &HRToastFontName) as! String?
        if name == nil {
            let font = UIFont.systemFont(ofSize: 12.0)
            name = font.fontName
            UIView.hr_setToastFontName(fontName: name!)
        }
        
        return name!
    }
    
    class func hr_setToastFontColor(color: UIColor) {
        objc_setAssociatedObject(self, &HRToastFontColor, color, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func hr_toastFontColor() -> UIColor {
        var color = objc_getAssociatedObject(self, &HRToastFontColor) as! UIColor?
        if color == nil {
            color = UIColor.white
            UIView.hr_setToastFontColor(color: color!)
        }
        
        return color!
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // toast 一个字符串
    func makeToast(message msg: String) {
        self.makeToast(message: msg, duration: HRToastDefaultDuration, position: HRToastPositionDefault as AnyObject)
    }
    // toast 一个字符串(持续时间,相对位置)
    func makeToast(message msg: String, duration: Double, position: AnyObject) {
        let toast = self.viewForMessage(msg, title: nil, image: nil) // 创建要显示的Toast UIView
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    // toast 一个字符串+标题
    func makeToast(message msg: String, duration: Double, position: AnyObject, title: String) {
        let toast = self.viewForMessage(msg, title: title, image: nil)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    // toast 一个字符串+图片
    func makeToast(message msg: String, duration: Double, position: AnyObject, image: UIImage) {
        let toast = self.viewForMessage(msg, title: nil, image: image)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    // toast 一个字符串+标题+图片
    func makeToast(message msg: String, duration: Double, position: AnyObject, title: String, image: UIImage) {
        let toast = self.viewForMessage(msg, title: title, image: image)
        self.showToast(toast: toast!, duration: duration, position: position)
    }
    // toast 一个UIView
    func showToast(toast: UIView) {
        self.showToast(toast: toast, duration: HRToastDefaultDuration, position: HRToastPositionDefault as AnyObject)
    }
    // 执行toast显示
    fileprivate func showToast(toast: UIView, duration: Double, position: AnyObject) {
        // 获取已经关联的Toast对象 (target, key)
        let existToast = objc_getAssociatedObject(self, &HRToastView) as! UIView?
        if let existToast = existToast{
            // 取消定时器
            if let timer: Timer = objc_getAssociatedObject(existToast, &HRToastTimer) as? Timer {
                timer.invalidate();
            }
            // 隐藏当前Toast
            self.hideToast(toast: existToast, force: false);
        }
        // View的中点
        toast.center = self.centerPointForPosition(position, toast: toast)
        toast.alpha = 0.0 // 透明
        // 点击隐藏事件
        if HRToastHidesOnTap {
            let tapRecognizer = UITapGestureRecognizer(target: toast, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(tapRecognizer)
            toast.isUserInteractionEnabled = true;
            toast.isExclusiveTouch = true;
        }
        // 添加到UIView
        self.addSubview(toast)
        objc_setAssociatedObject(self, &HRToastView, toast, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        //
        UIView.animate(withDuration: HRToastFadeDuration, delay: 0.0, options: ([.curveEaseOut, .allowUserInteraction]), animations: {
            toast.alpha = 1.0 // 渐变显示[透明到不透明]
            }, completion: {
                (finished: Bool) in
                // 显示完成,启动隐藏定时器
                let timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
                // 绑定定时器到toast的UIView中(target,key,value,policy[非原子引用])
                objc_setAssociatedObject(toast, &HRToastTimer, timer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // toast 一个加载中页面
    func makeToastActivity() {
        self.makeToastActivity(position: HRToastActivityPositionDefault as AnyObject)
    }
    // toast 一个String加载中页面
    func makeToastActivity(message msg: String){
        self.makeToastActivity(position: HRToastActivityPositionDefault as AnyObject, message: msg)
    }
    // toast 一个String加载中页面(相对位置)
    fileprivate func makeToastActivity(position pos: AnyObject, message msg: String = "") {
        // 获取已添加的页面[如果已添加]
        let existingActivityView: UIView? = objc_getAssociatedObject(self, &HRToastActivityView) as? UIView
        if existingActivityView != nil { // 当前有加载中页面显示,结束返回
            return
        }
        // 创建加载中页面的UIView
        let activityView = UIView(frame: CGRect(x: 0, y: 0, width: HRToastActivityWidth, height: HRToastActivityHeight))
        activityView.center = self.centerPointForPosition(pos, toast: activityView)//设置中点==显示父类的中点
        //activityView.backgroundColor = UIView.hr_toastThemeColor().colorWithAlphaComponent(HRToastOpacity)//背景色
        activityView.backgroundColor = UIView.hr_toastThemeColor().withAlphaComponent(0.25)
        activityView.alpha = 0.0 //透明
        activityView.autoresizingMask = ([.flexibleLeftMargin, .flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin])//自动大小限制[固定margin]
        activityView.layer.cornerRadius = HRToastCornerRadius //圆角
        // 显示阴影
        if HRToastDisplayShadow {
            activityView.layer.shadowColor = UIView.hr_toastThemeColor().cgColor
            activityView.layer.shadowOpacity = Float(HRToastShadowOpacity)
            activityView.layer.shadowRadius = HRToastShadowRadius
            activityView.layer.shadowOffset = HRToastShadowOffset
        }
        // 菊花指示器
        //let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        let activityIndicatorView = MyLogoIndicator()
        activityIndicatorView.center = CGPoint(x: activityView.bounds.size.width / 2, y: activityView.bounds.size.height / 2)//居toast中间
        activityView.addSubview(activityIndicatorView)
        //activityIndicatorView.startAnimating()//开始转
        // message String字符串
        if (!msg.isEmpty){
            activityIndicatorView.frame.origin.y -= 10 //y起点-10[上移10]
            let activityMessageLabel = UILabel(frame: CGRect(x: activityView.bounds.origin.x, y: (activityIndicatorView.frame.origin.y + activityIndicatorView.frame.size.height + 10), width: activityView.bounds.size.width, height: 20))//创建UILabel[宽满,高20]
            activityMessageLabel.textColor = UIView.hr_toastFontColor()//Text颜色
            activityMessageLabel.font = (msg.count<=10) ? UIFont(name:UIView.hr_toastFontName(), size: 16) : UIFont(name:UIView.hr_toastFontName(), size: 13)//Text字体
            activityMessageLabel.textAlignment = .center//对齐方式
            activityMessageLabel.text = msg
            activityView.addSubview(activityMessageLabel)//添加UILabel
        }
        // 添加加载页面到父UIView
        self.addSubview(activityView)
        // 绑定到父UIView[缓存]
        // associate activity view with self
        objc_setAssociatedObject(self, &HRToastActivityView, activityView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // 渐变显示
        UIView.animate(withDuration: HRToastFadeDuration, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            activityView.alpha = 1.0
        }, completion: nil)
    }
    
    // 隐藏Toast 加载中页面
    func hideToastActivity() {
        // 在父UIView中获取绑定的toast UIView
        let existingActivityView = objc_getAssociatedObject(self, &HRToastActivityView) as! UIView?
        if existingActivityView == nil {
            return
        }
        // 渐变隐藏
        UIView.animate(withDuration: HRToastFadeDuration, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            existingActivityView!.alpha = 0.0
            }, completion: {
                (finished: Bool) in
                // 从父UIView中移除加载中页面
                existingActivityView!.removeFromSuperview()
                // 删除绑定[绑定设置为nil]
                objc_setAssociatedObject(self, &HRToastActivityView, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }
    
    /*
     *  隐藏指定的Toast UIView
     *  private methods (helper)
     */
    func hideToast(toast: UIView) {
        self.hideToast(toast: toast, force: false);
    }
    
    func hideToast(toast: UIView, force: Bool) {
        let completeClosure = { // 匿名函数[变量引用]
            (finish: Bool) -> () in
            // 移除UIView
            toast.removeFromSuperview()
            // 删除绑定
            objc_setAssociatedObject(self, &HRToastTimer, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        if force {
            // 直接隐藏
            completeClosure(true)
        } else {
            // 动态渐变隐藏
            UIView.animate(withDuration: HRToastFadeDuration, delay: 0.0, options: ([.curveEaseIn, .beginFromCurrentState]), animations: {
                toast.alpha = 0.0
                }, completion:completeClosure)
        }
    }
    // 定时器到时完成结束
    @objc func toastTimerDidFinish(_ timer: Timer) {
        self.hideToast(toast: timer.userInfo as! UIView)
    }
    // 处理toast点击事件
    @objc func handleToastTapped(_ recognizer: UITapGestureRecognizer) {
        let timer = objc_getAssociatedObject(self, &HRToastTimer) as? Timer
        if timer != nil{
            timer!.invalidate()
        }
        self.hideToast(toast: recognizer.view!)
    }
    
    // 获取对象相对于UIView的位置
    fileprivate func centerPointForPosition(_ position: AnyObject, toast: UIView) -> CGPoint {
        if position is String {
            let toastSize = toast.bounds.size
            let viewSize  = self.bounds.size
            if position.lowercased == HRToastPositionTop {
                // 顶部
                return CGPoint(x: viewSize.width/2, y: toastSize.height/2 + HRToastVerticalMargin)
            } else if position.lowercased == HRToastPositionDefault {
                // 下部
                return CGPoint(x: viewSize.width/2, y: viewSize.height - toastSize.height/2 - HRToastVerticalMargin)
            } else if position.lowercased == HRToastPositionCenter {
                // 中间
                return CGPoint(x: viewSize.width/2, y: viewSize.height/2)
            }
        } else if position is NSValue {
            return position.cgPointValue
        }
        
        print("Warning: Invalid position for toast.")
        return self.centerPointForPosition(HRToastPositionDefault as AnyObject, toast: toast)
    }
    
    // 创建要显示的Toast UIView
    fileprivate func viewForMessage(_ msg: String?, title: String?, image: UIImage?) -> UIView? {
        if msg == nil && title == nil && image == nil {
            return nil
        }
        
        var msgLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?
        
        // 根UIView容器
        let wrapperView = UIView()
        wrapperView.autoresizingMask = ([.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin])//自动大小[固定Margin以覆盖]
        wrapperView.layer.cornerRadius = HRToastCornerRadius//圆角
        wrapperView.backgroundColor = UIView.hr_toastThemeColor().withAlphaComponent(HRToastOpacity)//背景
        // 显示阴影
        if HRToastDisplayShadow {
            wrapperView.layer.shadowColor = UIView.hr_toastThemeColor().cgColor
            wrapperView.layer.shadowOpacity = Float(HRToastShadowOpacity)
            wrapperView.layer.shadowRadius = HRToastShadowRadius
            wrapperView.layer.shadowOffset = HRToastShadowOffset
        }
        // 有图片
        if image != nil {
            imageView = UIImageView(image: image)
            imageView!.contentMode = .scaleAspectFit
            imageView!.frame = CGRect(x: HRToastHorizontalMargin, y: HRToastVerticalMargin, width: CGFloat(HRToastImageViewWidth), height: CGFloat(HRToastImageViewHeight))
        }
        
        var imageWidth: CGFloat, imageHeight: CGFloat, imageLeft: CGFloat
        if imageView != nil {
            imageWidth = imageView!.bounds.size.width
            imageHeight = imageView!.bounds.size.height
            imageLeft = HRToastHorizontalMargin
        } else {
            imageWidth  = 0.0; imageHeight = 0.0; imageLeft   = 0.0
        }
        // 标题UILabel
        if title != nil {
            titleLabel = UILabel()
            titleLabel!.numberOfLines = HRToastMaxTitleLines//
            titleLabel!.font = UIFont(name: UIView.hr_toastFontName(), size: HRToastFontSize)//字体
            titleLabel!.textAlignment = .center//对齐居中
            titleLabel!.lineBreakMode = .byWordWrapping//以单词断行
            titleLabel!.textColor = UIView.hr_toastFontColor()//Text颜色
            titleLabel!.backgroundColor = UIColor.clear//背景色
            titleLabel!.alpha = 1.0
            titleLabel!.text = title
            // 根据UILabel的Text字体和大小,计算UILabel的大小,设置大小
            // size the title label according to the length of the text
            let maxSizeTitle = CGSize(width: (self.bounds.size.width * HRToastMaxWidth) - imageWidth, height: self.bounds.size.height * HRToastMaxHeight);
            let expectedHeight = title!.stringHeightWithFontSize(HRToastFontSize, width: maxSizeTitle.width)
            titleLabel!.frame = CGRect(x: 0.0, y: 0.0, width: maxSizeTitle.width, height: expectedHeight)
        }
        // message UILabel
        if msg != nil {
            msgLabel = UILabel();
            msgLabel!.numberOfLines = HRToastMaxMessageLines
            msgLabel!.font = UIFont(name: UIView.hr_toastFontName(), size: HRToastFontSize)
            msgLabel!.lineBreakMode = .byWordWrapping
            msgLabel!.textAlignment = .center
            msgLabel!.textColor = UIView.hr_toastFontColor()
            msgLabel!.backgroundColor = UIColor.clear
            msgLabel!.alpha = 1.0
            msgLabel!.text = msg
            // 根据Text的文本,设置大小
            let maxSizeMessage = CGSize(width: (self.bounds.size.width * HRToastMaxWidth) - imageWidth, height: self.bounds.size.height * HRToastMaxHeight)
            let expectedHeight = msg!.stringHeightWithFontSize(HRToastFontSize, width: maxSizeMessage.width)
            msgLabel!.frame = CGRect(x: 0.0, y: 0.0, width: maxSizeMessage.width, height: expectedHeight)
        }
        // 计算Title的位置
        var titleWidth: CGFloat, titleHeight: CGFloat, titleTop: CGFloat, titleLeft: CGFloat
        if titleLabel != nil {
            titleWidth = titleLabel!.bounds.size.width
            titleHeight = titleLabel!.bounds.size.height
            titleTop = HRToastVerticalMargin
            titleLeft = imageLeft + imageWidth + HRToastHorizontalMargin
        } else {
            titleWidth = 0.0; titleHeight = 0.0; titleTop = 0.0; titleLeft = 0.0
        }
        // 计算Message的位置
        var msgWidth: CGFloat, msgHeight: CGFloat, msgTop: CGFloat, msgLeft: CGFloat
        if msgLabel != nil {
            msgWidth = msgLabel!.bounds.size.width
            msgHeight = msgLabel!.bounds.size.height
            msgTop = titleTop + titleHeight + HRToastVerticalMargin
            msgLeft = imageLeft + imageWidth + HRToastHorizontalMargin
        } else {
            msgWidth = 0.0; msgHeight = 0.0; msgTop = 0.0; msgLeft = 0.0
        }
        // 获取合法宽高[最大者]
        let largerWidth = max(titleWidth, msgWidth)
        let largerLeft  = max(titleLeft, msgLeft)
        // 获取适配UIView的宽高
        // set wrapper view's frame
        let wrapperWidth  = max(imageWidth + HRToastHorizontalMargin * 2, largerLeft + largerWidth + HRToastHorizontalMargin)
        let wrapperHeight = max(msgTop + msgHeight + HRToastVerticalMargin, imageHeight + HRToastVerticalMargin * 2)
        wrapperView.frame = CGRect(x: 0.0, y: 0.0, width: wrapperWidth, height: wrapperHeight)
        // 添加Title
        // add subviews
        if titleLabel != nil {
            titleLabel!.frame = CGRect(x: titleLeft, y: titleTop, width: titleWidth, height: titleHeight)
            wrapperView.addSubview(titleLabel!)
        }
        // 添加Message
        if msgLabel != nil {
            msgLabel!.frame = CGRect(x: msgLeft, y: msgTop, width: msgWidth, height: msgHeight)
            wrapperView.addSubview(msgLabel!)
        }
        // 添加Image
        if imageView != nil {
            wrapperView.addSubview(imageView!)
        }
        return wrapperView
    }
    
}

extension String{
    // 根据指定字体大小计算所占高度
    func stringHeightWithFontSize(_ fontSize: CGFloat,width: CGFloat) -> CGFloat {
        let font = UIFont(name: UIView.hr_toastFontName(), size: HRToastFontSize)
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping;
        let attributes = [NSAttributedString.Key.font:font!, NSAttributedString.Key.paragraphStyle:paragraphStyle.copy()]
        
        let text = self as NSString
        let rect = text.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }
    
}
