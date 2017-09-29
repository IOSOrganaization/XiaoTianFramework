//
//  MyAlertActionControl.swift
//  XiaoTianFramework
//  弹框支持Alert, ActionSheet
//  Created by guotianrui on 2017/7/17.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

public class MyAlertActionControl {
    // 事件卡
    open class Action : NSObject {
        open fileprivate(set) var button: UIButton!
        var title: String
        var style: Action.Style
        var handler: ((Action) -> Void)?
        open var enabled: Bool = true {
            didSet { button?.isEnabled = enabled }
        }
        
        public enum Style {
            case `default`, ok, cancel, destructive
        }
        
        public init(title: String, style: Style, handler: ((Action?) -> Void)? = nil) {
            self.title = title
            self.style = style
            self.handler = handler
            super.init()
        }
    }
    // 内容视图
    open class ContentView: UIView {
        let textFieldFontSize: CGFloat = 14
        let textFieldHeight: CGFloat = 25
        // UI
        open var baseView = UIView()
        open var titleLabel = UILabel()
        open var messageLabel = UILabel()
        open var textBackgroundView = UIView()
        open var textView = UITextView()
        // 约束
        fileprivate var verticalSpaceConstraint: NSLayoutConstraint!
        fileprivate var titleSpaceConstraint: NSLayoutConstraint!
        fileprivate var messageSpaceConstraint: NSLayoutConstraint!
        fileprivate var textViewHeightConstraint: NSLayoutConstraint!
        
        public convenience init() {
            self.init(frame: CGRect.zero)
            backgroundColor = UIColor.white
            addSubview(baseView)
            checkTranslatesAutoresizing(withView: baseView, toView: nil)
            verticalSpaceConstraint = addPinConstraint(addView: self, withItem: baseView, toItem: self, attribute: .top, constant: 20)
            _ = addPinConstraint(addView: self, withItem: baseView, toItem: self, attribute: .leading, constant: 20)
            _ = addPinConstraint(addView: self, withItem: baseView, toItem: self, attribute: .centerX, constant: 0)
            
            baseView.addSubview(titleLabel)
            checkTranslatesAutoresizing(withView: titleLabel, toView: nil)
            _ = addPinConstraint(addView: baseView, withItem: titleLabel, toItem: baseView, attribute: .top, constant: 0)
            _ = addPinConstraint(addView: baseView, withItem: titleLabel, toItem: baseView, attribute: .leading, constant: 0)
            _ = addPinConstraint(addView: baseView, withItem: titleLabel, toItem: baseView, attribute: .centerX, constant: 0)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.textColor = UIColor.gray
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            
            baseView.addSubview(messageLabel)
            checkTranslatesAutoresizing(withView: messageLabel, toView: nil)
            _ = addPinConstraint(addView: baseView, withItem: messageLabel, toItem: baseView, attribute: .leading, constant: 0)
            _ = addPinConstraint(addView: baseView, withItem: messageLabel, toItem: baseView, attribute: .centerX, constant: 0)
            titleSpaceConstraint = addNewConstraint(addView: baseView, relation: .equal, withItem: messageLabel, withAttribute: .top, toItem: titleLabel, toAttribute: .bottom, constant: 18)
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.textColor = UIColor.black
            messageLabel.font = UIFont.systemFont(ofSize: 14)
            
            baseView.addSubview(textBackgroundView)
            checkTranslatesAutoresizing(withView: textBackgroundView, toView: nil)
            _ = addPinConstraint(addView: baseView, withItem: textBackgroundView, toItem: baseView, attribute: .left, constant: 0)
            _ = addPinConstraint(addView: baseView, withItem: textBackgroundView, toItem: baseView, attribute: .right, constant: 0)
            _ = addPinConstraint(addView: baseView, withItem: textBackgroundView, toItem: baseView, attribute: .bottom, constant: 0)
            messageSpaceConstraint = addNewConstraint(addView: baseView, relation: .equal, withItem: textBackgroundView, withAttribute: .top, toItem: messageLabel, toAttribute: .bottom, constant: 18)
            textViewHeightConstraint = addNewConstraint(addView: textBackgroundView, relation: .equal, withItem: textBackgroundView, withAttribute: .height, toItem: nil, toAttribute: .height, constant: 0)
        }
    }
    open static func presentAlert(_ nvc:UINavigationController?,_ title:String,_ message:String){
        let controller = Controller(title: title, message: message, style: .alert)
        controller.addAction(Action(title: "确定", style: .ok))
        nvc?.present(controller, animated: true, completion: nil)
    }
    // 控制器VC
    public class Controller: UIViewController {
        let AlertDefaultWidth: CGFloat = 270
        let AlertButtonHeight: CGFloat = 48
        let AlertButtonFontSize: CGFloat = 17
        let ActionSheetMargin: CGFloat = 10
        let ActionSheetButtonHeight: CGFloat = 45
        let ActionSheetButtonFontSize: CGFloat = 21
        let ContentCornerRadius:CGFloat = 5.0
        // 模式
        public enum Style {
            case alert//弹框
            case actionSheet//事件卡
        }
        // 背景
        fileprivate class RespondView: UIView {
            var touchHandler: ((UIView) -> Void)?
            
            override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
                // 点击结束
                touchHandler?(self)
            }
        }
        // UI
        fileprivate var backgroundView:RespondView = RespondView()//背景
        fileprivate var containerView:UIView = UIView()//容器
        fileprivate var coverView:UIView = UIView()//覆盖
        fileprivate var marginView:UIView = UIView()//顶层容器
        fileprivate var baseView:UIView = UIView()//主视图容器
        fileprivate var mainView:UIScrollView = UIScrollView()//主视图容器
        fileprivate var buttonView:UIScrollView = UIScrollView()//主按钮容器
        fileprivate var cancelButtonView:UIScrollView = UIScrollView()//取消按钮容器
        fileprivate var contentView: ContentView? = ContentView()//主视图
        // UI AutoLayout 约束
        fileprivate var backgroundViewTopSpaceConstraint: NSLayoutConstraint!//背景顶
        fileprivate var backgroundViewBottomSpaceConstraint: NSLayoutConstraint!//背景底
        fileprivate var coverViewHeightConstraint: NSLayoutConstraint!//覆盖层高
        fileprivate var containerViewWidthConstraint: NSLayoutConstraint!//容器宽
        fileprivate var containerViewBottomSpaceConstraint: NSLayoutConstraint!//容器底边
        
