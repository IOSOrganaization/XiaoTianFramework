//
//  MyViewRefreshTable.swift
//  DriftBook
//  可刷新的 Table
//  Created by 郭天蕊 on 2017/1/3.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

@IBDesignable
class MyViewRefreshTable: UIView,UITableViewDataSource,UITableViewDelegate{
    // UI
    private let LOADING_TYPE_INIT = 0
    private let LOADING_TYPE_FIRST = 1
    private let LOADING_TYPE_NEXT = 2
    private let LOADING_TYPE_RELOAD = 3
    //
    private var viewErrorNetSetting: MyUIView!
    private var page = 0
    private var loadingType = -1 // 0初始化,1第一页,2下一页,3重新加载当前页
    private var isLoading = false
    private var hasMoreData = true
    private var viewErrorNetSettingHeight:CGFloat = 40
    private(set) var tableView:UITableView!
    private var refreshController:MyLogoRefreshControl!
    //
    var viewLoading: UIView!
    var viewEmpty: MyUIView!
    var viewError: MyUIView!
    var viewReloading: MyUIView!
    var viewLoadingMore: UIView!
    var viewLoadingFinish: UIView!
    private(set) var dataArray:[AnyObject]! = []
    var toastNetConnectError = true
    var showLoadingFinishView = false
    var pageSize = 10
    var autoLoadingNextPage = true
    var dataSourceRefresh: MyViewRefreshTableDataSource!
    
