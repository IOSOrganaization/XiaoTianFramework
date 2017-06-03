//
//  MyViewRefreshTable.swift
//  DriftBook
//  可刷新的 Table
//  Created by 郭天蕊 on 2017/1/3.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class MyViewRefreshTable: UIView,UITableViewDataSource,UITableViewDelegate{
    // UI
    fileprivate let LOADING_TYPE_INIT = 0
    fileprivate let LOADING_TYPE_FIRST = 1
    fileprivate let LOADING_TYPE_NEXT = 2
    fileprivate let LOADING_TYPE_RELOAD = 3
    //
    fileprivate var viewErrorNetSetting: MyUIView!
    fileprivate var page = 0
    fileprivate var loadingType = -1 // 0初始化,1第一页,2下一页,3重新加载当前页
    fileprivate var isLoading = false
    fileprivate var hasMoreData = true
    fileprivate var viewErrorNetSettingHeight:CGFloat = 40
    fileprivate(set) var tableView:UITableView!
    fileprivate var refreshController:MyLogoRefreshControl!
    //
    var viewLoading: UIView!
    var viewEmpty: MyUIView!
    var viewError: MyUIView!
    var viewReloading: MyUIView!
    var viewLoadingMore: UIView!
    var viewLoadingFinish: UIView!
    fileprivate(set) var dataArray:[AnyObject]! = []
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
    
    fileprivate func initView(){
        // 初始化完成后,系统根据系统主题设置样式
        #if TARGET_INTERFACE_BUILDER
            return
        #endif
        let rootViews =  Bundle.main.loadNibNamed("MyViewTipMessage", owner: nil, options: nil)
        viewLoading = rootViews?[0] as? UIView
        viewEmpty = rootViews?[1] as? MyUIView
        viewError = rootViews?[2] as? MyUIView
        viewReloading = rootViews?[3] as? MyUIView
        viewErrorNetSetting = viewError.viewWithTag(4610) as? MyUIView
        //
        tableView = UITableView(frame: CGRect.zero, style: UITableViewStyle.plain)
        utilLayoutConstant(tableView).top().left().widthMultiplier(1).heightMultiplier(1) // x,y,w,h才能确定准确位置
        utilLayoutConstant(viewLoading).top().left().widthMultiplier(1).heightMultiplier(1)
        utilLayoutConstant(viewEmpty).top().left().widthMultiplier(1).heightMultiplier(1)
        utilLayoutConstant(viewError).top().left().widthMultiplier(1).heightMultiplier(1)
        utilLayoutConstant(viewReloading).top().left().widthMultiplier(1).heightMultiplier(1)
        //
        viewEmpty.isHidden = true
        viewError.isHidden = true
        tableView.isHidden = true
        viewReloading.isHidden = true
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
        refreshController.addTarget(self, action: #selector(loadFirstPageData), for: UIControlEvents.valueChanged)
        tableView.backgroundView = refreshController
    }
    
    override func awakeFromNib() {
        // 样式要在系统完全初始化后才不会被系统修改
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.backgroundColor = UIColor.clear
        layoutIfNeeded()
    }
//    func setupDataArray(dataArray:[AnyObject]?){
//        if dataArray == nil{
//            fatalError("Data Array 不能为空!")
//        }
//        self.dataArray  = dataArray
//    }
    // #UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let result = dataSourceRefresh?.tableView?(tableView, numberOfRowsInSection: section){
            return result
        }
        return dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        // 滚动到最后加载更多
        if autoLoadingNextPage && self.tableView(tableView, numberOfRowsInSection: 1) - indexPath.row < 2{
            scrollEndLoadingMore()
        }
        // 返回 Cell
        return dataSourceRefresh == nil ? UITableViewCell() : dataSourceRefresh!.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool{
        if let result = dataSourceRefresh?.tableView?(tableView, canEditRowAtIndexPath: indexPath){
           return result
        }
        return false
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        dataSourceRefresh?.tableView?(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        if let result = dataSourceRefresh?.tableView?(tableView, heightForRowAtIndexPath: indexPath){
            return result
        }
        return UITableViewAutomaticDimension
    }
    func numberOfSections(in tableView: UITableView) -> Int{
        if let result = dataSourceRefresh?.numberOfSectionsInTableView?(tableView){
            return result
        }
        return 1
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{
        //tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        return dataSourceRefresh?.tableView?(tableView, viewForHeaderInSection: section)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //tableView.sectionFooterHeight = UITableViewAutomaticDimension
        return dataSourceRefresh?.tableView?(tableView, viewForFooterInSection: section)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return dataSourceRefresh?.tableView?(tableView, titleForHeaderInSection: section)
    }
    // #UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataSourceRefresh?.tableView?(tableView, didSelectRowAtIndexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?{
        if let result = dataSourceRefresh?.tableView?(tableView, editActionsForRowAtIndexPath: indexPath){
            return result
        }
        return nil
    }
    // #UITableViewDataSource:UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView){
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
            viewEmpty.isHidden = true
            viewError.isHidden = true
            tableView.isHidden = true
            viewReloading.isHidden = true
            viewLoading.isHidden = false
        } else {
            // 有数据,显示重加载页面
            viewReloading.isHidden = false
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
    func loadingSuccess(_ dataArray:[AnyObject]?){
        isLoading = false
        endRefreshing()
        switch loadingType {
        case LOADING_TYPE_INIT,LOADING_TYPE_FIRST:
            // 第一页
            if !self.dataArray.isEmpty{
                self.dataArray.removeAll()
            }
            if dataArray != nil{
                self.dataArray.append(contentsOf: dataArray!)
            }
            hasMoreData = self.dataArray.count >= pageSize
            setupHasMoreDataView(hasMoreData)
            break
        case LOADING_TYPE_NEXT:
            // 下一页
            if dataArray != nil{
                self.dataArray.append(contentsOf: dataArray!)
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
                self.dataArray.replaceSubrange(start ..< start+dataArray!.count, with: dataArray!)
            }
            break
        default:
            if !self.dataArray.isEmpty{
                self.dataArray.removeAll()
            }
            if dataArray != nil{
                self.dataArray.append(contentsOf: dataArray!)
            }
            hasMoreData = self.dataArray.count >= pageSize
            setupHasMoreDataView(hasMoreData)
            break
        }
        if self.dataArray.isEmpty{
            tableView.isHidden = true
            viewEmpty.isHidden = false
            viewError.isHidden = true
            viewLoading.isHidden = true
            viewReloading.isHidden = true
        }else{
            tableView.isHidden = false
            viewEmpty.isHidden = true
            viewError.isHidden = true
            viewLoading.isHidden = true
            viewReloading.isHidden = true
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
            tableView.isHidden = true
            viewEmpty.isHidden = true
            viewError.isHidden = false
            viewLoading.isHidden = true
            viewReloading.isHidden = true
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
    func onLodingPostExecute(_ result: HttpResponse){
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
                    dataArray.append(contentsOf: result.resultExtraArray!)
                }
                hasMoreData = dataArray.count >= pageSize
                setupHasMoreDataView(hasMoreData)
                break
            case LOADING_TYPE_NEXT:
                // 下一页
                if result.resultExtraArray != nil{
                    dataArray.append(contentsOf: result.resultExtraArray!)
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
                    dataArray.replaceSubrange(start ..< start+result.resultExtraArray!.count, with: result.resultExtraArray!)
                }
                break
            default:
                if !dataArray.isEmpty{
                    dataArray.removeAll()
                }
                if result.resultExtraArray != nil{
                    dataArray.append(contentsOf: result.resultExtraArray!)
                }
                hasMoreData = dataArray.count >= pageSize
                setupHasMoreDataView(hasMoreData)
                break
            }
            if dataArray.isEmpty{
                tableView.isHidden = true
                viewEmpty.isHidden = false
                viewError.isHidden = true
                viewLoading.isHidden = true
                viewReloading.isHidden = true
            }else{
                tableView.isHidden = false
                viewEmpty.isHidden = true
                viewError.isHidden = true
                viewLoading.isHidden = true
                viewReloading.isHidden = true
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
            tableView.isHidden = true
            viewEmpty.isHidden = true
            viewError.isHidden = false
            viewLoading.isHidden = true
            viewReloading.isHidden = true
            if !UtilEnvironment.isConnectedToNetwork && toastNetConnectError{
                showNetErrorSetting()
            }
            layoutIfNeeded()
        }
    }
    /// 获取指定 Indexpath 的数据
    func getDataForRowAtIndexPath(_ indexpath: IndexPath) -> AnyObject?{
        if indexpath.row < 0 || indexpath.row >= dataArray.count{
            return nil
        }
        return dataArray[indexpath.row]
    }
    /// 获取指定 Index 的数据
    func getDataForRowAtIndex(_ index: Int) -> AnyObject?{
        if index < 0 || index >= dataArray.count{
            return nil
        }
        return dataArray[index]
    }
    /// 滚动到最后加载更多
    fileprivate func scrollEndLoadingMore(){
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
    fileprivate func showNetErrorSetting(){
        // 动画出现,y 轴值[-90 ~ 0]
        UIView.animate(withDuration: 0.3, animations: {
            [weak self] in
            if let wSelf = self{
                var frame = wSelf.viewErrorNetSetting.frame
                frame.origin.y = 0
                wSelf.viewErrorNetSetting.frame = frame
            }
        }) 
        perform(#selector(hideNetErrorSetting), with: self, afterDelay: 3 + 0.3)
    }
    /// 是否有还有更多
    fileprivate func setupHasMoreDataView(_ hasMore:Bool){
        if hasMore{
            if viewLoadingMore == nil{
                let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
                viewLoadingMore = UIView(frame: frame)
                let moreIndicator = MyLogoIndicator()
                moreIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                moreIndicator.center = CGPoint(x: frame.width / 2.0 - 70, y: 25)
                let moreLabel = MyUILabel()
                moreLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 21)
                moreLabel.center = CGPoint(x: frame.width / 2.0, y: 25)
                moreLabel.textColor = utilShared.color.textGray
                moreLabel.font = utilShared.font.textTitle
                moreLabel.textAlignment = .center
                moreLabel.text = "加载更多数据..."
                viewLoadingMore.backgroundColor = UIColor.clear
                viewLoadingMore.addSubview(moreLabel)
                viewLoadingMore.addSubview(moreIndicator)
            }
            tableView.tableFooterView = viewLoadingMore
        }else if showLoadingFinishView{
            if viewLoadingFinish == nil{
                let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50)
                viewLoadingMore = UIView(frame: frame)
                let moreLabel = MyUILabel()
                moreLabel.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 21)
                moreLabel.center = CGPoint(x: frame.width / 2.0, y: 25)
                moreLabel.textColor = utilShared.color.textGray
                moreLabel.font = utilShared.font.textLabel
                moreLabel.textAlignment = .center
                moreLabel.text = "━━　End　━━"
                viewLoadingMore.backgroundColor = UIColor.clear
                viewLoadingMore.addSubview(moreLabel)
            }
            tableView.tableFooterView = viewLoadingMore
        }else{
            tableView.tableFooterView = nil
        }
    }
    /// 替换 DataArray 整个数组并刷新页面
    func replaceDataArray(_ dataArray:[AnyObject]?){
        if !self.dataArray.isEmpty{
            self.dataArray.removeAll()
        }
        if dataArray != nil && !dataArray!.isEmpty{
            self.dataArray.append(contentsOf: dataArray!)
        }
        if self.dataArray.isEmpty{
            tableView.isHidden = true
            viewEmpty.isHidden = false
            viewError.isHidden = true
            viewLoading.isHidden = true
            viewReloading.isHidden = true
        }else{
            tableView.isHidden = false
            viewEmpty.isHidden = true
            viewError.isHidden = true
            viewLoading.isHidden = true
            viewReloading.isHidden = true
        }
        tableView.reloadData()
        layoutIfNeeded()
    }
    /// 移除 Item 数据
    func removeDataByIndexPath(_ indexPath: IndexPath){
        if dataArray.isEmpty || indexPath.row < 0 || dataArray.count < indexPath.row{
            return
        }
        dataArray.remove(at: indexPath.row)
        tableView.reloadData()
    }
    func removeDataByIndexPathAnimation(_ indexPath: IndexPath){
        if dataArray.isEmpty || indexPath.row < 0 || dataArray.count < indexPath.row{
            return
        }
        dataArray.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    func removeData(_ data:AnyObject?){
        if dataArray.isEmpty || data == nil{
            return
        }
        if let index = dataArray.index(where: { data!.hash == $0.hash }){
            dataArray.remove(at: index)
            if dataArray.isEmpty{
                tableView.isHidden = true
                viewEmpty.isHidden = false
                viewError.isHidden = true
                viewLoading.isHidden = true
                viewReloading.isHidden = true
            }else{
                tableView.isHidden = false
                viewEmpty.isHidden = true
                viewError.isHidden = true
                viewLoading.isHidden = true
                viewReloading.isHidden = true
            }
            tableView.reloadData()
            layoutIfNeeded()

        }
    }
    func endRefreshing(){
        refreshController.endRefreshing()
    }
    @objc fileprivate func hideNetErrorSetting(){
        // 动态隐藏y 轴[0 ~ -90]
        UIView.animate(withDuration: 0.3, animations: {
            [weak self]params in
            if let wSelf = self{
                var frame = wSelf.viewErrorNetSetting.frame
                frame.origin.y = -wSelf.viewErrorNetSettingHeight
                wSelf.viewErrorNetSetting.frame = frame
            }
        })
        
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
        let table = UITableView(frame: CGRect(x: 0, y: 35, width: self.frame.width, height: self.frame.height - 35))
        self.addSubview(table)
        let iconFrame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let bar = UIImageView(image: UtilPrepareForInterfaceBuilder.loadImage("loading_bar", self.classForCoder, self.traitCollection))
        bar.frame = iconFrame
        bar.center = CGPoint(x: self.frame.width/2.0, y: 25)
        let bg = UIImageView(image: UtilPrepareForInterfaceBuilder.loadImage("loading_bar_bg", self.classForCoder, self.traitCollection))
        bg.frame = iconFrame
        bg.center = CGPoint(x: self.frame.width/2.0, y: 25)
        self.addSubview(bar)
        self.addSubview(bg)
    }
}
@objc
protocol MyViewRefreshTableDataSource {
    func loadingPageData(_ page: Int,pageSize:Int)
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    //
    @objc optional func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    @objc optional func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
    @objc optional func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    @objc optional func tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func tableView(_ tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: IndexPath)
    @objc optional func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    @objc optional func tableView(_ tableView: UITableView, editActionsForRowAtIndexPath indexPath: IndexPath) -> [UITableViewRowAction]?
    @objc optional func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    @objc optional func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    @objc optional func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    
}
/// UIRefreshControl 下拉刷新控制[启动加载动画记得要 endRefreshing ]
class MyLogoRefreshControl: UIRefreshControl{
    fileprivate let LOGO_SIZE:CGFloat = 38
    fileprivate let LOGO_CENTER_Y:CGFloat = 28
    fileprivate var logo: Logo = {
        let view = Logo(frame:CGRect(x: 0,y: 0,width: 38,height: 38))
        return view
    }()
    fileprivate var bar: Bar = {
        let view = Bar(frame:CGRect(x: 0,y: 0,width: 38,height: 38))
        return view
    }()
    fileprivate(set) var isRefreshControlAnimating:Bool!
    fileprivate var refreshContainerView: UIView!
    
