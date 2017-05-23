//
//  SimpleAlert.swift
//  SimpleAlert
//
//  Created by Kyohei Ito on 2015/01/09.
//  Copyright (c) 2015年 kyohei_ito. All rights reserved.
//

import UIKit

open class SimpleAlert {
    // 事件卡
    @objc(SimpleAlertAction)
    open class Action : NSObject {
        
        public enum Style {
            case `default`
            case ok
            case cancel
            case destructive
        }
        var title: String
        var handler: ((Action) -> Void)?
        var style: Action.Style
        open var enabled: Bool = true {
            didSet {
                button?.isEnabled = enabled
            }
        }
        open fileprivate(set) var button: UIButton!
        
        public init(title: String, style: Style, handler: ((Action?) -> Void)? = nil) {
            self.title = title
            self.handler = handler
            self.style = style
            super.init()
        }
    }
    // 内容视图
    @objc(SimpleAlertContentView)//OC对象,映射对象
    open class ContentView: UIView {
        let TextFieldFontSize: CGFloat = 14
        let TextFieldHeight: CGFloat = 25
        // UI
        @IBOutlet open weak var baseView: UIView!
        @IBOutlet open weak var titleLabel: UILabel!
        @IBOutlet open weak var messageLabel: UILabel!
        @IBOutlet open weak var textBackgroundView: UIView!
        // 约束
        @IBOutlet fileprivate var verticalSpaceConstraint: NSLayoutConstraint!
        @IBOutlet fileprivate var titleSpaceConstraint: NSLayoutConstraint!
        @IBOutlet fileprivate var messageSpaceConstraint: NSLayoutConstraint!
        @IBOutlet fileprivate var textViewHeightConstraint: NSLayoutConstraint!
        
        open override func awakeFromNib() {
            super.awakeFromNib()
            
            backgroundColor = UIColor.white
        }
    }
    
    // 控制器VC
    @objc(SimpleAlertController)
    open class Controller: UIViewController {
        // 模式
        public enum Style {
            case alert//弹框
            case actionSheet//事件卡
        }
        
        @objc(SimpleAlertControllerRespondView)
        fileprivate class RespondView: UIView {//背景视图
            var touchHandler: ((UIView) -> Void)?
            
            override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
                touchHandler?(self)
            }
        }
        // UI
        @IBOutlet fileprivate weak var containerView: UIView!//容器
        @IBOutlet fileprivate weak var backgroundView: RespondView!//背景
        @IBOutlet fileprivate weak var coverView: UIView!//覆盖
        @IBOutlet fileprivate weak var marginView: UIView!//顶层容器
        @IBOutlet fileprivate weak var baseView: UIView!//主视图容器
        @IBOutlet fileprivate weak var mainView: UIScrollView!//主视图容器
        @IBOutlet fileprivate weak var buttonView: UIScrollView!//主按钮容器
        @IBOutlet fileprivate weak var cancelButtonView: UIScrollView!//取消按钮容器
        @IBOutlet fileprivate weak var contentView: ContentView?//主视图
        // UI AutoLayout 约束
        @IBOutlet fileprivate var containerViewWidthConstraint: NSLayoutConstraint!//容器宽
        @IBOutlet fileprivate var containerViewBottomSpaceConstraint: NSLayoutConstraint!//容器底边
        @IBOutlet fileprivate var backgroundViewTopSpaceConstraint: NSLayoutConstraint!//背景顶
        @IBOutlet fileprivate var backgroundViewBottomSpaceConstraint: NSLayoutConstraint!//背景底
        @IBOutlet fileprivate var coverViewHeightConstraint: NSLayoutConstraint!//覆盖层高
        
        @IBOutlet fileprivate var mainViewHeightConstraint: NSLayoutConstraint!//主容高
        @IBOutlet fileprivate var buttonViewHeightConstraint: NSLayoutConstraint!//主按高
        @IBOutlet fileprivate var cancelButtonViewHeightConstraint: NSLayoutConstraint!//取消按高
        @IBOutlet fileprivate var buttonViewSpaceConstraint: NSLayoutConstraint!//主按/取消按 间距
        
