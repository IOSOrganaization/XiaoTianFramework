//
//  MyViewPullRefresh.swift
//  XiaoTianFramework
//  上拉刷新,支持箭头,菊花指示器,文件,多图片轮播
//  Created by guotianrui on 2017/6/30.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

public class MyViewPullRefresh: UIView{
    public static let KEY_LAST_UPDATE_TIME = "MyViewRefreshControl.KEY_LAST_UPDATE_TIME"
    @objc
    public enum TypeShow:Int{
        case Simple //箭头+菊花
        case Normal //箭头+菊花+文本
        case Gif
    }
    @objc
    public enum State:Int{
        case Idle
        case Pulling
        case Refreshing
        case WillRefresh
        case NoMoreData
    }
    //
    var originalTopContentInset:CGFloat?//缓冲下拉前原来的Top Content Inser
    var topContentInset:CGFloat = 0
    var pan:UIGestureRecognizer?
    var executeRefreshingCallback:(() -> Void)?
    var endRefreshingCompletionBlock:(() -> Void)?
    var imageArrowMrginLabel:CGFloat = 0
    var imageStatesGifs:[State:[UIImage]?]?
    private var stateLabels:[State:String]?
    private var typeShow:TypeShow = TypeShow.Simple
    //UI
    var scrollView:UIScrollView?
    var imageArrow,imageGif:UIImageView?
    var indicatorView:UIActivityIndicatorView?
    var labelState,labelUpdateTime:UILabel?
    //
    private var state:State = .Idle{
        willSet{
            if state != newValue{
                updateState(newValue, state)
            }
        }
        didSet{
            // 状态
            labelState?.text = stateLabels?[state]
            labelUpdateTime?.text = getLastUpdatedTime()
            // 刷新,调用layoutSubviews
            DispatchQueue.main.async { [weak self] in
                self?.setNeedsLayout()
            }
        }
    }
    public var isAutomaticallyChangeAlpha = true{
        didSet{
            if isRefreshing{
                return
            }
            if isAutomaticallyChangeAlpha{
                self.alpha = pullingPercentage
            }else{
                alpha = 1
            }
        }
    }
    public var pullingPercentage:CGFloat = 0 {
        didSet{
            if isAutomaticallyChangeAlpha{
                self.alpha = pullingPercentage
            }
            // Idle 步进图片
            if let imageGif = imageGif{
                if state == .Idle{
                    if let images = imageStatesGifs?[.Pulling] as? [UIImage]{
                        imageGif.stopAnimating()
                        var index = Int(CGFloat(images.count) * pullingPercentage)
                        if index > images.count - 1{
                            index = images.count - 1
                        }
                        imageGif.image = images[index]
                    }
                }
            }
        }
    }
    var keyLastUpdateTime:String = {
        MyViewPullRefresh.KEY_LAST_UPDATE_TIME.appending(".").appending(ProcessInfo.processInfo.globallyUniqueString)
    }()
    // initFrame:Designated initializer(系统指定构造器,必须调用)
    // init:NSObject默认构造器,系统会自动调用指定构造器
    @objc
    public convenience init(type:TypeShow = TypeShow.Simple, refreshing:@escaping ()->Void){
        self.init(frame:CGRect.zero)
        self.typeShow = type
        self.executeRefreshingCallback = refreshing
        initRefreshControlView()
    }
    // GIF动画构造器
    @nonobjc
    public convenience init(imageState:[State:[UIImage]]?, refreshing:@escaping ()->Void){
        self.init(frame:CGRect.zero)
        self.typeShow = .Gif
        self.imageStatesGifs = imageState
        self.executeRefreshingCallback = refreshing
        initRefreshControlView()
    }
    @objc
    public convenience init(imageStatePulling:[UIImage]?,imageStateRefreshing:[UIImage]?, refreshing:@escaping ()->Void){
        self.init(frame:CGRect.zero)
        self.typeShow = .Gif
        self.imageStatesGifs = [.Pulling:imageStatePulling,.Refreshing:imageStateRefreshing]
        self.executeRefreshingCallback = refreshing
        initRefreshControlView()
    }
    //
    private func initRefreshControlView(){
        autoresizingMask = .flexibleWidth
        backgroundColor = UIColor.clear
        //
        let bundle = UtilBundle()
        switch typeShow {
        case .Simple:
            imageArrow = UIImageView(image: bundle.imageInBundleXiaoTian("arrow"))
            addSubview(imageArrow!)
            indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicatorView?.hidesWhenStopped = true
            addSubview(indicatorView!)
            break
        case .Normal:
            imageArrow = UIImageView(image: bundle.imageInBundleXiaoTian("arrow"))
            addSubview(imageArrow!)
            indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicatorView?.hidesWhenStopped = true
            addSubview(indicatorView!)
            //
            imageArrowMrginLabel = 25
            stateLabels = [:]
            stateLabels?[.Idle] = "下拉可以刷新"
            stateLabels?[.Pulling] = "松开立即刷新"
            stateLabels?[.Refreshing] = "正在刷新数据中..."
            //
            labelState = UILabel()
            if let labelState = labelState{
                labelState.font = UIFont.systemFont(ofSize: 14)
                labelState.textColor = UIColor.gray
                labelState.translatesAutoresizingMaskIntoConstraints = true
                labelState.autoresizingMask = .flexibleWidth
                labelState.textAlignment = .center
                labelState.backgroundColor = UIColor.clear
                addSubview(labelState)
            }
            labelUpdateTime = UILabel()
            if let labelUpdateTime = labelUpdateTime{
                labelUpdateTime.font = UIFont.systemFont(ofSize: 14)
                labelUpdateTime.textColor = UIColor.gray
                labelUpdateTime.autoresizingMask = .flexibleWidth
                labelUpdateTime.textAlignment = .center
                labelUpdateTime.backgroundColor = UIColor.clear
                addSubview(labelUpdateTime)
            }
            break
        case .Gif:
            imageGif = UIImageView()
            imageGif?.backgroundColor = UIColor.clear
            addSubview(imageGif!)
            break
        }
    }
    // 更新子View回调(转到后台返回)
    public override func layoutSubviews() {
        placeSubviews() // 布局子类视图
        super.layoutSubviews()
        Mylog.log("MyViewRefreshControl->layoutSubviews")
    }
    private func placeSubviews(){
        // 插入view的位置
        if let originalTopContentInset = originalTopContentInset{
            let y = -frame.height - originalTopContentInset
            frame = CGRect(x: frame.origin.x, y: y, width: frame.width, height: frame.height)
        }
        // State,DateTime 文本位置
        if let labelState = labelState {
            if let labelUpdateTime = labelUpdateTime{
                // 显示状态+时间(各占一半高度)
                let stateLabelHeight = frame.height / 2
                if labelState.frame.isEmpty {
                    labelState.frame = CGRect(x: 0, y: 0, width: bounds.width, height: stateLabelHeight)
                    labelState.text = stateLabels?[.Idle]
                }
                if labelUpdateTime.frame.isEmpty{
                    labelUpdateTime.frame = CGRect(x: 0, y: stateLabelHeight, width: bounds.width, height: bounds.height - stateLabelHeight)
                }
            }else{
                // 显示状态
                if labelState.frame.isEmpty {
                    labelState.frame = bounds
                    labelState.text = stateLabels?[.Idle]
                }
            }
        }
        // 箭头位置(默认中点)
        var arrowCenterX = frame.width / 2
        if let labelState = labelState{
            // 文字的左边+边距
            var frame = CGRect(x: labelState.frame.origin.x, y: labelState.frame.origin.y, width: labelState.frame.width, height: labelState.frame.height)
            let frameMax = CGRect(x: 0, y: 0, width: CGFloat(0x1.fffffep+127), height: CGFloat(0x1.fffffep+127)) // 无限大的bound
            labelState.frame = frameMax
            labelState.sizeToFit()
            let stateWidth = labelState.frame.width //获取状态文字宽度
            labelState.frame = frame
            var dateTimeWidth:CGFloat = 0
            if let labelUpdateTime = labelUpdateTime{
                frame = CGRect(x: labelUpdateTime.frame.origin.x, y: labelUpdateTime.frame.origin.y, width: labelUpdateTime.frame.width, height: labelUpdateTime.frame.height)
                labelUpdateTime.frame = frameMax
                labelUpdateTime.sizeToFit()
                dateTimeWidth = labelUpdateTime.frame.width //获取日期文字宽度
                labelUpdateTime.frame = frame
            }
            let maxWidth = CGFloat.maximum(stateWidth, dateTimeWidth)
            arrowCenterX -= maxWidth / 2 + imageArrowMrginLabel
        }
        let arrowCenterY = frame.height / 2
        if let imageArrow = imageArrow{
            imageArrow.center = CGPoint(x: arrowCenterX, y: arrowCenterY)
            imageArrow.tintColor = UIColor.gray
            if imageArrow.frame.isEmpty{
                if let size = imageArrow.image?.size{
                    imageArrow.frame.size = CGSize(width: size.width, height: size.width)
                }
            }
        }
        // 菊花进度条位置
        indicatorView?.center = CGPoint(x: arrowCenterX, y: arrowCenterY)
        // Gif
        if let imageGif = imageGif{
            if imageGif.frame.isEmpty{
                imageGif.frame = bounds
                if let firstImage = imageStatesGifs?[.Refreshing]??[0]{
                    imageGif.frame.size = firstImage.size
                }
            }
            imageGif.center = CGPoint(x: arrowCenterX, y: arrowCenterY)
        }
    }
    // 父类改变时触发,override it to perform additional actions whenever the superview changes
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        removeObservers()
        guard let superview = newSuperview as? UIScrollView else {
            return
        }
        scrollView = superview
        scrollView?.alwaysBounceVertical = true
        originalTopContentInset = scrollView!.contentInset.top
        addObservers()
        frame = CGRect(x:0, y:0, width:scrollView!.bounds.width, height:54)
    }
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        if state == .WillRefresh{ // 修改刷新状态,触发调用加载事件
            state = .Refreshing
        }
    }
    private func scrollViewContentOffsetDidChange(_ change:[NSKeyValueChangeKey : Any]?){
        //Mylog.log("scrollViewContentOffsetDidChange")
        if state == .Refreshing{
            if self.window == nil{
                return
            }
            // 插入头部占位符
            if let originalTopContentInset = originalTopContentInset{
                var insetTop:CGFloat = -scrollView!.contentOffset.y > originalTopContentInset ? -scrollView!.contentOffset.y : originalTopContentInset
                insetTop = insetTop > frame.size.height + originalTopContentInset ? frame.size.height + originalTopContentInset : insetTop
                scrollView?.contentInset.top = insetTop
                // 记录插入的高度,恢复时直接减去(这个为负值,恢复方便直接加,没啥卵用,就装逼蒙人)
                self.topContentInset = originalTopContentInset - insetTop
            }
            return
        }
        // 缓冲头部内容高度
        originalTopContentInset = scrollView?.contentInset.top
        let happenOffsetY = -originalTopContentInset!//头部内容插入高度
        let offsetY = scrollView!.contentOffset.y//内容的间距Y(下拉是负,上拉是正)
        if offsetY > happenOffsetY{// 只处理向上滑
            return
        }
        let pullingPercent = (happenOffsetY - offsetY) / frame.height // 滑动距离占下拉插件高度的比
        if scrollView!.isDragging{
            // 正在拖动中
            let normal2pullingOffsetY = happenOffsetY - frame.height // frame.height + topContentInset
            self.pullingPercentage = pullingPercent
            if state == .Idle && offsetY < normal2pullingOffsetY{
                // 下拉距离超过frame,开始刷新
                state = .Pulling
            }else if state == .Pulling && offsetY >= normal2pullingOffsetY{
                // 下拉距离小于frame,重置State
                state = .Idle
            }
        }else if state == .Pulling{
            // 拖动放手后,开始刷新
            beginRefreshing()
        }else if pullingPercent < 1{
            // 其他拖动中
            self.pullingPercentage = pullingPercent
        }
    }
    private func scrollViewContentSizeDidChange(_ change:[NSKeyValueChangeKey : Any]?){
        //Mylog.log("scrollViewContentSizeDidChange")
    }
    private func scrollViewPanStateDidChange(_ change:[NSKeyValueChangeKey : Any]?){
        //Mylog.log("scrollViewPanStateDidChange")
    }
    private func beginRefreshing(){
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.alpha = 1.0
        }
        pullingPercentage = 1
        if self.window == nil && state != .Refreshing{
            state = .WillRefresh
            setNeedsDisplay()
        }else{
            state = .Refreshing
        }
    }
    public func endRefreshing(){
        DispatchQueue.main.async { [weak self] in
            self?.state = .Idle
        }
    }
    public var isRefreshing:Bool{
        return state == .WillRefresh || state == .Refreshing
    }
    private func getLastUpdatedTime() -> String?{
        if let date = UserDefaults.standard.object(forKey: keyLastUpdateTime) as? Date{
            let calendar = Calendar.current
            let componentLast = calendar.dateComponents([.month,.day,.hour,.minute], from: date)
            let componentNow = calendar.dateComponents([.month,.day,.hour,.minute], from: Date())
            let formatter = DateFormatter()
            if componentLast.day! == componentNow.day!{
                formatter.dateFormat = "HH:mm"
                return "最后更新今天\(formatter.string(from: date))"
            }else if componentLast.year! == componentNow.year!{
                formatter.dateFormat = "MM-dd HH:mm"
                return "最后更新\(formatter.string(from: date))"
            }else{
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
                return "最后更新\(formatter.string(from: date))"
            }
        }
        return "最后更新无记录"
    }
    private func updateState(_ newState:State,_ oldState:State){
        switch newState {
        case .Idle:
            // Refreshing -> Idle
            if oldState == .Refreshing{
                if let _ = labelState{
                    UserDefaults.standard.set(Date(), forKey: keyLastUpdateTime)
                    UserDefaults.standard.synchronize()
                }
                // 恢复Inset/offset
                UIView.animate(withDuration: 0.4, animations: { [weak self] in
                    if let wSelf = self{
                        wSelf.scrollView?.contentInset.top  += wSelf.topContentInset
                        if wSelf.isAutomaticallyChangeAlpha{
                            wSelf.alpha = 0.0
                        }
                    }
                    },completion:{[weak self](finished) in
                        self?.pullingPercentage = 0.0
                        // 刷新完成
                        self?.endRefreshingCompletionBlock?()
                })
            }
            //
            if oldState == .Refreshing{
                imageArrow?.transform = CGAffineTransform.identity // 重置动画
                UIView.animate(withDuration: 0.4, animations: {[weak self] in
                        self?.indicatorView?.alpha = 0.0
                    }, completion:{[weak self](finished) in
                        guard let wSelf = self else{
                            return
                        }
                        if wSelf.state != .Idle{
                            return
                        }
                        wSelf.indicatorView?.alpha = 1.0
                        wSelf.indicatorView?.stopAnimating()
                        wSelf.indicatorView?.isHidden = false
                })
            }else{
                indicatorView?.stopAnimating()
                imageArrow?.isHidden = false
                UIView.animate(withDuration: 0.25, animations: { [weak self] in
                    self?.imageArrow?.transform = .identity
                })
            }
            //
            imageGif?.stopAnimating()
            break
        case .Refreshing:
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, animations: {[weak self] in
                    if let wSelf = self{
                        let top = wSelf.originalTopContentInset! + wSelf.frame.size.height
                        wSelf.scrollView?.contentInset.top = top
                        wSelf.scrollView?.setContentOffset(CGPoint(x: 0, y: -top), animated: false)
                    }
                }, completion:{[weak self](finished) in
                        self?.executeRefreshingCallback?()
                })
            }
            //
            indicatorView?.alpha = 1.0
            indicatorView?.startAnimating()
            imageArrow?.isHidden = true
            //
            imageGif?.stopAnimating()
            if let images = imageStatesGifs?[state] as? [UIImage]{
                imageGif?.animationImages = images
                imageGif?.animationDuration = Double(images.count) * 0.05
                imageGif?.startAnimating()
            }
            break
        case .Pulling:
            indicatorView?.stopAnimating()
            imageArrow?.isHidden = false
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.imageArrow?.transform = CGAffineTransform(rotationAngle: CGFloat(0.000001 - Double.pi))
            })
            //
            imageGif?.stopAnimating()
            break
        default:
            break
        }
    }
    // KVO 属性值变化监听添加
    private func addObservers(){
        // 内容间隙(滑动)
        scrollView?.addObserver(self, forKeyPath: "contentOffset", options: [.new,.old], context: nil)
        // 内容大小
        scrollView?.addObserver(self, forKeyPath: "contentSize", options: [.new,.old], context: nil)
        // 手指触摸状态
        pan = scrollView?.panGestureRecognizer
        pan?.addObserver(self, forKeyPath: "state", options: [.new,.old], context: nil)
    }
    // KVO 属性值变化监听移除
    private func removeObservers(){
        scrollView?.removeObserver(self, forKeyPath: "contentOffset")
        scrollView?.removeObserver(self, forKeyPath: "contentSize")
        pan?.removeObserver(self, forKeyPath: "state")
    }
    // KVO 变化侦听接收
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if isUserInteractionEnabled == false{
            return
        }
        if let keyPath = keyPath{
            switch keyPath {
            case "contentOffset":
                scrollViewContentOffsetDidChange(change)
                break
            case "contentSize":
                scrollViewContentSizeDidChange(change)
                break
            case "state":
                scrollViewPanStateDidChange(change)
                break
            default:
                break
            }
        }
    }
    // 销毁
    deinit {
        UserDefaults.standard.removeObject(forKey: keyLastUpdateTime)
        UserDefaults.standard.synchronize()
        removeObservers()
    }
}
// 扩展Header
public extension UIScrollView{
    // Objec-C Associaled Key
    private struct AssocialtedKey{
        static var HEADER:UnsafeMutablePointer<MyViewPullRefresh>? = nil
        static var PAGE:UnsafeMutablePointer<Int>? = nil
        static var PAGESIZE:UnsafeMutablePointer<Int>? = nil
    }
    // 添加Header
    public var headerPull:MyViewPullRefresh?{
        get{
            if let header = objc_getAssociatedObject(self, &AssocialtedKey.HEADER) as? MyViewPullRefresh{
                return header
            }
            return nil
        }
        set{
            if let header = objc_getAssociatedObject(self, &AssocialtedKey.HEADER) as? MyViewPullRefresh{
                header.removeFromSuperview()
            }
            if let newValue = newValue{
                addSubview(newValue)
            }
            objc_setAssociatedObject(self, &AssocialtedKey.HEADER, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    /// 页码
    public var pagePull:Int{
        get{
            if let page = objc_getAssociatedObject(self, &AssocialtedKey.PAGE) as? Int{
                return page
            }else{
                objc_setAssociatedObject(self, &AssocialtedKey.PAGE, 1, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
                return 1
            }
        }
        set{
           objc_setAssociatedObject(self, &AssocialtedKey.PAGE, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
    /// 每页数
    public var pageSizePull:Int{
        get{
            if let page = objc_getAssociatedObject(self, &AssocialtedKey.PAGESIZE) as? Int{
                return page
            }else{
                objc_setAssociatedObject(self, &AssocialtedKey.PAGESIZE, 10, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
                return 10
            }
        }
        set{
            objc_setAssociatedObject(self, &AssocialtedKey.PAGESIZE, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
    }
    /// 加载完成,修改page页码,返回是否还有更多
    public func refreshingFinishPull(_ page:Int,_ pageSize:Int,_ responseData:[Any]?){
        // 加载失败
        if responseData == nil{
            return
        }
        // 加载成功
        if responseData!.count == pageSize{
            self.pagePull = page + 1
        }
    }
}