        fileprivate var mainViewHeightConstraint: NSLayoutConstraint!//主容高
        fileprivate var buttonViewHeightConstraint: NSLayoutConstraint!//主按高
        fileprivate var cancelButtonViewHeightConstraint: NSLayoutConstraint!//取消按高
        fileprivate var cancelButtonViewSpaceConstraint: NSLayoutConstraint!//主按/取消按 间距
        
        fileprivate var marginViewTopSpaceConstraint: NSLayoutConstraint!//顶上
        fileprivate var marginViewLeftSpaceConstraint: NSLayoutConstraint!//顶左
        fileprivate var marginViewBottomSpaceConstraint: NSLayoutConstraint!//顶下
        fileprivate var marginViewRightSpaceConstraint: NSLayoutConstraint!//顶右
        // 内容View配置
        open var configContainerWidth: (() -> CGFloat?)? //修改容器宽
        open var configContainerCornerRadius: (() -> CGFloat?)?//修改容器圆角
        open var configContentView: ((UIView?) -> Void)?//修改主视图
        
        open fileprivate(set) var actions: [Action] = []//事件集合[公开属性,私有setter(公开外部不能setter)]
        open fileprivate(set) var textFields: [UITextField] = []//输入框集合
        fileprivate var textFieldHandlers: [((UITextField?) -> Void)?] = []
        fileprivate var customView: UIView?//自定义View
        fileprivate var transitionCoverView: UIView?//转场覆盖层
        fileprivate var displayTargetView: UIView?//显示主View
        fileprivate var presentedAnimation: Bool = true//动态出现
        fileprivate var message: String?
        // 优先样式为弹框
        fileprivate var preferredStyle: Style = .alert
        // 四周边距
        fileprivate var marginInsets: UIEdgeInsets {
            set {
                marginViewTopSpaceConstraint.constant = newValue.top
                marginViewLeftSpaceConstraint.constant = newValue.left
                marginViewBottomSpaceConstraint.constant = newValue.bottom
                marginViewRightSpaceConstraint.constant = newValue.right
            }
            get {
                let top = marginViewTopSpaceConstraint.constant
                let left = marginViewLeftSpaceConstraint.constant
                let bottom = marginViewBottomSpaceConstraint.constant
                let right = marginViewRightSpaceConstraint.constant
                return UIEdgeInsetsMake(top, left, bottom, right)
            }
        }
        // 构造器
        private init() {
            // 初始化VC,系统自动创建必要属性,根view
            super.init(nibName: nil, bundle: nil)
            setupView()
            // 自定义过场动画
            modalPresentationStyle = .custom
            modalTransitionStyle = .crossDissolve// 交叉溶解
            transitioningDelegate = self// 过场事件委托
            // 通知中心->添加键盘侦听器
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        }
        
