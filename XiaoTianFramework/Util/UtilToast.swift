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
let HRToastShadowOffset   : CGSize    = CGSizeMake(CGFloat(3.0), CGFloat(3.0)) //阴影偏移

let HRToastOpacity        : CGFloat   = 0.4 //背景色透明度
let HRToastCornerRadius   : CGFloat   = 10.0 //背景圆角半径

var HRToastActivityView: UnsafePointer<UIView>    =   nil
var HRToastTimer: UnsafePointer<NSTimer>          =   nil
var HRToastView: UnsafePointer<UIView>            =   nil
var HRToastThemeColor : UnsafePointer<UIColor>    =   nil
var HRToastTitleFontName: UnsafePointer<String>   =   nil
var HRToastFontName: UnsafePointer<String>        =   nil
var HRToastFontColor: UnsafePointer<UIColor>      =   nil

/*
 *  Custom Config
 */
let HRToastHidesOnTap       =   true
let HRToastDisplayShadow    =   true

@objc(UtilToastXT)
class UtilToast : NSObject{
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
    
    class func toast(message:String){
        
    }
    // Toast Message
    func toast(message:String){
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
    class func hr_setToastThemeColor(color color: UIColor) {
        objc_setAssociatedObject(self, &HRToastThemeColor, color, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func hr_toastThemeColor() -> UIColor {
        var color = objc_getAssociatedObject(self, &HRToastThemeColor) as! UIColor?
        if color == nil {
            color = UIColor.blackColor()
            UIView.hr_setToastThemeColor(color: color!)
        }
        return color!
    }
    
    class func hr_setToastTitleFontName(fontName fontName: String) {
        objc_setAssociatedObject(self, &HRToastTitleFontName, fontName, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func hr_toastTitleFontName() -> String {
        var name = objc_getAssociatedObject(self, &HRToastTitleFontName) as! String?
        if name == nil {
            let font = UIFont.systemFontOfSize(12.0)
            name = font.fontName
            UIView.hr_setToastTitleFontName(fontName: name!)
        }
        
        return name!
    }
    
    class func hr_setToastFontName(fontName fontName: String) {
        objc_setAssociatedObject(self, &HRToastFontName, fontName, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func hr_toastFontName() -> String {
        var name = objc_getAssociatedObject(self, &HRToastFontName) as! String?
        if name == nil {
            let font = UIFont.systemFontOfSize(12.0)
            name = font.fontName
            UIView.hr_setToastFontName(fontName: name!)
        }
        
        return name!
    }
    
    class func hr_setToastFontColor(color color: UIColor) {
        objc_setAssociatedObject(self, &HRToastFontColor, color, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    class func hr_toastFontColor() -> UIColor {
        var color = objc_getAssociatedObject(self, &HRToastFontColor) as! UIColor?
        if color == nil {
            color = UIColor.whiteColor()
            UIView.hr_setToastFontColor(color: color!)
        }
        
        return color!
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // toast 一个字符串
    func makeToast(message msg: String) {
        self.makeToast(message: msg, duration: HRToastDefaultDuration, position: HRToastPositionDefault)
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
    func showToast(toast toast: UIView) {
        self.showToast(toast: toast, duration: HRToastDefaultDuration, position: HRToastPositionDefault)
    }
    // 执行toast显示
    private func showToast(toast toast: UIView, duration: Double, position: AnyObject) {
        // 获取已经关联的Toast对象 (target, key)
        let existToast = objc_getAssociatedObject(self, &HRToastView) as! UIView?
        if existToast != nil {
            // 取消定时器
            if let timer: NSTimer = objc_getAssociatedObject(existToast, &HRToastTimer) as? NSTimer {
                timer.invalidate();
            }
            // 隐藏当前Toast
            self.hideToast(toast: existToast!, force: false);
        }
        // View的中点
        toast.center = self.centerPointForPosition(position, toast: toast)
        toast.alpha = 0.0 // 透明
        // 点击隐藏事件
        if HRToastHidesOnTap {
            let tapRecognizer = UITapGestureRecognizer(target: toast, action: #selector(UIView.handleToastTapped(_:)))
            toast.addGestureRecognizer(tapRecognizer)
            toast.userInteractionEnabled = true;
            toast.exclusiveTouch = true;
        }
        // 添加到UIView
        self.addSubview(toast)
        objc_setAssociatedObject(self, &HRToastView, toast, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        //
        UIView.animateWithDuration(HRToastFadeDuration, delay: 0.0, options: ([.CurveEaseOut, .AllowUserInteraction]), animations: {
            toast.alpha = 1.0 // 渐变显示[透明到不透明]
            }, completion: {
                (finished: Bool) in
                // 显示完成,启动隐藏定时器
                let timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: #selector(UIView.toastTimerDidFinish(_:)), userInfo: toast, repeats: false)
                // 绑定定时器到toast的UIView中(target,key,value,policy[非原子引用])
                objc_setAssociatedObject(toast, &HRToastTimer, timer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        })
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    // toast 一个加载中页面
    func makeToastActivity() {
        self.makeToastActivity(position: HRToastActivityPositionDefault)
    }
    // toast 一个String加载中页面
    func makeToastActivity(message msg: String){
        self.makeToastActivity(position: HRToastActivityPositionDefault, message: msg)
    }
    // toast 一个String加载中页面(相对位置)
    private func makeToastActivity(position pos: AnyObject, message msg: String = "") {
        // 获取已添加的页面[如果已添加]
        let existingActivityView: UIView? = objc_getAssociatedObject(self, &HRToastActivityView) as? UIView
        if existingActivityView != nil { // 当前有加载中页面显示,结束返回
            return
        }
        // 创建加载中页面的UIView
        let activityView = UIView(frame: CGRectMake(0, 0, HRToastActivityWidth, HRToastActivityHeight))
        activityView.center = self.centerPointForPosition(pos, toast: activityView)//设置中点==显示父类的中点
        //activityView.backgroundColor = UIView.hr_toastThemeColor().colorWithAlphaComponent(HRToastOpacity)//背景色
        activityView.backgroundColor = UIView.hr_toastThemeColor().colorWithAlphaComponent(0.25)
        activityView.alpha = 0.0 //透明
        activityView.autoresizingMask = ([.FlexibleLeftMargin, .FlexibleTopMargin, .FlexibleRightMargin, .FlexibleBottomMargin])//自动大小限制[固定margin]
        activityView.layer.cornerRadius = HRToastCornerRadius //圆角
        // 显示阴影
        if HRToastDisplayShadow {
            activityView.layer.shadowColor = UIView.hr_toastThemeColor().CGColor
            activityView.layer.shadowOpacity = Float(HRToastShadowOpacity)
            activityView.layer.shadowRadius = HRToastShadowRadius
            activityView.layer.shadowOffset = HRToastShadowOffset
        }
        // 菊花指示器
        //let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        let activityIndicatorView = MyLogoIndicator()
        activityIndicatorView.center = CGPointMake(activityView.bounds.size.width / 2, activityView.bounds.size.height / 2)//居toast中间
        activityView.addSubview(activityIndicatorView)
        //activityIndicatorView.startAnimating()//开始转
        // message String字符串
        if (!msg.isEmpty){
            activityIndicatorView.frame.origin.y -= 10 //y起点-10[上移10]
            let activityMessageLabel = UILabel(frame: CGRectMake(activityView.bounds.origin.x, (activityIndicatorView.frame.origin.y + activityIndicatorView.frame.size.height + 10), activityView.bounds.size.width, 20))//创建UILabel[宽满,高20]
            activityMessageLabel.textColor = UIView.hr_toastFontColor()//Text颜色
            activityMessageLabel.font = (msg.characters.count<=10) ? UIFont(name:UIView.hr_toastFontName(), size: 16) : UIFont(name:UIView.hr_toastFontName(), size: 13)//Text字体
            activityMessageLabel.textAlignment = .Center//对齐方式
            activityMessageLabel.text = msg
            activityView.addSubview(activityMessageLabel)//添加UILabel
        }
        // 添加加载页面到父UIView
        self.addSubview(activityView)
        // 绑定到父UIView[缓存]
        // associate activity view with self
        objc_setAssociatedObject(self, &HRToastActivityView, activityView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        // 渐变显示
        UIView.animateWithDuration(HRToastFadeDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
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
        UIView.animateWithDuration(HRToastFadeDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
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
    func hideToast(toast toast: UIView) {
        self.hideToast(toast: toast, force: false);
    }
    
    func hideToast(toast toast: UIView, force: Bool) {
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
            UIView.animateWithDuration(HRToastFadeDuration, delay: 0.0, options: ([.CurveEaseIn, .BeginFromCurrentState]), animations: {
                toast.alpha = 0.0
                }, completion:completeClosure)
        }
    }
    // 定时器到时完成结束
    func toastTimerDidFinish(timer: NSTimer) {
        self.hideToast(toast: timer.userInfo as! UIView)
    }
    // 处理toast点击事件
    func handleToastTapped(recognizer: UITapGestureRecognizer) {
        let timer = objc_getAssociatedObject(self, &HRToastTimer) as? NSTimer
        if timer != nil{
            timer!.invalidate()
        }
        self.hideToast(toast: recognizer.view!)
    }
    
    // 获取对象相对于UIView的位置
    private func centerPointForPosition(position: AnyObject, toast: UIView) -> CGPoint {
        if position is String {
            let toastSize = toast.bounds.size
            let viewSize  = self.bounds.size
            if position.lowercaseString == HRToastPositionTop {
                // 顶部
                return CGPointMake(viewSize.width/2, toastSize.height/2 + HRToastVerticalMargin)
            } else if position.lowercaseString == HRToastPositionDefault {
                // 下部
                return CGPointMake(viewSize.width/2, viewSize.height - toastSize.height/2 - HRToastVerticalMargin)
            } else if position.lowercaseString == HRToastPositionCenter {
                // 中间
                return CGPointMake(viewSize.width/2, viewSize.height/2)
            }
        } else if position is NSValue {
            return position.CGPointValue
        }
        
        print("Warning: Invalid position for toast.")
        return self.centerPointForPosition(HRToastPositionDefault, toast: toast)
    }
    
    // 创建要显示的Toast UIView
    private func viewForMessage(msg: String?, title: String?, image: UIImage?) -> UIView? {
        if msg == nil && title == nil && image == nil {
            return nil
        }
        
        var msgLabel: UILabel?
        var titleLabel: UILabel?
        var imageView: UIImageView?
        
        // 根UIView容器
        let wrapperView = UIView()
        wrapperView.autoresizingMask = ([.FlexibleLeftMargin, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleBottomMargin])//自动大小[固定Margin以覆盖]
        wrapperView.layer.cornerRadius = HRToastCornerRadius//圆角
        wrapperView.backgroundColor = UIView.hr_toastThemeColor().colorWithAlphaComponent(HRToastOpacity)//背景
        // 显示阴影
        if HRToastDisplayShadow {
            wrapperView.layer.shadowColor = UIView.hr_toastThemeColor().CGColor
            wrapperView.layer.shadowOpacity = Float(HRToastShadowOpacity)
            wrapperView.layer.shadowRadius = HRToastShadowRadius
            wrapperView.layer.shadowOffset = HRToastShadowOffset
        }
        // 有图片
        if image != nil {
            imageView = UIImageView(image: image)
            imageView!.contentMode = .ScaleAspectFit
            imageView!.frame = CGRectMake(HRToastHorizontalMargin, HRToastVerticalMargin, CGFloat(HRToastImageViewWidth), CGFloat(HRToastImageViewHeight))
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
            titleLabel!.textAlignment = .Center//对齐居中
            titleLabel!.lineBreakMode = .ByWordWrapping//以单词断行
            titleLabel!.textColor = UIView.hr_toastFontColor()//Text颜色
            titleLabel!.backgroundColor = UIColor.clearColor()//背景色
            titleLabel!.alpha = 1.0
            titleLabel!.text = title
            // 根据UILabel的Text字体和大小,计算UILabel的大小,设置大小
            // size the title label according to the length of the text
            let maxSizeTitle = CGSizeMake((self.bounds.size.width * HRToastMaxWidth) - imageWidth, self.bounds.size.height * HRToastMaxHeight);
            let expectedHeight = title!.stringHeightWithFontSize(HRToastFontSize, width: maxSizeTitle.width)
            titleLabel!.frame = CGRectMake(0.0, 0.0, maxSizeTitle.width, expectedHeight)
        }
        // message UILabel
        if msg != nil {
            msgLabel = UILabel();
            msgLabel!.numberOfLines = HRToastMaxMessageLines
            msgLabel!.font = UIFont(name: UIView.hr_toastFontName(), size: HRToastFontSize)
            msgLabel!.lineBreakMode = .ByWordWrapping
            msgLabel!.textAlignment = .Center
            msgLabel!.textColor = UIView.hr_toastFontColor()
            msgLabel!.backgroundColor = UIColor.clearColor()
            msgLabel!.alpha = 1.0
            msgLabel!.text = msg
            // 根据Text的文本,设置大小
            let maxSizeMessage = CGSizeMake((self.bounds.size.width * HRToastMaxWidth) - imageWidth, self.bounds.size.height * HRToastMaxHeight)
            let expectedHeight = msg!.stringHeightWithFontSize(HRToastFontSize, width: maxSizeMessage.width)
            msgLabel!.frame = CGRectMake(0.0, 0.0, maxSizeMessage.width, expectedHeight)
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
        wrapperView.frame = CGRectMake(0.0, 0.0, wrapperWidth, wrapperHeight)
        // 添加Title
        // add subviews
        if titleLabel != nil {
            titleLabel!.frame = CGRectMake(titleLeft, titleTop, titleWidth, titleHeight)
            wrapperView.addSubview(titleLabel!)
        }
        // 添加Message
        if msgLabel != nil {
            msgLabel!.frame = CGRectMake(msgLeft, msgTop, msgWidth, msgHeight)
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
    func stringHeightWithFontSize(fontSize: CGFloat,width: CGFloat) -> CGFloat {
        let font = UIFont(name: UIView.hr_toastFontName(), size: HRToastFontSize)
        let size = CGSizeMake(width, CGFloat.max)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping;
        let attributes = [NSFontAttributeName:font!, NSParagraphStyleAttributeName:paragraphStyle.copy()]
        
        let text = self as NSString
        let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size.height
    }
    
}