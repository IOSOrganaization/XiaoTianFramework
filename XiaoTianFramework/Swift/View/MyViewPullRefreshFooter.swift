//
//  MyViewLoadMoreData.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/7/3.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
public class MyViewPullRefreshFooter: UIView{
    public enum State:Int{
        case Idle
        case Refreshing
        case WillRefresh
        case NoMoreData
    }
    var executeRefreshingCallback:(() -> Void)?
    var endRefreshingCompletionBlock:(() -> Void)?
    var imageArrowMrginLabel:CGFloat = 0
    /// 下拉到最后自动加载更多
    var automaticallyRefresh = true
    /// 加载时是否显示正在加载文字
    var isRefreshingTitleHidden = false
    private var preRefreshDataCount = 0
    private var pan:UIGestureRecognizer?
    private var stateLabels:[State:String]?
    //UI
    var scrollView:UIScrollView?
    var indicatorView:UIActivityIndicatorView?
    var labelState:UILabel?
    private var state:State = .Idle{
        willSet{
            if state != newValue{
                updateState(newValue, state)
            }
        }
        didSet{
            if state == .Refreshing && isRefreshingTitleHidden{
                labelState?.text = ""
            }else{
                labelState?.text = stateLabels?[state]
            }
            // 刷新,调用layoutSubviews
            DispatchQueue.main.async { [weak self] in
                self?.setNeedsLayout()
            }
        }
    }
    public override var isHidden: Bool{
        willSet{
            if isHidden == false && newValue {
                // hidden -> show
                state = .Idle
                scrollView?.contentInset.bottom += frame.height
            }else if isHidden && newValue == false{
                // show -> hidden
                scrollView?.contentInset.bottom -= frame.height
                frame.origin.y = scrollView!.contentSize.height
            }
        }
    }
    @objc
    public convenience init(refreshing:@escaping ()->Void) {
        self.init()
        autoresizingMask = .flexibleWidth
        backgroundColor = UIColor.clear
        self.executeRefreshingCallback = refreshing
        //
        imageArrowMrginLabel = 25
        indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicatorView?.hidesWhenStopped = true
        addSubview(indicatorView!)
        labelState = UILabel()
        if let labelState = labelState{
            stateLabels = [:]
            stateLabels?[.Idle] = "点击或上拉加载更多"
            stateLabels?[.Refreshing] = "正在加载更多的数据..."
            stateLabels?[.NoMoreData] = "已经全部加载完毕"
            //
            labelState.font = UIFont.systemFont(ofSize: 14)
            labelState.textColor = UIColor.gray
            labelState.translatesAutoresizingMaskIntoConstraints = true
            labelState.autoresizingMask = .flexibleWidth
            labelState.textAlignment = .center
            labelState.backgroundColor = UIColor.clear
            labelState.isUserInteractionEnabled = true
            labelState.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onClickLabelState)))
            addSubview(labelState)
        }
    }
    // 父类改变时触发,override it to perform additional actions whenever the superview changes
    public override func willMove(toSuperview newSuperview: UIView?) {
        //Mylog.log("willMove")
        super.willMove(toSuperview: newSuperview)
        //
        removeObservers()
        if let superview = newSuperview as? UIScrollView {
            scrollView = superview
            scrollView?.alwaysBounceVertical = true
            addObservers()
            frame = CGRect(x:0, y:0, width:scrollView!.bounds.width, height:44)
        }
        if newSuperview != nil{
            if let scrollView = scrollView{
                if isHidden == false{
                    scrollView.contentInset.bottom += frame.height
                }
                frame.origin.y = scrollView.contentSize.height
            }
        }else if isHidden == false{
            scrollView?.contentInset.bottom -= frame.height
        }
    }
    // 更新子View回调(转到后台返回)
    public override func layoutSubviews() {
        //Mylog.log("MyViewRefreshControl->layoutSubviews")
        placeSubviews() // 布局子类视图
        super.layoutSubviews()
    }
    private func placeSubviews(){
        //Mylog.log("placeSubviews")
        if let labelState = labelState{
            if labelState.frame.isEmpty {
                labelState.frame = bounds
            }
        }
        if let indicatorView = indicatorView{
            var centerX = frame.size.width / 2
            if let labelState = labelState{
                if isRefreshingTitleHidden == false {
                    let frame = CGRect(x: labelState.frame.origin.x, y: labelState.frame.origin.y, width: labelState.frame.width, height: labelState.frame.height)
                    let frameMax = CGRect(x: 0, y: 0, width: CGFloat(0x1.fffffep+127), height: CGFloat(0x1.fffffep+127)) // 无限大的bound
                    labelState.frame = frameMax
                    labelState.sizeToFit()
                    let stateWidth = labelState.frame.width //获取状态文字宽度
                    centerX -= stateWidth / 2 + imageArrowMrginLabel
                    labelState.frame = frame
                }
            }
            let centerY = frame.height / 2
            indicatorView.center = CGPoint(x: centerX, y: centerY)
        }
    }
    public func endRefreshing(_ pageSize:Int,_ responseData:[Any]?){
        if let count = responseData?.count{
            endRefreshing(count < pageSize)
        }else{
            endRefreshing(true)
        }
    }
    public func endRefreshing(_ hasMoreData:Bool){
        state = hasMoreData ? .NoMoreData : .Idle
        // 无数据隐藏
        isHidden = getDataCount() == 0
    }
    
    public var isRefreshing:Bool{
        return state == .WillRefresh || state == .Refreshing
    }
    public func onClickLabelState(){
        if state == .Idle{
            beginRefreshing()
        }
    }
    
    private func updateState(_ newState:State,_ oldState:State){
        switch newState {
        case .Idle:
            indicatorView?.stopAnimating()
            if oldState == .Refreshing{
                endRefreshingCompletionBlock?()
            }
            break
        case .Refreshing:
            indicatorView?.startAnimating()
            preRefreshDataCount = getDataCount()
            DispatchQueue.main.async {[weak self] in
                if let wSelf = self {
                    wSelf.executeRefreshingCallback?()
                }
            }
            break
        case .NoMoreData:
            indicatorView?.stopAnimating()
            if oldState == .Refreshing{
                endRefreshingCompletionBlock?()
            }
            break
        default:
            break
        }
    }
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        if state == .WillRefresh{ // 修改刷新状态,触发调用加载事件
            state = .Refreshing
        }
    }
    private func scrollViewContentOffsetDidChange(_ change:[NSKeyValueChangeKey : Any]?){
        //Mylog.log("scrollViewContentOffsetDidChange")
        switch state {
        case .Idle:
            // automaticallyRefresh:滚动到末尾自动加载,frame.origin.y:刚进入时
            if automaticallyRefresh && frame.origin.y != 0{
                let contentHeight = scrollView!.contentSize.height
                let insetTop = scrollView!.contentInset.top
                let insetBottom = scrollView!.contentInset.bottom
                if insetTop + insetBottom + contentHeight > scrollView!.frame.height{ // inset+Content 超出ScrollView一个屏幕
                    let offsetY = scrollView!.contentOffset.y // 内容y的偏移量
                    let height = scrollView!.frame.height
                    if offsetY >= contentHeight - height + insetBottom - frame.height + frame.height{ //上拉超出一个frame距离触发加载事件
                        let old = change?[.oldKey] as! CGPoint
                        let new = change?[.newKey] as! CGPoint
                        if new.y <= old.y {
                            return
                        }
                        beginRefreshing()
                    }
                }
            }
            break
        default:
            break
        }
    }
    private func scrollViewContentSizeDidChange(_ change:[NSKeyValueChangeKey : Any]?){
        frame.origin.y = scrollView!.contentSize.height
    }
    private func scrollViewPanStateDidChange(_ change:[NSKeyValueChangeKey : Any]?){
        if state != .Idle{
            return
        }
        if scrollView!.panGestureRecognizer.state == .ended{
            // 判断上滑
            if scrollView!.contentInset.top + scrollView!.contentSize.height <= scrollView!.frame.height{
                if scrollView!.contentOffset.y >= -scrollView!.contentInset.top{
                    beginRefreshing()
                }
            }else{
                if scrollView!.contentOffset.y >= scrollView!.contentSize.height + scrollView!.contentInset.bottom - scrollView!.frame.height{
                    beginRefreshing()
                }
            }
        }
    }
    private func beginRefreshing(){
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.alpha = 1.0
        }
        if self.window == nil && state != .Refreshing{
            state = .WillRefresh
            setNeedsDisplay()
        }else{
            state = .Refreshing
        }
    }
    private func getDataCount() -> Int{
        var totalCount:Int = 0
        if scrollView is UITableView{
            if let table = scrollView as? UITableView {
                for section in 0  ..< table.numberOfSections {
                    totalCount += table.numberOfRows(inSection: section)
                }
            }
        }else if scrollView is UICollectionView{
            if let collection = scrollView as? UICollectionView{
                for section in 0 ..< collection.numberOfSections{
                    totalCount += collection.numberOfItems(inSection: section)
                }
            }
        }
        return totalCount
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
        removeObservers()
    }
}

// 扩展Header,Footer
public extension UIScrollView{
    // Objec-C Associaled Key
    private struct AssocialtedKey{
        static var FOOTER:UnsafeMutablePointer<MyViewPullRefreshFooter>? = nil
    }
    // 添加Footer
    public var footerPull:MyViewPullRefreshFooter?{
        get{
            if let footer = objc_getAssociatedObject(self, &AssocialtedKey.FOOTER) as? MyViewPullRefreshFooter{
                return footer
            }
            return nil
        }
        set{
            if let footer = objc_getAssociatedObject(self, &AssocialtedKey.FOOTER) as? MyViewPullRefreshFooter{
                footer.removeFromSuperview()
            }
            if let newValue = newValue{
                addSubview(newValue)
            }
            objc_setAssociatedObject(self, &AssocialtedKey.FOOTER, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