    override init(frame:CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView(){
        // 初始化完成后,系统根据系统主题设置样式
        #if TARGET_INTERFACE_BUILDER
            return
        #endif
        let rootViews =  NSBundle.mainBundle().loadNibNamed("MyViewTipMessage", owner: nil, options: nil)
        viewLoading = rootViews[0] as? UIView
        viewEmpty = rootViews[1] as? MyUIView
        viewError = rootViews[2] as? MyUIView
        viewReloading = rootViews[3] as? MyUIView
        viewErrorNetSetting = viewError.viewWithTag(4610) as? MyUIView
        //
        tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.Plain)
        utilLayoutConstant(tableView).top().left().widthMultiplier(1).heightMultiplier(1) // x,y,w,h才能确定准确位置
        utilLayoutConstant(viewLoading).top().left().widthMultiplier(1).heightMultiplier(1)
        utilLayoutConstant(viewEmpty).top().left().widthMultiplier(1).heightMultiplier(1)
        utilLayoutConstant(viewError).top().left().widthMultiplier(1).heightMultiplier(1)
        utilLayoutConstant(viewReloading).top().left().widthMultiplier(1).heightMultiplier(1)
        //
        viewEmpty.hidden = true
        viewError.hidden = true
        tableView.hidden = true
        viewReloading.hidden = true
        //
        backgroundColor = utilShared.color.cleanColor
        viewLoading.backgroundColor = utilShared.color.cleanColor
        viewEmpty.backgroundColor = utilShared.color.cleanColor
        viewError.backgroundColor = utilShared.color.cleanColor
        viewEmpty.setTabedBackground(utilShared.color.cleanColor)
        viewError.setTabedBackground(utilShared.color.cleanColor)
        viewErrorNetSetting.setTabedBackground(utilShared.color.cleanColor)
        viewReloading.setTabedBackground(utilShared.color.cleanColor)
        viewEmpty.setOnTabListener({
            [weak self] view in
            if let wSelf = self {
                wSelf.initLoadingData()
            }
        })
        viewError.setOnTabListener({
            [weak self] view in
            if let wSelf = self {
                wSelf.initLoadingData()
            }
        })
        viewErrorNetSetting.setOnTabListener({
            view in
            UtilEnvironment.openSettingNetwork()
        })
        viewReloading.setOnTabListener({view in})
        refreshController = MyLogoRefreshControl()
        refreshController.addTarget(self, action: #selector(loadFirstPageData), forControlEvents: UIControlEvents.ValueChanged)
        tableView.backgroundView = refreshController
    }
    
    override func awakeFromNib() {
        // 样式要在系统完全初始化后才不会被系统修改
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.backgroundColor = UIColor.clearColor()
        layoutIfNeeded()
    }
//    func setupDataArray(dataArray:[AnyObject]?){
//        if dataArray == nil{
//            fatalError("Data Array 不能为空!")
//        }
//        self.dataArray  = dataArray
//    }
    // #UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let result = dataSourceRefresh?.tableView?(tableView, numberOfRowsInSection: section){
            return result
        }
        return dataArray.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        // 滚动到最后加载更多
        if autoLoadingNextPage && self.tableView(tableView, numberOfRowsInSection: 1) - indexPath.row < 2{
            scrollEndLoadingMore()
        }
        // 返回 Cell
        return dataSourceRefresh == nil ? UITableViewCell() : dataSourceRefresh!.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool{
        if let result = dataSourceRefresh?.tableView?(tableView, canEditRowAtIndexPath: indexPath){
           return result
        }
        return false
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath){
        dataSourceRefresh?.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if let result = dataSourceRefresh?.tableView?(tableView, heightForRowAtIndexPath: indexPath){
            return result
        }
        return UITableViewAutomaticDimension
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        if let result = dataSourceRefresh?.numberOfSectionsInTableView?(tableView){
            return result
        }
        return 1
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        //tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        return dataSourceRefresh?.tableView?(tableView, viewForHeaderInSection: section)
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //tableView.sectionFooterHeight = UITableViewAutomaticDimension
        return dataSourceRefresh?.tableView?(tableView, viewForFooterInSection: section)
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return dataSourceRefresh?.tableView?(tableView, titleForHeaderInSection: section)
    }
    // #UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dataSourceRefresh?.tableView?(tableView, didSelectRowAtIndexPath: indexPath)
    }
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?{
        if let result = dataSourceRefresh?.tableView?(tableView, editActionsForRowAtIndexPath: indexPath){
            return result
        }
        return nil
    }
    // #UITableViewDataSource:UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView){
        refreshController.scrollViewDidScroll(scrollView)
    }
    /// 数据加载
    func initLoadingData(){
        if isLoading {
            return
        }
        isLoading = true
        page = 0
        loadingType = LOADING_TYPE_INIT
        if dataArray.isEmpty{
            // 无数据,显示加载页面
            viewEmpty.hidden = true
            viewError.hidden = true
            tableView.hidden = true
            viewReloading.hidden = true
            viewLoading.hidden = false
        } else {
            // 有数据,显示重加载页面
            viewReloading.hidden = false
        }
        dataSourceRefresh?.loadingPageData(page, pageSize: pageSize)
    }
    /// 加载第一页数据
    func loadFirstPageData(){
        if isLoading {
            return
        }
        isLoading = true
        page = 0
        loadingType = LOADING_TYPE_FIRST
        dataSourceRefresh?.loadingPageData(page, pageSize: pageSize)
    }
    /// 加载下一页数据
    func loadNextPageData(){
        if isLoading {
            return
        }
        if hasMoreData {
            isLoading = true
            page = page + 1
            loadingType = LOADING_TYPE_NEXT
            dataSourceRefresh?.loadingPageData(page, pageSize: pageSize)
        }
    }
    /// 重新加载当前页数据
    func reloadCurrentPageData(){
        if isLoading {
            return
        }
        loadingType = LOADING_TYPE_RELOAD
        isLoading = true
        dataSourceRefresh?.loadingPageData(page, pageSize: pageSize)
    }
    /// 加载成功
    func loadingSuccess(dataArray:[AnyObject]?){
        isLoading = false
        endRefreshing()
        switch loadingType {
        case LOADING_TYPE_INIT,LOADING_TYPE_FIRST:
            // 第一页
            if !self.dataArray.isEmpty{
                self.dataArray.removeAll()
            }
            if dataArray != nil{
                self.dataArray.appendContentsOf(dataArray!)
            }
            hasMoreData = self.dataArray.count >= pageSize
            setupHasMoreDataView(hasMoreData)
            break
        case LOADING_TYPE_NEXT:
            // 下一页
            if dataArray != nil{
                self.dataArray.appendContentsOf(dataArray!)
                hasMoreData = dataArray!.count >= pageSize
                setupHasMoreDataView(hasMoreData)
            }else{
                hasMoreData = false
                setupHasMoreDataView(hasMoreData)
            }
            break
        case LOADING_TYPE_RELOAD:
            // 重新加载页
            if dataArray != nil{
                let start = page * pageSize
                self.dataArray.replaceRange(start ..< start+dataArray!.count, with: dataArray!)
            }
            break
        default:
            if !self.dataArray.isEmpty{
                self.dataArray.removeAll()
            }
            if dataArray != nil{
                self.dataArray.appendContentsOf(dataArray!)
            }
            hasMoreData = self.dataArray.count >= pageSize
            setupHasMoreDataView(hasMoreData)
            break
        }
        if self.dataArray.isEmpty{
            tableView.hidden = true
            viewEmpty.hidden = false
            viewError.hidden = true
            viewLoading.hidden = true
            viewReloading.hidden = true
        }else{
            tableView.hidden = false
            viewEmpty.hidden = true
            viewError.hidden = true
            viewLoading.hidden = true
            viewReloading.hidden = true
            tableView.reloadData()
        }
        loadingType = -1
        layoutIfNeeded()
    }
    /// 加载失败
    func loadingFailed(){
        isLoading = false
        endRefreshing()
        switch loadingType {
        case LOADING_TYPE_INIT:
            // 第一页
            tableView.hidden = true
            viewEmpty.hidden = true
            viewError.hidden = false
            viewLoading.hidden = true
            viewReloading.hidden = true
            break
        case LOADING_TYPE_NEXT:
            // 下一页
            page = page - 1
            break
        case LOADING_TYPE_RELOAD:
            // 重新加载页
            break
        default:
            break
        }
        loadingType = -1
        if !UtilEnvironment.isConnectedToNetwork && toastNetConnectError{
            showNetErrorSetting()
        }
        layoutIfNeeded()
    }
    /// 加载完成
    func onLodingPostExecute(result: HttpResponse){
        isLoading = false
        endRefreshing()
        if result.isSuccess(){
            // 加载成功
            switch loadingType {
            case LOADING_TYPE_INIT,LOADING_TYPE_FIRST:
                // 第一页
                if !dataArray.isEmpty{
                    dataArray.removeAll()
                }
                if result.resultExtraArray != nil{
                    dataArray.appendContentsOf(result.resultExtraArray!)
                }
                hasMoreData = dataArray.count >= pageSize
                setupHasMoreDataView(hasMoreData)
                break
            case LOADING_TYPE_NEXT:
                // 下一页
                if result.resultExtraArray != nil{
                    dataArray.appendContentsOf(result.resultExtraArray!)
                    hasMoreData = result.resultExtraArray!.count >= pageSize
                    setupHasMoreDataView(hasMoreData)
                }else{
                    hasMoreData = false
                    setupHasMoreDataView(hasMoreData)
                }
                break
            case LOADING_TYPE_RELOAD:
                // 重新加载页
                if result.resultExtraArray != nil{
                    let start = page * pageSize
                    dataArray.replaceRange(start ..< start+result.resultExtraArray!.count, with: result.resultExtraArray!)
                }
                break
            default:
                if !dataArray.isEmpty{
                    dataArray.removeAll()
                }
                if result.resultExtraArray != nil{
                    dataArray.appendContentsOf(result.resultExtraArray!)
                }
                hasMoreData = dataArray.count >= pageSize
                setupHasMoreDataView(hasMoreData)
                break
            }
            if dataArray.isEmpty{
                tableView.hidden = true
                viewEmpty.hidden = false
                viewError.hidden = true
                viewLoading.hidden = true
                viewReloading.hidden = true
            }else{
                tableView.hidden = false
                viewEmpty.hidden = true
                viewError.hidden = true
                viewLoading.hidden = true
                viewReloading.hidden = true
            }
            loadingType = -1
            tableView.reloadData()
            layoutIfNeeded()
        }else{
            // 加载失败
            switch loadingType {
            case LOADING_TYPE_INIT,LOADING_TYPE_FIRST:
                // 第一页
                break
            case LOADING_TYPE_NEXT:
                // 下一页
                page = page - 1
                break
            case LOADING_TYPE_RELOAD:
                // 重新加载页
                break
            default:
                break
            }
            loadingType = -1
            tableView.hidden = true
            viewEmpty.hidden = true
            viewError.hidden = false
            viewLoading.hidden = true
            viewReloading.hidden = true
            if !UtilEnvironment.isConnectedToNetwork && toastNetConnectError{
                showNetErrorSetting()
            }
            layoutIfNeeded()
        }
    }
    /// 获取指定 Indexpath 的数据
    func getDataForRowAtIndexPath(indexpath: NSIndexPath) -> AnyObject?{
        if indexpath.row < 0 || indexpath.row >= dataArray.count{
            return nil
        }
        return dataArray[indexpath.row]
    }
    /// 获取指定 Index 的数据
    func getDataForRowAtIndex(index: Int) -> AnyObject?{
        if index < 0 || index >= dataArray.count{
            return nil
        }
        return dataArray[index]
    }
    /// 滚动到最后加载更多
    private func scrollEndLoadingMore(){
        if isLoading{
            return
        }
        if hasMoreData{
            page = page + 1
            isLoading = true
            loadingType = LOADING_TYPE_NEXT
            dataSourceRefresh?.loadingPageData(page, pageSize: pageSize)
        }
    }
    /// 网络无连接提示
    private func showNetErrorSetting(){
        // 动画出现,y 轴值[-90 ~ 0]
        UIView.animateWithDuration(0.3) {
            [weak self] in
            if let wSelf = self{
                var frame = wSelf.viewErrorNetSetting.frame
                frame.origin.y = 0
                wSelf.viewErrorNetSetting.frame = frame
            }
        }
        performSelector(#selector(hideNetErrorSetting), withObject: self, afterDelay: 3 + 0.3)
    }
    /// 是否有还有更多
    private func setupHasMoreDataView(hasMore:Bool){
        if hasMore{
            if viewLoadingMore == nil{
                let frame = CGRectMake(0, 0, tableView.frame.width, 50)
                viewLoadingMore = UIView(frame: frame)
                let moreIndicator = MyLogoIndicator()
                moreIndicator.frame = CGRectMake(0, 0, 30, 30)
                moreIndicator.center = CGPointMake(frame.width / 2.0 - 70, 25)
                let moreLabel = MyUILabel()
                moreLabel.frame = CGRectMake(0, 0, tableView.frame.width, 21)
                moreLabel.center = CGPointMake(frame.width / 2.0, 25)
                moreLabel.textColor = utilShared.color.textGray
                moreLabel.font = utilShared.font.textTitle
                moreLabel.textAlignment = .Center
                moreLabel.text = "加载更多数据..."
                viewLoadingMore.backgroundColor = UIColor.clearColor()
                viewLoadingMore.addSubview(moreLabel)
                viewLoadingMore.addSubview(moreIndicator)
            }
            tableView.tableFooterView = viewLoadingMore
        }else if showLoadingFinishView{
            if viewLoadingFinish == nil{
                let frame = CGRectMake(0, 0, tableView.frame.width, 50)
                viewLoadingMore = UIView(frame: frame)
                let moreLabel = MyUILabel()
                moreLabel.frame = CGRectMake(0, 0, tableView.frame.width, 21)
                moreLabel.center = CGPointMake(frame.width / 2.0, 25)
                moreLabel.textColor = utilShared.color.textGray
                moreLabel.font = utilShared.font.textLabel
                moreLabel.textAlignment = .Center
                moreLabel.text = "━━　End　━━"
                viewLoadingMore.backgroundColor = UIColor.clearColor()
                viewLoadingMore.addSubview(moreLabel)
            }
            tableView.tableFooterView = viewLoadingMore
        }else{
            tableView.tableFooterView = nil
        }
    }
    /// 替换 DataArray 整个数组并刷新页面
    func replaceDataArray(dataArray:[AnyObject]?){
        if !self.dataArray.isEmpty{
            self.dataArray.removeAll()
        }
        if dataArray != nil && !dataArray!.isEmpty{
            self.dataArray.appendContentsOf(dataArray!)
        }
        if self.dataArray.isEmpty{
            tableView.hidden = true
            viewEmpty.hidden = false
            viewError.hidden = true
            viewLoading.hidden = true
            viewReloading.hidden = true
        }else{
            tableView.hidden = false
            viewEmpty.hidden = true
            viewError.hidden = true
            viewLoading.hidden = true
            viewReloading.hidden = true
        }
        tableView.reloadData()
        layoutIfNeeded()
    }
    /// 移除 Item 数据
    func removeDataByIndexPath(indexPath: NSIndexPath){
        if dataArray.isEmpty || indexPath.row < 0 || dataArray.count < indexPath.row{
            return
        }
        dataArray.removeAtIndex(indexPath.row)
        tableView.reloadData()
    }
    func removeDataByIndexPathAnimation(indexPath: NSIndexPath){
        if dataArray.isEmpty || indexPath.row < 0 || dataArray.count < indexPath.row{
            return
        }
        dataArray.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    }
    func removeData(data:AnyObject?){
        if dataArray.isEmpty || data == nil{
            return
        }
        if let index = dataArray.indexOf({ data!.hash == $0.hash }){
            dataArray.removeAtIndex(index)
            if dataArray.isEmpty{
                tableView.hidden = true
                viewEmpty.hidden = false
                viewError.hidden = true
                viewLoading.hidden = true
                viewReloading.hidden = true
            }else{
                tableView.hidden = false
                viewEmpty.hidden = true
                viewError.hidden = true
                viewLoading.hidden = true
                viewReloading.hidden = true
            }
            tableView.reloadData()
            layoutIfNeeded()

        }
    }
    func endRefreshing(){
        refreshController.endRefreshing()
    }
    @objc private func hideNetErrorSetting(){
        // 动态隐藏y 轴[0 ~ -90]
        UIView.animateWithDuration(0.3){
            [weak self]params in
            if let wSelf = self{
                var frame = wSelf.viewErrorNetSetting.frame
                frame.origin.y = -wSelf.viewErrorNetSettingHeight
                wSelf.viewErrorNetSetting.frame = frame
            }
        }
        
    }
    override func didMoveToSuperview(){
        super.didMoveToSuperview()
        if self.superview == nil && refreshController != nil{
            refreshController.endRefreshing()
        }
    }
    override func didMoveToWindow(){
        super.didMoveToWindow()
        #if TARGET_INTERFACE_BUILDER
            return
        #endif
        if self.window == nil && refreshController != nil{
            refreshController.endRefreshing()
        }
    }
    override func removeFromSuperview() {
        super.removeFromSuperview()
        #if TARGET_INTERFACE_BUILDER
            return
        #endif
        if refreshController != nil{
            refreshController.endRefreshing()
        }
    }
    var isEmpty: Bool{
        return dataArray == nil ? true : dataArray.isEmpty
    }
    
    // 定义 IB 显示效果
    override func prepareForInterfaceBuilder() {
        let table = UITableView(frame: CGRectMake(0, 35, self.frame.width, self.frame.height - 35))
        self.addSubview(table)
        let iconFrame = CGRectMake(0, 0, 30, 30)
        let bar = UIImageView(image: UtilPrepareForInterfaceBuilder.loadImage("loading_bar", self.classForCoder, self.traitCollection))
        bar.frame = iconFrame
        bar.center = CGPointMake(self.frame.width/2.0, 25)
        let bg = UIImageView(image: UtilPrepareForInterfaceBuilder.loadImage("loading_bar_bg", self.classForCoder, self.traitCollection))
        bg.frame = iconFrame
        bg.center = CGPointMake(self.frame.width/2.0, 25)
        self.addSubview(bar)
        self.addSubview(bg)
    }
}
@objc
protocol MyViewRefreshTableDataSource {
    func loadingPageData(page: Int,pageSize:Int)
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    //
    optional func numberOfSectionsInTableView(tableView: UITableView) -> Int
    optional func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    optional func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    optional func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    optional func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    optional func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    optional func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    optional func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    optional func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    
}
/// UIRefreshControl 下拉刷新控制[启动加载动画记得要 endRefreshing ]
class MyLogoRefreshControl: UIRefreshControl{
    private let LOGO_SIZE:CGFloat = 38
    private let LOGO_CENTER_Y:CGFloat = 28
    private var logo: Logo = {
        let view = Logo(frame:CGRectMake(0,0,38,38))
        return view
    }()
    private var bar: Bar = {
        let view = Bar(frame:CGRectMake(0,0,38,38))
        return view
    }()
    private(set) var isRefreshControlAnimating:Bool!
    private var refreshContainerView: UIView!
    
