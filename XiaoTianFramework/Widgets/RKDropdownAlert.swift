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
    let ANIMATION_TIME:TimeInterval = 0.3
    let X_BUFFER:CGFloat = 10
    let Y_BUFFER:CGFloat = 10
    let TIME:TimeInterval = 3
    let STATUS_BAR_HEIGHT:CGFloat = 20
    let FONT_SIZE:CGFloat = 14
    //
    var DEFAULT_TITLE = "Default Text Here"
    var delegate:RKDropdownAlertDelegate!
    var isShowing:Bool = false
    var defaultTextColor:UIColor = UIColor.white
    var defaultViewColor:UIColor = UIColor(red: 0.98, green: 0.66, blue: 0.2, alpha: 1)
    //
    var titleLabel: UILabel!
    var messageLabel: UILabel!
    
    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
        // 初始化 View
        backgroundColor = defaultViewColor
        titleLabel = UILabel(frame: CGRect(x: X_BUFFER, y: STATUS_BAR_HEIGHT, width: frame.size.width - 2 * X_BUFFER, height: 30))
        titleLabel.font = UIFont(name: "Arial-BoldMT", size: FONT_SIZE)
        titleLabel.textColor = defaultTextColor
        titleLabel.textAlignment = .center
        self.addSubview(titleLabel)
        messageLabel = UILabel(frame: CGRect(x: X_BUFFER, y: STATUS_BAR_HEIGHT + Y_BUFFER * 2.3, width: frame.size.width - 2 * X_BUFFER, height: 40))
        messageLabel.font = messageLabel.font.withSize(FONT_SIZE)
        messageLabel.textColor = defaultTextColor
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.numberOfLines = 2
        messageLabel.textAlignment = .center
        self.addSubview(messageLabel)
        self.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(viewWasTapped)))
        NotificationCenter.default.addObserver(self, selector: #selector(dismissAlertView), name: NSNotification.Name(rawValue: RKDropdownAlert.TAG), object: nil)
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
    func hideView(_ alert:RKDropdownAlert!){
        if alert != nil{
            // 动态隐藏y 轴[0 ~ -90]
            UIView.animate(withDuration: ANIMATION_TIME, animations: {
                [weak self]params in
                    if let wSelf = self{
                    var frame = alert.frame
                    frame.origin.y = -wSelf.HEIGHT
                    alert.frame = frame
                }
            })
            // 等待动画完成后 removeView
            perform(#selector(removeView), with: alert, afterDelay: ANIMATION_TIME)
        }
    }
    func removeView(_ alert:RKDropdownAlert!){
        if alert != nil{
            alert.removeFromSuperview()
            self.isShowing = false
            if delegate != nil{
                delegate.dropdownAlertWasDismissed()
            }
        }
    }
    func messageTextIsOnLine() -> Bool{
        let size = (messageLabel.text! as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: FONT_SIZE)])
        if size.width > messageLabel.frame.size.width{
            return false
        }
        return true
    }
    
    func alert(_ title:String?,_ message:String?,_ backgroundColor:UIColor?,_ textColor:UIColor?,_ duration:Int){
        var time:TimeInterval = TimeInterval(duration)
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
            let frontToBackWindows = UIApplication.shared.windows.reversed()
            for windows in frontToBackWindows{
                if windows.windowLevel == UIWindowLevelNormal && windows.isHidden == false{
                    windows.addSubview(self)
                    break
                }
            }
        }
        isShowing = true
        // 动画出现,y 轴值[-90 ~ 0]
        UIView.animate(withDuration: ANIMATION_TIME, animations: {
            [weak self] in
            if let wSelf = self{
                var frame = wSelf.frame
                frame.origin.y = 0
                wSelf.frame = frame
            }
        }) 
        perform(#selector(hideView), with: self, afterDelay: time + ANIMATION_TIME)
    }
    /// Static Method
    static func dismissAllAlert(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: RKDropdownAlert.TAG), object: nil)
    }
    static func alert(_ title:String?,_ message:String?){
        let alert = alertViewWithDelegate(nil)
        alert.alert(title, message, UIColor(red: 0.98, green: 0.66, blue: 0.2, alpha: 1), UIColor.white, -1)
    }
    static func alert(_ title:String?,_ message:String?,_ backgroundColor:UIColor?,_ textColor:UIColor?){
        let alert = alertViewWithDelegate(nil)
        alert.alert(title, message, backgroundColor, textColor, -1)
    }
    // 静态构造
    static func alertViewWithDelegate(_ delegate: RKDropdownAlertDelegate?) -> RKDropdownAlert{
        // (0, -90, screenWidth, 90)
        let alert = RKDropdownAlert(frame: CGRect(x: 0, y: -90,width: UIScreen.main.bounds.size.width, height: 90))
        alert.delegate = delegate
        return alert
    }
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
}
protocol RKDropdownAlertDelegate {
    func dropdownAlertWasTapped(_ alert:RKDropdownAlert) -> Bool
    func dropdownAlertWasDismissed() -> Bool
}