    override init() {
        super.init()
        setupRefreshControl()
        addTarget(self, action: #selector(triggerValueChange), for: UIControlEvents.valueChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var refreshBounds = self.bounds
        
        // Distance the table has been pulled
        let pullDistance = max(0.0, -self.frame.origin.y)
        let pullRatio = min(max(pullDistance, 0.0), 140.0) / 500.0 //[0~140]

        refreshBounds.size.height = pullDistance;
        
        _ = [self.refreshContainerView].map({$0.frame = refreshBounds});
        
        // Don't rotate the gears if the refresh animation is playing
        if (!isRefreshing && !isRefreshControlAnimating) {
            // 放大
            let centerX = self.frame.width / 2.0
            let centerY = pullDistance / 2.0
            logo.center = CGPoint(x: centerX , y: centerY > LOGO_CENTER_Y ? LOGO_CENTER_Y : centerY)
            let progress:CGFloat = (pullDistance > LOGO_SIZE ? LOGO_SIZE : pullDistance) / LOGO_SIZE
            logo.transform = CGAffineTransform(scaleX: progress, y: progress)
            // 旋转
            let scaleProgress = (centerY > LOGO_CENTER_Y ? LOGO_CENTER_Y : centerY) / LOGO_CENTER_Y
            bar.alpha = max(scaleProgress, 0.7) > 0.7 ? min(scaleProgress, 1.0) : 0.0
            bar.center = CGPoint(x: centerX, y: LOGO_CENTER_Y)
            bar.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI) * pullRatio)
        }
        