    override init() {
        super.init()
        setupRefreshControl()
        addTarget(self, action: #selector(triggerValueChange), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var refreshBounds = self.bounds
        
        // Distance the table has been pulled
        let pullDistance = max(0.0, -self.frame.origin.y)
        let pullRatio = min(max(pullDistance, 0.0), 140.0) / 500.0 //[0~140]

        refreshBounds.size.height = pullDistance;
        
        _ = [self.refreshContainerView].map({$0.frame = refreshBounds});
        
        // Don't rotate the gears if the refresh animation is playing
        if (!refreshing && !isRefreshControlAnimating) {
            // 放大
            let centerX = self.frame.width / 2.0
            let centerY = pullDistance / 2.0
            logo.center = CGPointMake(centerX , centerY > LOGO_CENTER_Y ? LOGO_CENTER_Y : centerY)
            let progress:CGFloat = (pullDistance > LOGO_SIZE ? LOGO_SIZE : pullDistance) / LOGO_SIZE
            logo.transform = CGAffineTransformMakeScale(progress, progress)
            // 旋转
            let scaleProgress = (centerY > LOGO_CENTER_Y ? LOGO_CENTER_Y : centerY) / LOGO_CENTER_Y
            bar.alpha = max(scaleProgress, 0.7) > 0.7 ? min(scaleProgress, 1.0) : 0.0
            bar.center = CGPointMake(centerX, LOGO_CENTER_Y)
            bar.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * pullRatio)
        }
        
        // If we're refreshing and the animation is not playing, then play the animation
        if (refreshing && !isRefreshControlAnimating) {
            UIView.animateWithDuration(0.3, delay: 0, options: .CurveLinear, animations: {
                [weak self] in
                if let wSelf = self{
                    let centerX = wSelf.frame.width / 2.0
                    wSelf.logo.center = CGPointMake(centerX , wSelf.LOGO_CENTER_Y)
                    wSelf.bar.center = CGPointMake(centerX , wSelf.LOGO_CENTER_Y)
                }
            }, completion:nil)
            animateRefreshView()
        }
    }
    func setupRefreshControl() {
        isRefreshControlAnimating = false
        refreshContainerView = UIView(frame: self.bounds)
        
        _ = [logo, bar].map { self.refreshContainerView.addSubview($0) }
        
        refreshContainerView.clipsToBounds = true
        tintColor = UIColor.clearColor()
        
        addSubview(self.refreshContainerView)
    }
    