        public convenience init(title: String?, message: String?, style: Style) {
            self.init()
            self.title = title
            self.message = message
            self.preferredStyle = style
        }
        
        public convenience init(view: UIView?, style: Style) {
            self.init()
            self.customView = view
            self.preferredStyle = style
            self.contentView = nil
        }
        
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setupView(){
            view.frame = UIScreen.main.bounds
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(backgroundView)
            //backgroundView.backgroundColor = utilShared.color.randomColor
            // view 自动转换大小为约束,根view不使用自动布局
            checkTranslatesAutoresizing(withView: backgroundView, toView: nil)
            _ = addPinConstraint(addView: view, withItem: backgroundView, toItem: view, attribute: .leading, constant: 0)
            _ = addPinConstraint(addView: view, withItem: backgroundView, toItem: view, attribute: .trailing, constant: 0)
            backgroundViewTopSpaceConstraint = addPinConstraint(addView: view, withItem: backgroundView, toItem: view, attribute: .top, constant: 0)
            backgroundViewBottomSpaceConstraint = addPinConstraint(addView: view, withItem: view, toItem: backgroundView, attribute: .bottom, constant: 0)
            
            backgroundView.addSubview(coverView)
            //coverView.backgroundColor = utilShared.color.randomColor
            checkTranslatesAutoresizing(withView: coverView, toView: nil)
            _ = addPinConstraint(addView: backgroundView, withItem: coverView, toItem: backgroundView, attribute: .bottom, constant: 0)
            _ = addPinConstraint(addView: backgroundView, withItem: coverView, toItem: backgroundView, attribute: .leading, constant: 0)
            _ = addPinConstraint(addView: backgroundView, withItem: coverView, toItem: backgroundView, attribute: .trailing, constant: 0)
            coverViewHeightConstraint = addNewConstraint(addView: coverView, relation: .equal, withItem: coverView, withAttribute: .height, toItem: nil, toAttribute: .height, constant: 600)
            
            backgroundView.addSubview(marginView)
            //marginView.backgroundColor = utilShared.color.randomColor
            checkTranslatesAutoresizing(withView: marginView, toView: nil)
            marginViewTopSpaceConstraint = addPinConstraint(addView: backgroundView, withItem: marginView, toItem: backgroundView, attribute: .top, constant: 0)
            marginViewBottomSpaceConstraint = addPinConstraint(addView: backgroundView, withItem: backgroundView, toItem: marginView, attribute: .bottom, constant: 0)
            marginViewLeftSpaceConstraint = addPinConstraint(addView: backgroundView, withItem: marginView, toItem: backgroundView, attribute: .leading, constant: 0)
            marginViewRightSpaceConstraint = addPinConstraint(addView: backgroundView, withItem: backgroundView, toItem: marginView, attribute: .trailing, constant: 0)
            
            marginView.addSubview(containerView)
            //containerView.backgroundColor = utilShared.color.randomColor
            checkTranslatesAutoresizing(withView: containerView, toView: nil)
            // 根据内容居中(修改权重)
            // 靠上
            let containerViewTop = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: marginView, attribute: .top, multiplier: 1, constant: 0)
            containerViewTop.priority = UILayoutPriorityDefaultLow
            marginView.addConstraint(containerViewTop)
            // 居中
            let containerViewCenterY = NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: marginView, attribute: .centerY, multiplier: 1, constant: 0)
            containerViewCenterY.priority = UILayoutPriorityDefaultHigh
            marginView.addConstraint(containerViewCenterY)
            // 靠下
            containerViewBottomSpaceConstraint = NSLayoutConstraint(item: marginView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1, constant: 0)
            containerViewBottomSpaceConstraint.priority = UILayoutPriorityDefaultLow
            marginView.addConstraint(containerViewBottomSpaceConstraint)
            _ = addPinConstraint(addView: marginView, withItem: containerView, toItem: marginView, attribute: .centerX, constant: 0)
            containerViewWidthConstraint = addNewConstraint(addView: containerView, relation: .equal, withItem: containerView, withAttribute: .width, toItem: nil, toAttribute: .width, constant: 300)
            
            containerView.addSubview(baseView)
            //baseView.backgroundColor = utilShared.color.randomColor
            checkTranslatesAutoresizing(withView: baseView, toView: nil)
            _ = addPinConstraint(addView: containerView, withItem: baseView, toItem: containerView, attribute: .top, constant: 0)
            _ = addPinConstraint(addView: containerView, withItem: baseView, toItem: containerView, attribute: .leading, constant: 0)
            _ = addPinConstraint(addView: containerView, withItem: baseView, toItem: containerView, attribute: .trailing, constant: 0)
            
            containerView.addSubview(cancelButtonView)
            //cancelButtonView.backgroundColor = utilShared.color.randomColor
            checkTranslatesAutoresizing(withView: cancelButtonView, toView: nil)
            _ = addPinConstraint(addView: containerView, withItem: cancelButtonView, toItem: containerView, attribute: .bottom, constant: 0)
            _ = addPinConstraint(addView: containerView, withItem: cancelButtonView, toItem: containerView, attribute: .leading, constant: 0)
            _ = addPinConstraint(addView: containerView, withItem: cancelButtonView, toItem: containerView, attribute: .trailing, constant: 0)
            cancelButtonViewSpaceConstraint = addNewConstraint(addView: containerView, relation: .equal, withItem: cancelButtonView, withAttribute: .top, toItem: baseView, toAttribute: .bottom, constant: 0)
            cancelButtonViewHeightConstraint = addNewConstraint(addView: cancelButtonView, relation: .equal, withItem: cancelButtonView, withAttribute: .height, toItem: nil, toAttribute: .height, constant: 0)
            
            baseView.addSubview(mainView)
            //mainView.backgroundColor = utilShared.color.randomColor
            checkTranslatesAutoresizing(withView: mainView, toView: nil)
            _ = addPinConstraint(addView: baseView, withItem: mainView, toItem: baseView, attribute: .top, constant: 0)
            _ = addPinConstraint(addView: baseView, withItem: mainView, toItem: baseView, attribute: .leading, constant: 0)
            _ = addPinConstraint(addView: baseView, withItem: mainView, toItem: baseView, attribute: .trailing, constant: 0)
            mainViewHeightConstraint = addNewConstraint(addView: mainView, relation: .equal, withItem: mainView, withAttribute: .height, toItem: nil, toAttribute: .height, constant: 0)
            
            baseView.addSubview(buttonView)
            //buttonView.backgroundColor = utilShared.color.randomColor
            checkTranslatesAutoresizing(withView: buttonView, toView: nil)
            _ = addPinConstraint(addView: baseView, withItem: buttonView, toItem: baseView, attribute: .bottom, constant: 0)
            _ = addPinConstraint(addView: baseView, withItem: buttonView, toItem: baseView, attribute: .leading, constant: 0)
            _ = addPinConstraint(addView: baseView, withItem: buttonView, toItem: baseView, attribute: .trailing, constant: 0)
            _ = addNewConstraint(addView: baseView, relation: .equal, withItem: buttonView, withAttribute: .top, toItem: mainView, toAttribute: .bottom, constant: 0)
            buttonViewHeightConstraint = addNewConstraint(addView: buttonView, relation: .equal, withItem: buttonView, withAttribute: .height, toItem: nil, toAttribute: .height, constant: AlertButtonHeight)
        }
        // #UIViewController
        override open func viewDidLoad() {
            super.viewDidLoad()
            baseView.layer.cornerRadius = ContentCornerRadius
            baseView.clipsToBounds = true
            cancelButtonView.layer.cornerRadius = ContentCornerRadius
            cancelButtonView.clipsToBounds = true
            displayTargetView = contentView
        }
        override open func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            // 是否自定义View
            if let view = customView {
                displayTargetView = view
            }
            // 非自定义,设置默认内容View
            if displayTargetView == contentView {
                setupContnetView()
            }
            // 输入框
            textFieldHandlers.removeAll()
            //如果有输入框,第一个获取键盘焦点
            if let textField = textFields.first {
                textField.becomeFirstResponder()
            }
            // 样式为事件卡
            if preferredStyle == .actionSheet {
                containerViewBottomSpaceConstraint.priority = 999// 优先级,权重(控制靠下,不能修/改 为1000的权重)
                // 点击背景隐藏,销毁
                backgroundView.touchHandler = { [weak self] view in //声明对self弱引用,因为这个方法会dismissViewController,会销毁self,所以声明弱引用
                    self?.dismiss()//隐藏,销毁 self
                }
            }
        }
        override open func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            if transitionCoverView == nil {
                return
            }
            layoutContainer()
            layoutContents()
            layoutButtons()
            let margin = marginInsets.top + marginInsets.bottom
            let backgroundViewHeight = view.bounds.size.height - backgroundViewBottomSpaceConstraint.constant - margin
            if cancelButtonView.contentSize.height > cancelButtonViewHeightConstraint.constant {
                cancelButtonViewHeightConstraint.constant = cancelButtonView.contentSize.height
            }
            if cancelButtonViewHeightConstraint.constant > backgroundViewHeight {
                cancelButtonView.contentSize.height = cancelButtonViewHeightConstraint.constant
                cancelButtonViewHeightConstraint.constant = backgroundViewHeight
                mainViewHeightConstraint.constant = 0
                buttonViewHeightConstraint.constant = 0
            } else {
                let baseViewHeight = backgroundViewHeight - cancelButtonViewHeightConstraint.constant - cancelButtonViewSpaceConstraint.constant
                if buttonView.contentSize.height > buttonViewHeightConstraint.constant {
                    buttonViewHeightConstraint.constant = buttonView.contentSize.height
                }
                if buttonViewHeightConstraint.constant > baseViewHeight {
                    buttonView.contentSize.height = buttonViewHeightConstraint.constant
                    buttonViewHeightConstraint.constant = baseViewHeight
                    mainViewHeightConstraint.constant = 0
                } else {
                    let mainViewHeight = baseViewHeight - buttonViewHeightConstraint.constant
                    if mainViewHeightConstraint.constant > mainViewHeight {
                        mainView.contentSize.height = mainViewHeightConstraint.constant
                        mainViewHeightConstraint.constant = mainViewHeight
                    }
                }
            }
            if preferredStyle == .actionSheet {
                let contentHeight = cancelButtonViewHeightConstraint.constant + mainViewHeightConstraint.constant + buttonViewHeightConstraint.constant + cancelButtonViewSpaceConstraint.constant
                coverViewHeightConstraint.constant = contentHeight + marginInsets.top + marginInsets.bottom
            }
            view.layoutSubviews()
        }
        // 添加输入框[handler默认为nil]
        open func addTextFieldWithConfigurationHandler(_ configurationHandler: ((UITextField?) -> Void)? = nil) {
            textFieldHandlers.append(configurationHandler)
        }
        // 添加事件卡
        open func addAction(_ action: Action) {
            let button = createActionButton()
            if button.bounds.height <= 0 {
                button.frame.size.height = preferredStyle == .actionSheet ? ActionSheetButtonHeight : AlertButtonHeight
            }
            button.autoresizingMask = .flexibleWidth
            button.addTarget(self, action: #selector(buttonWasTapped), for: .touchUpInside)
            action.setButton(button)
            configurActionButton(action.style, forButton: button)
            actions.append(action)
        }
        
        /** override if needed */
        open func createActionButton() -> UIButton {
            let button = UIButton(type: .system)
            let borderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.7))
            borderView.backgroundColor = UIColor.lightGray
            borderView.autoresizingMask = .flexibleWidth
            button.addSubview(borderView)
            return button
        }
        open func configurActionButton(_ style: Action.Style, forButton button: UIButton) {
            if preferredStyle == .alert {
                configurAlertButton(style, forButton: button)
            } else {
                configurActionSheetButton(style, forButton: button)
            }
        }
        // 隐藏弹框
        open func dismiss(_ sender: AnyObject? = nil) {
            dismiss(animated: true) { //动态隐藏,销毁
                if let action = self.actions.filter({ $0.button == sender as? UIButton }).first {
                    action.handler?(action)//事件的handler
                }
                // Array 移除
                self.actions.removeAll()
                self.textFields.removeAll()
            }
        }
        // 销毁
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
    }
    // 点击改变背景色按钮
    private class MyButton: UIButton {
        override public init(frame: CGRect) {
            super.init(frame: frame)
            setupButton()
        }
        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        public func setupButton() {
            addTarget(self, action: #selector(buttonTapDown(_:)), for: [.touchDown,.touchDragEnter])
            addTarget(self, action: #selector(buttonRelease(_:)), for: [.touchUpInside,.touchUpOutside,.touchCancel,.touchDragOutside])
        }
        @objc
        private func buttonTapDown(_ btn:MyButton){
            btn.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
        @objc
        private func buttonRelease(_ btn:MyButton){
            btn.backgroundColor = UIColor.clear
        }
    }
}
// 私有扩展Action方法
private extension MyAlertActionControl.Action {
    func setButton(_ forButton: UIButton) {
        button = forButton
        button.setTitle(title, for: UIControlState())
        button.isEnabled = enabled
    }
}
// 私有扩展内容视图方法
private extension MyAlertActionControl.ContentView {
    // 内容输入框
    private class TextField: UITextField {
        let textLeftOffset: CGFloat = 4
        
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.offsetBy(dx: textLeftOffset, dy: 0)
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.offsetBy(dx: textLeftOffset, dy: 0)
        }
    }
    // 创建输入框View
    func addTextField() -> UITextField {
        let textField = TextField(frame: textBackgroundView.bounds)
        textField.autoresizingMask = .flexibleWidth
        textField.font = UIFont.systemFont(ofSize: textFieldFontSize)
        textField.backgroundColor = UIColor.white
        textField.layer.borderColor = UIColor.darkGray.cgColor
        textField.layer.borderWidth = 0.5
        textBackgroundView.addSubview(textField)
        return textField
    }
    // 重新布局内容
    func layoutContents() {
        titleLabel.preferredMaxLayoutWidth = baseView.bounds.width
        titleLabel.layoutIfNeeded()
        messageLabel.preferredMaxLayoutWidth = baseView.bounds.width
        messageLabel.layoutIfNeeded()
        if textBackgroundView.subviews.isEmpty {
            messageSpaceConstraint.constant = 0
        }
        if titleLabel.text == nil && messageLabel.text == nil {
            titleSpaceConstraint.constant = 0
            messageSpaceConstraint.constant = 0
            if textBackgroundView.subviews.isEmpty {
                verticalSpaceConstraint.constant = 0
            }
        } else if titleLabel.text == nil || messageLabel.text == nil {
            titleSpaceConstraint.constant = 0
        }
        baseView.setNeedsLayout()
        baseView.layoutIfNeeded()
        frame.size.height = baseView.bounds.height + (verticalSpaceConstraint.constant * 2)
    }
    // 重新布局输入框
    func layoutTextField(_ textField: UITextField) {
        textField.frame.origin.y = textViewHeightConstraint.constant
        if textField.frame.height <= 0 {
            textField.frame.size.height = textFieldHeight
        }
        textViewHeightConstraint.constant += textField.frame.height
    }
}
// 私有扩展Controller方法(只能本文件使用)
private extension MyAlertActionControl.Controller {
    // 设置内容View
    func setupContnetView() {
        takeOverColor(contentView)
        contentView?.titleLabel.text = title
        contentView?.messageLabel.text = message
        if preferredStyle == .alert {
            for handler in textFieldHandlers {
                if let textField = self.contentView?.addTextField() {
                    self.textFields.append(textField)
                    handler?(textField)
                }
            }
        }
    }
    // 重新布局容器宽度
    func layoutContainer() {
        var containerWidth = AlertDefaultWidth
        if preferredStyle == .actionSheet {
            marginInsets = UIEdgeInsetsMake(ActionSheetMargin, ActionSheetMargin, ActionSheetMargin, ActionSheetMargin)
            marginView.layoutIfNeeded()
            containerWidth = min(view.bounds.width, view.bounds.height) - marginInsets.top - marginInsets.bottom
        }
        
        if let width = configContainerWidth?() {
            containerWidth = width
        }
        if let radius = configContainerCornerRadius?() {
            baseView.layer.cornerRadius = radius
            cancelButtonView.layer.cornerRadius = radius
        }
        
        containerViewWidthConstraint.constant = containerWidth
        containerView.layoutIfNeeded()
    }
    // 重新布局内容
    func layoutContents() {
        displayTargetView?.frame.size.width = mainView.frame.size.width
        displayTargetView?.layoutIfNeeded()
        
        if let config = configContentView {
            config(displayTargetView)
            configContentView = nil
        }
        takeOverColor(displayTargetView)
        if displayTargetView == contentView {
            contentView?.textViewHeightConstraint.constant = 0
            for textField in textFields {
                contentView?.layoutTextField(textField)
            }
            contentView?.layoutContents()
        }
        
        if let targetView = displayTargetView {
            mainViewHeightConstraint.constant = targetView.bounds.height
            mainView.frame.size.height = targetView.bounds.height
            mainView.addSubview(targetView)
        }
    }
    // 重新布局按钮
    func layoutButtons() {
        var buttonActions = actions
        if preferredStyle == .actionSheet {
            let cancelActions = actions.filter { $0.style == .cancel }
            let buttonHeight = addButton(cancelButtonView, actions: cancelActions)
            cancelButtonViewHeightConstraint.constant = buttonHeight
            cancelButtonViewSpaceConstraint.constant = ActionSheetMargin
            buttonActions = actions.filter { $0.style != .cancel }
        }
        
        let buttonHeight = addButton(buttonView, actions: buttonActions)
        if preferredStyle != .alert || buttonActions.count != 2 {
            buttonViewHeightConstraint.constant = buttonHeight
        }
    }
    // 设置View颜色为背景颜色[View的透明覆盖]
    func takeOverColor(_ targetView: UIView?) {
        if let color = targetView?.backgroundColor {
            mainView.backgroundColor = color
            buttonView.backgroundColor = color
            cancelButtonView.backgroundColor = color
        }
        targetView?.backgroundColor = nil
    }
    // 添加并计算按钮高度
    func addButton(_ view: UIView, actions: [MyAlertActionControl.Action]) -> CGFloat {
        var sizeToFit: ((_ button: UIButton, _ index: Int) -> Void) = buttonSizeToFitForVertical
        // 两个按钮,自动横向平铺
        if preferredStyle == .alert && actions.count == 2 {
            sizeToFit = buttonSizeToFitForHorizontal
        }
        // 累加迭代
        return actions.reduce(0) { (height, action) in
            if let button = action.button{
                view.addSubview(button)
                let buttonHeight = button.bounds.height
                let buttonsHeight = height
                sizeToFit(button, Int(buttonsHeight / buttonHeight))
                return buttonsHeight + buttonHeight
            }
            return height
        }
    }
    // 纵向适配按钮大小
    func buttonSizeToFitForVertical(_ button: UIButton, index: Int) {
        button.frame.size.width = containerViewWidthConstraint.constant
        button.frame.origin.y = button.bounds.height * CGFloat(index)
    }
    // 横向适配按钮大小
    func buttonSizeToFitForHorizontal(_ button: UIButton, index: Int) {
        button.frame.size.width = containerViewWidthConstraint.constant / 2
        button.frame.origin.x = button.bounds.width * CGFloat(index)
        
        if index != 0 {
            let borderView = UIView(frame: CGRect(x: -0.25, y: 0, width: 0.5, height: button.bounds.height))
            borderView.backgroundColor = UIColor.lightGray
            borderView.autoresizingMask = .flexibleHeight
            button.addSubview(borderView)
        }
    }
    // 配置弹框按钮字体,颜色
    func configurAlertButton(_ style :MyAlertActionControl.Action.Style, forButton button: UIButton) {
        switch style {
        case .destructive:
            button.setTitleColor(UIColor.red, for: UIControlState())
            button.titleLabel?.font = UIFont.systemFont(ofSize: AlertButtonFontSize)
        case .cancel:
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: AlertButtonFontSize)
        default:
            button.titleLabel?.font = UIFont.systemFont(ofSize: AlertButtonFontSize)
        }
    }
    // 配置默认事件卡按钮字体,颜色
    func configurActionSheetButton(_ style :MyAlertActionControl.Action.Style, forButton button: UIButton) {
        switch style {
        case .destructive:
            button.setTitleColor(UIColor.red, for: UIControlState())
            button.titleLabel?.font = UIFont.systemFont(ofSize: ActionSheetButtonFontSize)
        case .cancel:
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: ActionSheetButtonFontSize)
        default:
            button.titleLabel?.font = UIFont.systemFont(ofSize: ActionSheetButtonFontSize)
        }
    }
}