        @IBOutlet fileprivate var marginViewTopSpaceConstraint: NSLayoutConstraint!//顶上
        @IBOutlet fileprivate var marginViewLeftSpaceConstraint: NSLayoutConstraint!//顶左
        @IBOutlet fileprivate var marginViewBottomSpaceConstraint: NSLayoutConstraint!//顶下
        @IBOutlet fileprivate var marginViewRightSpaceConstraint: NSLayoutConstraint!//顶右
        
        // 内容View配置
        open var configContainerWidth: (() -> CGFloat?)? //修改容器宽
        open var configContainerCornerRadius: (() -> CGFloat?)?//修改容器圆角
        open var configContentView: ((UIView?) -> Void)?//修改主视图
        
        open fileprivate(set) var actions: [Action] = []//事件集合[公开属性,私有setter(公开外部不能setter)]
        open fileprivate(set) var textFields: [UITextField] = []//输入框集合
        //
        fileprivate var textFieldHandlers: [((UITextField?) -> Void)?] = []
        fileprivate var customView: UIView?//自定义View
        fileprivate var transitionCoverView: UIView?//覆盖层
        fileprivate var displayTargetView: UIView?//显示主View
        fileprivate var presentedAnimation: Bool = true//显示动态
        //
        let AlertDefaultWidth: CGFloat = 270
        let AlertButtonHeight: CGFloat = 48
        let AlertButtonFontSize: CGFloat = 17
        //
        let ActionSheetMargin: CGFloat = 8
        let ActionSheetButtonHeight: CGFloat = 44
        let ActionSheetButtonFontSize: CGFloat = 21
        let ConstraintPriorityRequired: Float = 1000
        
        fileprivate var message: String?
        fileprivate var preferredStyle: Style = .alert//优先样式为弹框
        
        fileprivate var marginInsets: UIEdgeInsets {//边距
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
        public convenience init() {
            self.init(nibName: "SimpleAlert", bundle: Bundle(for: Controller.self))
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
        }
        
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        // 覆盖构造器
        override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
            
            modalPresentationStyle = .custom
            modalTransitionStyle = .crossDissolve
            transitioningDelegate = self
            // 通知中心->添加键盘侦听器
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        }
        // 销毁器
        deinit {
            NotificationCenter.default.removeObserver(self)
        }
        // #UIViewController
        override open func viewDidLoad() {
            super.viewDidLoad()
            
            view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            baseView.layer.cornerRadius = 3.0
            baseView.clipsToBounds = true
            
            cancelButtonView.layer.cornerRadius = 3.0
            cancelButtonView.clipsToBounds = true
            
            displayTargetView = contentView
        }
        override open func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            if let view = customView {// 是否自定义View
                displayTargetView = view
            }
            
            if displayTargetView == contentView {// 非自定义,设置默认内容View
                setupContnetView()
            }
            
            textFieldHandlers.removeAll()// 输入框
            
            if let textField = textFields.first {//如果有输入框,第一个获取键盘焦点
                textField.becomeFirstResponder()
            }
            
