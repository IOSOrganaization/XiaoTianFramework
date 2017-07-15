//
//  UtilUITableView.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/7/14.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

open class UtilUITableView: NSObject{
    
    /// 系统下拉刷新
    @discardableResult
    open class func addRefreshControl(_ table:UITableView?,_ target:Any,_ selector:Selector) -> UIRefreshControl?{
        if let table = table{
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(target, action: selector, for: .valueChanged)// 触发事件
            table.addSubview(refreshControl)// 系统自动处理添加位置,下拉头InserContent事件
            return refreshControl
        }
        return nil
    }
    /// 系统下拉刷新匿名函数模式
    @discardableResult
    open class func addRefreshControl(_ table:UITableView?,_ refresh:@escaping (UITableView,UIRefreshControl)->()) -> UIRefreshControl?{
        if let table = table{
            let refreshControl = UIRefreshControl()
            //refreshControl.backgroundColor = UIColor.lightGray
            refreshControl.addTarget(table, action: #selector(UITableView.refreshControlAction), for: .valueChanged)// 触发事件
            table.addSubview(refreshControl)// 系统自动处理添加位置,下拉头InserContent事件
            objc_setAssociatedObject(table, &UITableView.RefreshAction.KEY_ACTION, refresh, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(table, &UITableView.RefreshAction.KEY_REFRESH_CONTROL, refreshControl, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return refreshControl
        }
        return nil
    }
    
    // 添加搜索控制器
    @discardableResult
    open class func addSearchController(rootViewControl:UIViewController, tableVeiw:UITableView?, textHolder:String? = nil, resultDelegate:UISearchResultsUpdating? = nil, resultsViewController:UIViewController? = nil, colorTintBar:UIColor? = nil, colorTint:UIColor? = nil, colorBackground:UIColor? = nil, imageSearchField:UIImage? = nil) -> UISearchController{
        //Pass nil if you wish to display search results in the same view that you are searching
        let searchControl = UISearchController(searchResultsController: nil) // 结果显示所在的VC(nil:当前table所在VC,searchControl.isActive:是否激活搜索器修改TableView显示)
        searchControl.searchResultsUpdater = resultDelegate //结果回调
        searchControl.dimsBackgroundDuringPresentation = false //显示时背景变暗
        searchControl.searchBar.placeholder = textHolder //输入占位符
        searchControl.hidesNavigationBarDuringPresentation = true
        if colorTintBar != nil{
            searchControl.searchBar.barTintColor = colorTintBar //激活是Bar的颜色
        }
        if colorTint != nil{
            searchControl.searchBar.tintColor = colorTint //
        }
        if colorBackground != nil{
            searchControl.searchBar.backgroundColor = colorBackground
            searchControl.searchBar.backgroundImage = nil // 有背景图的话,背景色无效
        }
        if imageSearchField != nil{
            searchControl.searchBar.searchBarStyle = .prominent //输入背景样式: default:默认根据主题(突出),minimal:最小的淡淡突出,prominent:背景颜色突出
            searchControl.searchBar.setSearchFieldBackgroundImage(imageSearchField, for: .normal)
        }
        //
        tableVeiw?.tableHeaderView = searchControl.searchBar
        tableVeiw?.alwaysBounceVertical = true
        // 去掉显示上下文边界限制(false:完全匹配根VC的位置大小,true:自动调整适应边界)
        rootViewControl.definesPresentationContext = true
        // 边界插入扩展布局(上,下自动插入, 与extendedLayoutIncludesOpaqueBars同时使用)
        //edgesForExtendedLayout tells what edges should be extended (left, right, top, bottom, all, none or any combination of those). Extending bottom edge equals "Under Bottom Bars" tick, extending top edge equals "Under Top Bars" tick.
        rootViewControl.edgesForExtendedLayout = [.top,.bottom]
        // 扩展布局包含状态栏在内
        //extendedLayoutIncludesOpaqueBars tells if edges should be automatically extended under the opaque bars. So if you combine those two settings you can mimic any combination of interface builder ticks in your code.
        rootViewControl.extendedLayoutIncludesOpaqueBars = true
        // 由系统自动调整插入ScrollView的距离
        rootViewControl.automaticallyAdjustsScrollViewInsets = true
        //把searchControl绑定到VC中,不然如果没有手动在VC中存储searchControl引用, 本function执行完 searchControl就直接被系统回收,所有效果出现神奇异常
        objc_setAssociatedObject(rootViewControl, &UITableView.RefreshAction.KEY_SEARCH_CONTROL, searchControl, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return searchControl
    }
}
/// 下拉刷新匿名函数模式
extension UITableView{
    fileprivate struct RefreshAction{
        static var KEY_ACTION = "UITableView.RefreshAction.KEY_ACTION"
        static var KEY_REFRESH_CONTROL = "UITableView.RefreshAction.KEY_REFRESH_CONTROL"
        static var KEY_SEARCH_CONTROL = "UITableView.RefreshAction.KEY_SEARCH_CONTROL"
    }
    
    @objc
    fileprivate func refreshControlAction(){
        guard let action = objc_getAssociatedObject(self, &RefreshAction.KEY_ACTION) as? (UITableView,UIRefreshControl) -> () else {
            return
        }
        guard let refresh = objc_getAssociatedObject(self, &RefreshAction.KEY_REFRESH_CONTROL) as? UIRefreshControl else {
            return
        }
        action(self,refresh)
    }
}