        // If we're refreshing and the animation is not playing, then play the animation
        if (isRefreshing && !isRefreshControlAnimating) {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
                [weak self] in
                if let wSelf = self{
                    let centerX = wSelf.frame.width / 2.0
                    wSelf.logo.center = CGPoint(x: centerX , y: wSelf.LOGO_CENTER_Y)
                    wSelf.bar.center = CGPoint(x: centerX , y: wSelf.LOGO_CENTER_Y)
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
        tintColor = UIColor.clear
        
        addSubview(self.refreshContainerView)
    }
    
    func animateRefreshView() {
        isRefreshControlAnimating = true
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveLinear, animations: {
                [weak self] in
                if let wSelf = self{
                    wSelf.bar.transform = wSelf.bar.transform.rotated(by: CGFloat(M_PI))
                }
            }, completion: { [weak self]finished in
                // If still refreshing, keep spinning
                if let wSelf = self{
                    if (wSelf.isRefreshing) {
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
    fileprivate class Logo: UIView{
        lazy fileprivate var backgroudLayer : CALayer = {
            return CALayer()
        }()
       
        override init(frame: CGRect) {
            super.init(frame: frame)
            clipsToBounds = true
            let imageBarLogo = UIImage(named: "loading_bar_bg")
            backgroudLayer.frame = frame
            backgroudLayer.contents = imageBarLogo?.cgImage
            backgroudLayer.masksToBounds = true
            backgroudLayer.anchorPoint = CGPoint(x: 0.5,y: 0.5) // Scale锚点
            self.layer.addSublayer(backgroudLayer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    fileprivate class Bar: UIView{
        lazy fileprivate var backgroudLayer : CALayer = { //CA[Code Animation]层 [The base layer class of View]
            return CALayer()
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            clipsToBounds = true
            let imageBarLogo = UIImage(named: "loading_bar")
            backgroudLayer.frame = frame
            backgroudLayer.contents = imageBarLogo?.cgImage
            backgroudLayer.masksToBounds = true
            self.layer.addSublayer(backgroudLayer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