// MARK: - Action Methods
extension MyAlertActionControl.Controller {
    // 按钮事件点击,隐藏事件卡(可重写)
    func buttonWasTapped(_ sender: UIButton) {
        dismiss(sender)
    }
}

// MARK: - NSNotificationCenter Methods
extension MyAlertActionControl.Controller {
    //键盘隐藏
    func keyboardDidHide(_ notification: Notification) {
        backgroundViewBottomSpaceConstraint.constant = 0
    }
    //键盘显示
    func keyboardWillShow(_ notification: Notification) {
        if let window = view.window {
            if let frame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
                let rect = window.convert(frame, to: view)
                backgroundViewBottomSpaceConstraint.constant = view.bounds.size.height - rect.origin.y
            }
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate Methods 动画转换委托
extension MyAlertActionControl.Controller: UIViewControllerTransitioningDelegate {
    // 动画->显示
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentedAnimation = true
        return self
    }
    // 动画->隐藏
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        presentedAnimation = false
        return self
    }
}

// MARK: - UIViewControllerAnimatedTransitioning Methods
extension MyAlertActionControl.Controller: UIViewControllerAnimatedTransitioning {
    // 动画时间
    func animateDuration() -> TimeInterval {
        return 0.25
    }
    // 动画执行曲线
    func animationOptionsForAnimationCurve(_ curve: UInt) -> UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: curve << 16)
    }
    // 创建动画转换视图
    func createCoverView(_ frame: CGRect) -> UIView {
        let coverView = UIView(frame: frame)
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        coverView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        coverView.alpha = 0
        return coverView
    }
    // 弹出框显示动画
    func presentAnimationForAlert(_ container: UIView, toView: UIView, fromView: UIView, completion: @escaping (Bool) -> Void) {
        let coverView = createCoverView(container.bounds)
        container.addSubview(coverView)
        toView.frame = container.bounds
        toView.transform = fromView.transform.concatenating(CGAffineTransform(scaleX: 1.2, y: 1.2))//先放大1.2陪 (缩小效果)
        coverView.addSubview(toView)
        transitionCoverView = coverView
        // 执行动画
        animation({
            toView.transform = fromView.transform
            coverView.alpha = 1
        }, completion: completion)
    }
    // 弹出框隐藏动画
    func dismissAnimationForAlert(_ container: UIView, toView: UIView, fromView: UIView, completion: @escaping (Bool) -> Void) {
        transitionCoverView?.addSubview(fromView)
        animation({
            self.transitionCoverView?.alpha = 0 //渐隐
            self.transitionCoverView = nil
        }, completion: completion)
    }
    // 事件卡显示动画
    func presentAnimationForActionSheet(_ container: UIView, toView: UIView, fromView: UIView, completion: @escaping (Bool) -> Void) {
        let coverView = createCoverView(container.bounds)
        container.addSubview(coverView)
        toView.frame = container.bounds
        container.addSubview(toView)
        // 上拉出现动态效果
        backgroundViewBottomSpaceConstraint.constant = -toView.bounds.height // 下移高度
        backgroundViewTopSpaceConstraint.constant = toView.bounds.height
        view.layoutIfNeeded() // 必须调用父类重新执行布局
        backgroundViewBottomSpaceConstraint.constant = 0 // 重新上移(重置)
        backgroundViewTopSpaceConstraint.constant = 0
        transitionCoverView = coverView
        // 执行动画
        animation({
            // 必须调用父类重新执行布局
            self.view.layoutIfNeeded() // Called on parent view
            coverView.alpha = 1
        }, completion: completion)
    }
    // 事件卡隐藏动画
    func dismissAnimationForActionSheet(_ container: UIView, toView: UIView, fromView: UIView, completion: @escaping (Bool) -> Void) {
        container.addSubview(fromView)
        backgroundViewBottomSpaceConstraint.constant = -toView.bounds.height
        backgroundViewTopSpaceConstraint.constant = toView.bounds.height
        animation({
            self.view.layoutIfNeeded()
            self.transitionCoverView?.alpha = 0
            self.transitionCoverView = nil
        }, completion: completion)
    }
    // 执行动画
    func animation(_ animations: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
        //执行指定动画(持续时间,延时,动画执行曲线,动画体,完成回调)
        UIView.animate(withDuration: animateDuration(), delay: 0, options: animationOptionsForAnimationCurve(7), animations: animations, completion: completion)
    }
    // 动画时间
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animateDuration()
    }
    // 转换动画
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let container:UIView = transitionContext.containerView
        guard let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return transitionContext.completeTransition(false)
        }
        guard let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return transitionContext.completeTransition(false)
        }
        if presentedAnimation == true {
            if preferredStyle == .alert {
                presentAnimationForAlert(container, toView: to.view, fromView: from.view) {_ in
                    transitionContext.completeTransition(true)
                }
            } else {
                presentAnimationForActionSheet(container, toView: to.view, fromView: from.view) {_ in
                    transitionContext.completeTransition(true)
                }
            }
        } else {
            if preferredStyle == .alert {
                dismissAnimationForAlert(container, toView: to.view, fromView: from.view) {_ in
                    transitionContext.completeTransition(true)
                }
            } else {
                dismissAnimationForActionSheet(container, toView: to.view, fromView: from.view) {_ in
                    transitionContext.completeTransition(true)
                }
            }
        }
    }
}
fileprivate func checkTranslatesAutoresizing(withView: UIView?, toView:UIView?){
    if withView?.translatesAutoresizingMaskIntoConstraints == true{
        withView?.translatesAutoresizingMaskIntoConstraints = false
    }
    if toView?.translatesAutoresizingMaskIntoConstraints == true{
        toView?.translatesAutoresizingMaskIntoConstraints = false
    }
}
@discardableResult
fileprivate func addPinConstraint(addView:UIView,withItem:UIView,toItem:UIView?,attribute:NSLayoutAttribute,constant:CGFloat) -> NSLayoutConstraint{
    return addNewConstraint(addView: addView, relation: .equal, withItem: withItem, withAttribute: attribute, toItem: toItem, toAttribute: attribute, constant: constant)
}
@discardableResult
fileprivate func addNewConstraint(addView: UIView, relation:NSLayoutRelation, withItem:UIView, withAttribute:NSLayoutAttribute, toItem:UIView?, toAttribute:NSLayoutAttribute, constant:CGFloat) ->NSLayoutConstraint{
    let constraint = NSLayoutConstraint(item: withItem, attribute: withAttribute, relatedBy: relation, toItem: toItem, attribute: toAttribute, multiplier: 1, constant: constant)
    addView.addConstraint(constraint)
    return constraint
}

