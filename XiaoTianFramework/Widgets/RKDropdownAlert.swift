//
//  RKDropdownAlert.swift
//  DriftBook
//
//  Created by 郭天蕊 on 2016/12/19.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
class RKDropdownAlert: UIView{
    static let TAG = "RKDropdownAlert"
    let HEIGHT:CGFloat = 90
    let ANIMATION_TIME:NSTimeInterval = 0.3
    let X_BUFFER:CGFloat = 10
    let Y_BUFFER:CGFloat = 10
    let TIME:NSTimeInterval = 3
    let STATUS_BAR_HEIGHT:CGFloat = 20
    let FONT_SIZE:CGFloat = 14
    //
    var DEFAULT_TITLE = "Default Text Here"
    var delegate:RKDropdownAlertDelegate!
    var isShowing:Bool = false
    var defaultTextColor:UIColor = UIColor.whiteColor()
    var defaultViewColor:UIColor = UIColor(red: 0.98, green: 0.66, blue: 0.2, alpha: 1)
    //
    var titleLabel: UILabel!
    var messageLabel: UILabel!
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        // 初始化 View
        backgroundColor = defaultViewColor
        titleLabel = UILabel(frame: CGRectMake(X_BUFFER, STATUS_BAR_HEIGHT, frame.size.width - 2 * X_BUFFER, 30))
        titleLabel.font = UIFont(name: "Arial-BoldMT", size: FONT_SIZE)
        titleLabel.textColor = defaultTextColor
        titleLabel.textAlignment = .Center
        self.addSubview(titleLabel)
        messageLabel = UILabel(frame: CGRectMake(X_BUFFER, STATUS_BAR_HEIGHT + Y_BUFFER * 2.3, frame.size.width - 2 * X_BUFFER, 40))
        messageLabel.font = messageLabel.font.fontWithSize(FONT_SIZE)
        messageLabel.textColor = defaultTextColor
        messageLabel.lineBreakMode = .ByWordWrapping
        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .Center
        self.addSubview(messageLabel)
        self.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(viewWasTapped)))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(dismissAlertView), name: RKDropdownAlert.TAG, object: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Can Not Init RKDropdownAlert By Nib.")
    }
    func viewWasTapped(){
        if delegate != nil && delegate.dropdownAlertWasTapped(self){
            hideView(self)
        } else {
            hideView(self)
        }
    }
    func dismissAlertView(){
        hideView(self)
    }
    func hideView(alert:RKDropdownAlert!){
        if alert != nil{
            // 动态隐藏y 轴[0 ~ -90]
            UIView.animateWithDuration(ANIMATION_TIME){
                [weak self]params in
                    if let wSelf = self{
                    var frame = alert.frame
                    frame.origin.y = -wSelf.HEIGHT
                    alert.frame = frame
                }
            }
            // 等待动画完成后 removeView
            performSelector(#selector(removeView), withObject: alert, afterDelay: ANIMATION_TIME)
        }
    }
    func removeView(alert:RKDropdownAlert!){
        if alert != nil{
            alert.removeFromSuperview()
            self.isShowing = false
            if delegate != nil{
                delegate.dropdownAlertWasDismissed()
            }
        }
    }
    func messageTextIsOnLine() -> Bool{
        let size = (messageLabel.text! as NSString).sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(FONT_SIZE)])
        if size.width > messageLabel.frame.size.width{
            return false
        }
        return true
    }
    
    func alert(title:String?,_ message:String?,_ backgroundColor:UIColor?,_ textColor:UIColor?,_ duration:Int){
        var time:NSTimeInterval = NSTimeInterval(duration)
        titleLabel.text = title
        if message != nil && message!.characters.count > 0{
            // 有 Message 的话, Title 靠上
            messageLabel.text = message
            if messageTextIsOnLine(){
                var frame = titleLabel.frame
                frame.origin.y = STATUS_BAR_HEIGHT + 5
                titleLabel.frame = frame
            }
        } else {
            // 没有 Message 的话, Title 居中
            var frame = titleLabel.frame
            frame.size.height = HEIGHT - 2*Y_BUFFER - STATUS_BAR_HEIGHT
            frame.origin.y = Y_BUFFER + STATUS_BAR_HEIGHT
            titleLabel.frame = frame
        }
        if backgroundColor != nil{
            self.backgroundColor = backgroundColor
        }
        if textColor != nil{
            titleLabel.textColor = textColor
            messageLabel.textColor = textColor
        }
        if duration == -1{
            time = TIME
        }
        // 加入 View 到最前的 window 中
        if superview == nil{
            let frontToBackWindows = UIApplication.sharedApplication().windows.reverse()
            for windows in frontToBackWindows{
                if windows.windowLevel == UIWindowLevelNormal && windows.hidden == false{
                    windows.addSubview(self)
                    break
                }
            }
        }
        isShowing = true
        // 动画出现,y 轴值[-90 ~ 0]
        UIView.animateWithDuration(ANIMATION_TIME) {
            [weak self] in
            if let wSelf = self{
                var frame = wSelf.frame
                frame.origin.y = 0
                wSelf.frame = frame
            }
        }
        performSelector(#selector(hideView), withObject: self, afterDelay: time + ANIMATION_TIME)
    }
    /// Static Method
    static func dismissAllAlert(){
        NSNotificationCenter.defaultCenter().postNotificationName(RKDropdownAlert.TAG, object: nil)
    }
    static func alert(title:String?,_ message:String?){
        let alert = alertViewWithDelegate(nil)
        alert.alert(title, message, UIColor(red: 0.98, green: 0.66, blue: 0.2, alpha: 1), UIColor.whiteColor(), -1)
    }
    static func alert(title:String?,_ message:String?,_ backgroundColor:UIColor?,_ textColor:UIColor?){
        let alert = alertViewWithDelegate(nil)
        alert.alert(title, message, backgroundColor, textColor, -1)
    }
    // 静态构造
    static func alertViewWithDelegate(delegate: RKDropdownAlertDelegate?) -> RKDropdownAlert{
        // (0, -90, screenWidth, 90)
        let alert = RKDropdownAlert(frame: CGRectMake(0, -90,UIScreen.mainScreen().bounds.size.width, 90))
        alert.delegate = delegate
        return alert
    }
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
protocol RKDropdownAlertDelegate {
    func dropdownAlertWasTapped(alert:RKDropdownAlert) -> Bool
    func dropdownAlertWasDismissed() -> Bool
}