    func animateRefreshView() {
        isRefreshControlAnimating = true
        UIView.animateWithDuration(0.6, delay: 0, options: .CurveLinear, animations: {
                [weak self] in
                if let wSelf = self{
                    wSelf.bar.transform = CGAffineTransformRotate(wSelf.bar.transform, CGFloat(M_PI))
                }
            }, completion: { [weak self]finished in
                // If still refreshing, keep spinning
                if let wSelf = self{
                    if (wSelf.refreshing) {
                        wSelf.animateRefreshView() //一定要调用endRefreshing方法,不然造成死递归
                    } else {
                        wSelf.isRefreshControlAnimating = false
                    }
                }
            }
        )
    }
    func triggerValueChange(){
        if !isRefreshControlAnimating{
            animateRefreshView()
        }
    }

//    override func willMoveToSuperview(newSuperview: UIView?) {
//        self.superview?.removeObserver(self, forKeyPath: "contentOffset", context: contentOffsetObservingKey)
//    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        let superview = self.superview
        //Mylog.log("didMoveToSuperview \(superview)")
        // Reposition ourself in the scrollview
        if superview is UIScrollView {
            //Mylog.log("superview is UIScrollView")
            //[self repositionAboveContent];
            //superview?.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.Old, context: contentOffsetObservingKey)
        
            //originalTopContentInset = [(UIScrollView *)superview contentInset].top;
        }
        // Set the 'UITableViewController.refreshControl' property, if applicable
//        if ([superview isKindOfClass:[UITableView class]]) {
//            UITableViewController *tableViewController = (UITableViewController *)superview.nextResponder;
//            if ([tableViewController isKindOfClass:[UITableViewController class]]) {
//                if (tableViewController.refreshControl != (id)self)
//                tableViewController.refreshControl = (id)self;
//            }
//        }
    }
    // UIView Animation 动画[UIView 整体动画]
    private class Logo: UIView{
        lazy private var backgroudLayer : CALayer = {
            return CALayer()
        }()
       
        override init(frame: CGRect) {
            super.init(frame: frame)
            clipsToBounds = true
            let imageBarLogo = UIImage(named: "loading_bar_bg")
            backgroudLayer.frame = frame
            backgroudLayer.contents = imageBarLogo?.CGImage
            backgroudLayer.masksToBounds = true
            backgroudLayer.anchorPoint = CGPoint(x: 0.5,y: 0.5) // Scale锚点
            self.layer.addSublayer(backgroudLayer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    private class Bar: UIView{
        lazy private var backgroudLayer : CALayer = { //CA[Code Animation]层 [The base layer class of View]
            return CALayer()
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            clipsToBounds = true
            let imageBarLogo = UIImage(named: "loading_bar")
            backgroudLayer.frame = frame
            backgroudLayer.contents = imageBarLogo?.CGImage
            backgroudLayer.masksToBounds = true
            self.layer.addSublayer(backgroudLayer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