            if preferredStyle == .actionSheet {// 优先样式为事件卡
                containerViewBottomSpaceConstraint.priority = ConstraintPriorityRequired// 优先级,权重
                // 点击背景隐藏,销毁
                backgroundView.touchHandler = {
                    [weak self] //声明对self弱引用,因为这个方法会dismissViewController,会销毁self,所以声明弱引用
                    view in
                    self?.dismiss()//隐藏,销毁 self
                }
            }
        }
        
        open func dismiss(_ sender: AnyObject? = nil) {
            dismiss(animated: true) { //动态隐藏,销毁
                if let action = self.actions.filter({ $0.button == sender as? UIButton }).first {
                    action.handler?(action)//执行第一个事件的handler
                }
                // Array 移除
                self.actions.removeAll()
                self.textFields.removeAll()
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
                let baseViewHeight = backgroundViewHeight - cancelButtonViewHeightConstraint.constant - buttonViewSpaceConstraint.constant
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
                let contentHeight = cancelButtonViewHeightConstraint.constant + mainViewHeightConstraint.constant + buttonViewHeightConstraint.constant + buttonViewSpaceConstraint.constant
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
            var buttonHeight: CGFloat!
            if preferredStyle == .actionSheet {
                buttonHeight = ActionSheetButtonHeight
            } else {
                buttonHeight = AlertButtonHeight
            }
            
            let button = loadButton()
            if button.bounds.height <= 0 {
                button.frame.size.height = buttonHeight
            }
            button.autoresizingMask = .flexibleWidth
            button.addTarget(self, action: #selector(buttonWasTapped), for: .touchUpInside)
            action.setButton(button)
            configurButton(action.style, forButton: button)
            actions.append(action)
        }
        
        /** override if needed */
        open func loadButton() -> UIButton {
            let button = UIButton(type: .system)
            let borderView = UIView(frame: CGRect(x: 0, y: -0.5, width: 0, height: 0.5))
            borderView.backgroundColor = UIColor.lightGray
            borderView.autoresizingMask = .flexibleWidth
            button.addSubview(borderView)
            
            return button
        }
        
        open func configurButton(_ style: Action.Style, forButton button: UIButton) {
            if preferredStyle == .alert {
                configurAlertButton(style, forButton: button)
            } else {
                configurActionSheetButton(style, forButton: button)
            }
        }
    }
}
// 私有扩展Action方法
private extension SimpleAlert.Action {
    func setButton(_ forButton: UIButton) {
        button = forButton
        button.setTitle(title, for: UIControlState())
        button.isEnabled = enabled
    }
}
// 私有扩展内容视图方法
private extension SimpleAlert.ContentView {
     // 内容输入框
    class ContentTextField: UITextField {
        let TextLeftOffset: CGFloat = 4
        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.offsetBy(dx: TextLeftOffset, dy: 0)
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.offsetBy(dx: TextLeftOffset, dy: 0)
        }
    }
    // 创建输入框View
    func addTextField() -> UITextField {
        let textField = ContentTextField(frame: textBackgroundView.bounds)
        textField.autoresizingMask = .flexibleWidth
        textField.font = UIFont.systemFont(ofSize: TextFieldFontSize)
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
            textField.frame.size.height = TextFieldHeight
        }
        textViewHeightConstraint.constant += textField.frame.height
    }
}
// 私有扩展Controller方法(只能本文件使用)
private extension SimpleAlert.Controller {
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
    
    // 重新布局容器
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
            buttonViewSpaceConstraint.constant = ActionSheetMargin
            
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
    // 添加按钮
    func addButton(_ view: UIView, actions: [SimpleAlert.Action]) -> CGFloat {
        var sizeToFit: ((_ button: UIButton, _ index: Int) -> Void) = buttonSizeToFitForVertical
        if preferredStyle == .alert && actions.count == 2 {
            sizeToFit = buttonSizeToFitForHorizontal
        }
        
        return actions.reduce(0) { height, action in
            let button = action.button
            view.addSubview(button!)
            
            let buttonHeight = Int((button?.bounds.height)!)
            let buttonsHeight = Int(height)
            sizeToFit(button!, buttonsHeight / buttonHeight)
            
            return CGFloat(buttonsHeight + buttonHeight)
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
            let borderView = UIView(frame: CGRect(x: 0, y: 0, width: 0.5, height: button.bounds.height))
            borderView.backgroundColor = UIColor.lightGray
            borderView.autoresizingMask = .flexibleHeight
            button.addSubview(borderView)
        }
    }
    // 配置弹框按钮字体,颜色
    func configurAlertButton(_ style :SimpleAlert.Action.Style, forButton button: UIButton) {
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
    func configurActionSheetButton(_ style :SimpleAlert.Action.Style, forButton button: UIButton) {
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
extension SimpleAlert.Controller {
    // 事件点击,隐藏事件卡
    func buttonWasTapped(_ sender: UIButton) {
        dismiss(sender)
    }
}

// MARK: - NSNotificationCenter Methods
extension SimpleAlert.Controller {
    //键盘隐藏
    func keyboardDidHide(_ notification: Notification) {
        backgroundViewBottomSpaceConstraint?.constant = 0
    }
    //键盘显示
    func keyboardWillShow(_ notification: Notification) {
        if let window = view.window {
            if let frame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue {
                let rect = window.convert(frame, to: view)
                
                backgroundViewBottomSpaceConstraint?.constant = view.bounds.size.height - rect.origin.y
            }
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate Methods
extension SimpleAlert.Controller: UIViewControllerTransitioningDelegate {//动画转换委托
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
extension SimpleAlert.Controller: UIViewControllerAnimatedTransitioning {
    //动画时间
    func animateDuration() -> TimeInterval {
        return 0.25
    }
    //动画执行曲线
    func animationOptionsForAnimationCurve(_ curve: UInt) -> UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: curve << 16)
    }
    //创建动画转换视图
    func createCoverView(_ frame: CGRect) -> UIView {
        let coverView = UIView(frame: frame)
        coverView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        coverView.alpha = 0
        coverView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return coverView
    }
    
    func animation(_ animations: @escaping () -> Void, completion: @escaping (Bool) -> Void) {
        //执行指定动画(持续时间,延时,动画执行曲线,动画体,完成回调)
        UIView.animate(withDuration: animateDuration(), delay: 0, options: animationOptionsForAnimationCurve(7), animations: animations, completion: completion)
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
        
        backgroundViewBottomSpaceConstraint.constant = -toView.bounds.height //内容高度为0 (上拉出现效果)
        backgroundViewTopSpaceConstraint.constant = toView.bounds.height
        backgroundView.layoutIfNeeded()
        backgroundViewBottomSpaceConstraint.constant = 0
        backgroundViewTopSpaceConstraint.constant = 0
        
        transitionCoverView = coverView
        // 执行动画
        animation({
            self.backgroundView.layoutIfNeeded()
            coverView.alpha = 1
            }, completion: completion)
    }
    // 事件卡隐藏动画
    func dismissAnimationForActionSheet(_ container: UIView, toView: UIView, fromView: UIView, completion: @escaping (Bool) -> Void) {
        container.addSubview(fromView)
        
        backgroundViewBottomSpaceConstraint.constant = -toView.bounds.height
        backgroundViewTopSpaceConstraint.constant = toView.bounds.height
        
        animation({
            self.backgroundView.layoutIfNeeded()
            self.transitionCoverView?.alpha = 0
            self.transitionCoverView = nil
            }, completion: completion)
    }
    // 动画时间
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animateDuration()
    }
    // 转换动画
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let container:UIView = transitionContext.containerView else {
            return transitionContext.completeTransition(false)
        }
        
        guard let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return transitionContext.completeTransition(false)
        }
        
        guard let to = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return transitionContext.completeTransition(false)
        }

        if presentedAnimation == true {
            if preferredStyle == .alert {
                presentAnimationForAlert(container, toView: to.view, fromView: from.view) {
                    _ in
                    transitionContext.completeTransition(true)
                }
            } else {
                presentAnimationForActionSheet(container, toView: to.view, fromView: from.view) {
                    _ in
                    transitionContext.completeTransition(true)
                }
            }
        } else {
            if preferredStyle == .alert {
                dismissAnimationForAlert(container, toView: to.view, fromView: from.view) {
                    _ in
                    transitionContext.completeTransition(true)
                }
            } else {
                dismissAnimationForActionSheet(container, toView: to.view, fromView: from.view) {
                    _ in
                    transitionContext.completeTransition(true)
                }
            }
        }
    }
}
