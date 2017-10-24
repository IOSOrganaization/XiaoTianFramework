//
//  CAPSScrollMenu.swift
//  Vegetables
//
//  Created by guotianrui on 2017/9/30.
//  Copyright © 2017年 hexinglong. All rights reserved.
//
import UIKit
import Foundation

@objc
public protocol CAPSScrollMenuDelegate {
    @objc
    optional func didMoveToMenu(_ scrollMenu: CAPSScrollMenu, index: Int)
}

public class CAPSScrollMenuItem: UIView {
    var titleLabel : UILabel?
    
    func setUpMenuItemView(_ menuItemWidth: CGFloat, menuScrollViewHeight: CGFloat, indicatorHeight: CGFloat) {
        titleLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: menuItemWidth, height: menuScrollViewHeight - indicatorHeight))
        self.addSubview(titleLabel!)
    }
    
    func setTitleText(_ text: NSString) {
        if titleLabel != nil {
            titleLabel!.text = text as String
            titleLabel!.numberOfLines = 0
            titleLabel!.sizeToFit()
        }
    }
}

public enum CAPSScrollMenuOption {
    case selectionIndicatorHeight(CGFloat)
    case menuItemSeparatorWidth(CGFloat)
    case scrollMenuBackgroundColor(UIColor)
    case viewBackgroundColor(UIColor)
    case bottomMenuHairlineColor(UIColor)
    case selectionIndicatorColor(UIColor)
    case menuItemSeparatorColor(UIColor)
    case menuMargin(CGFloat)
    case menuItemMargin(CGFloat)
    case menuHeight(CGFloat)
    case selectedMenuItemLabelColor(UIColor)
    case unselectedMenuItemLabelColor(UIColor)
    case addMenuItemSeparator(Bool)
    case menuItemSeparatorRoundEdges(Bool)
    case menuItemFont(UIFont)
    case menuItemSeparatorPercentageHeight(CGFloat)
    case menuItemWidth(CGFloat)
    case enableHorizontalBounce(Bool)
    case addBottomMenuHairline(Bool)
    case menuItemWidthBasedOnTitleTextWidth(Bool)
    case titleTextSizeBasedOnMenuItemWidth(Bool)
}

@IBDesignable
open class CAPSScrollMenu: UIView, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    let menuScrollView = UIScrollView()
    var menuItems : [CAPSScrollMenuItem] = []
    var menuItemWidths : [CGFloat] = []
    var menuTitles:[String] = []
    
    open var menuHeight : CGFloat = 34.0
    open var menuMargin : CGFloat = 15.0
    open var menuItemWidth : CGFloat = 111.0
    open var selectionIndicatorHeight : CGFloat = 3.0
    var totalMenuItemWidthIfDifferentWidths : CGFloat = 0.0
    var startingMenuMargin : CGFloat = 0.0
    var menuItemMargin : CGFloat = 0.0
    
    var selectionIndicatorView : UIView = UIView()
    
    var currentMenuIndex : Int = 0
    var lastPageIndex : Int = 0
    
    open var selectionIndicatorColor : UIColor = UIColor.white
    open var selectedMenuItemLabelColor : UIColor = UIColor.white
    open var unselectedMenuItemLabelColor : UIColor = UIColor.lightGray
    open var scrollMenuBackgroundColor : UIColor = UIColor.black
    open var viewBackgroundColor : UIColor = UIColor.white
    open var bottomMenuHairlineColor : UIColor = UIColor.white
    open var menuItemSeparatorColor : UIColor = UIColor.lightGray
    
    open var menuItemFont : UIFont = UIFont.systemFont(ofSize: 15.0)
    open var menuItemSeparatorPercentageHeight : CGFloat = 0.8
    open var menuItemSeparatorWidth : CGFloat = 0.5
    open var menuItemSeparatorRoundEdges : Bool = false
    
    open var addBottomMenuHairline : Bool = true
    open var addMenuItemSeparator : Bool = false
    open var menuItemWidthBasedOnTitleTextWidth : Bool = false
    open var titleTextSizeBasedOnMenuItemWidth : Bool = false
    open var centerMenuItems : Bool = false
    open var enableHorizontalBounce : Bool = true
    
    var currentOrientationIsPortrait : Bool = true
    var pageIndexForOrientationChange : Int = 0
    var didLayoutSubviewsAfterRotation : Bool = false
    var didScrollAlready : Bool = false
    
    var lastControllerScrollViewContentOffset : CGFloat = 0.0
    
    var startingPageForScroll : Int = 0
    var didTapMenuItemToScroll : Bool = false
    
    open weak var delegate : CAPSScrollMenuDelegate?
    
    var tapTimer : Timer?
    
    public func setupMenu(_ menuTitles: [String], menuOptions: [CAPSScrollMenuOption]? = nil){
        
        self.menuTitles = menuTitles
        if let options = menuOptions {
            for option in options {
                switch (option) {
                case let .selectionIndicatorHeight(value):
                    selectionIndicatorHeight = value
                case let .menuItemSeparatorWidth(value):
                    menuItemSeparatorWidth = value
                case let .scrollMenuBackgroundColor(value):
                    scrollMenuBackgroundColor = value
                case let .viewBackgroundColor(value):
                    viewBackgroundColor = value
                case let .bottomMenuHairlineColor(value):
                    bottomMenuHairlineColor = value
                case let .selectionIndicatorColor(value):
                    selectionIndicatorColor = value
                case let .menuItemSeparatorColor(value):
                    menuItemSeparatorColor = value
                case let .menuMargin(value):
                    menuMargin = value
                case let .menuItemMargin(value):
                    menuItemMargin = value
                case let .menuHeight(value):
                    menuHeight = value
                case let .selectedMenuItemLabelColor(value):
                    selectedMenuItemLabelColor = value
                case let .unselectedMenuItemLabelColor(value):
                    unselectedMenuItemLabelColor = value
                case let .menuItemSeparatorRoundEdges(value):
                    menuItemSeparatorRoundEdges = value
                case let .addMenuItemSeparator(value):
                    addMenuItemSeparator = value
                case let .menuItemFont(value):
                    menuItemFont = value
                case let .menuItemSeparatorPercentageHeight(value):
                    menuItemSeparatorPercentageHeight = value
                case let .menuItemWidth(value):
                    menuItemWidth = value
                case let .enableHorizontalBounce(value):
                    enableHorizontalBounce = value
                case let .addBottomMenuHairline(value):
                    addBottomMenuHairline = value
                case let .menuItemWidthBasedOnTitleTextWidth(value):
                    menuItemWidthBasedOnTitleTextWidth = value
                case let .titleTextSizeBasedOnMenuItemWidth(value):
                    titleTextSizeBasedOnMenuItemWidth = value
                }
            }
        }
        
        setUpUserInterface()
        
        if menuScrollView.subviews.count == 0 {
            configureUserInterface()
        }
    }
    
    // MARK: - UI Setup
    public func setUpUserInterface() {
        // Set up menu scroll view
        menuScrollView.translatesAutoresizingMaskIntoConstraints = false
        menuScrollView.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: menuHeight)
        
        self.addSubview(menuScrollView)
        
        let menuScrollView_constraint_H:Array = NSLayoutConstraint.constraints(withVisualFormat: "H:|[menuScrollView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menuScrollView":menuScrollView])
        let menuScrollView_constraint_V:Array = NSLayoutConstraint.constraints(withVisualFormat: "V:|[menuScrollView(\(menuHeight))]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menuScrollView":menuScrollView])
        self.addConstraints(menuScrollView_constraint_H)
        self.addConstraints(menuScrollView_constraint_V)
        
        // Add hairline to menu scroll view
        if addBottomMenuHairline {
            let menuBottomHairline : UIView = UIView()
            menuBottomHairline.backgroundColor = bottomMenuHairlineColor
            menuBottomHairline.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(menuBottomHairline)
            let menuBottomHairline_constraint_H:Array = NSLayoutConstraint.constraints(withVisualFormat: "H:|[menuBottomHairline]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
            let menuBottomHairline_constraint_V:Array = NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(menuHeight)-[menuBottomHairline(0.5)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["menuBottomHairline":menuBottomHairline])
            self.addConstraints(menuBottomHairline_constraint_H)
            self.addConstraints(menuBottomHairline_constraint_V)
        }
        // Disable scroll bars
        menuScrollView.showsHorizontalScrollIndicator = false
        menuScrollView.showsVerticalScrollIndicator = false
        // Set background color behind scroll views and for menu scroll view
        self.backgroundColor = viewBackgroundColor
        menuScrollView.backgroundColor = scrollMenuBackgroundColor
    }
    
    public func configureUserInterface() {
        // Add tap gesture recognizer to controller scroll view to recognize menu item selection
        let menuItemTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMenuItemTap(_:)))
        menuItemTapGestureRecognizer.numberOfTapsRequired = 1
        menuItemTapGestureRecognizer.numberOfTouchesRequired = 1
        menuItemTapGestureRecognizer.delegate = self
        menuScrollView.addGestureRecognizer(menuItemTapGestureRecognizer)
        // When the user taps the status bar, the scroll view beneath the touch which is closest to the status bar will be scrolled to top,
        // but only if its `scrollsToTop` property is YES, its delegate does not return NO from `shouldScrollViewScrollToTop`, and it is not already at the top.
        // If more than one scroll view is found, none will be scrolled.
        // Disable scrollsToTop for menu and controller scroll views so that iOS finds scroll views within our pages on status bar tap gesture.
        menuScrollView.scrollsToTop = false;
        
        // Configure menu scroll view
        menuScrollView.contentSize = CGSize(width: (menuItemWidth + menuMargin) * CGFloat(menuTitles.count) + menuMargin, height: menuHeight)
        
        var index : CGFloat = 0.0
        
        for (titleIndex, titleText) in menuTitles.enumerated() {
            // Set up menu item for menu scroll view
            var menuItemFrame : CGRect = CGRect()
            
            if menuItemWidthBasedOnTitleTextWidth {
                let itemWidthRect : CGRect = (titleText as NSString).boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:menuItemFont], context: nil)
                menuItemWidth = itemWidthRect.width
                menuItemFrame = CGRect(x: totalMenuItemWidthIfDifferentWidths + menuMargin + (menuMargin * index), y: 0.0, width: menuItemWidth, height: menuHeight)
                totalMenuItemWidthIfDifferentWidths += itemWidthRect.width
                menuItemWidths.append(itemWidthRect.width)
            } else {
                if centerMenuItems && index == 0.0  {
                    startingMenuMargin = ((self.frame.width - ((CGFloat(menuItems.count) * menuItemWidth) + (CGFloat(menuItems.count - 1) * menuMargin))) / 2.0) -  menuMargin
                    
                    if startingMenuMargin < 0.0 {
                        startingMenuMargin = 0.0
                    }
                    
                    menuItemFrame = CGRect(x: startingMenuMargin + menuMargin, y: 0.0, width: menuItemWidth, height: menuHeight)
                } else {
                    menuItemFrame = CGRect(x: menuItemWidth * index + menuMargin * (index + 1) + startingMenuMargin, y: 0.0, width: menuItemWidth, height: menuHeight)
                }
            }
            
            let menuItemView : CAPSScrollMenuItem = CAPSScrollMenuItem(frame: menuItemFrame)
            menuItemView.setUpMenuItemView(menuItemWidth, menuScrollViewHeight: menuHeight, indicatorHeight: selectionIndicatorHeight)
            
            // Configure menu item label font if font is set by user
            menuItemView.titleLabel!.font = menuItemFont
            menuItemView.titleLabel!.textAlignment = NSTextAlignment.center
            menuItemView.titleLabel!.textColor = unselectedMenuItemLabelColor
            menuItemView.titleLabel!.adjustsFontSizeToFitWidth = titleTextSizeBasedOnMenuItemWidth
            menuItemView.titleLabel!.text = titleText
            // Add menu item view to menu scroll view
            menuScrollView.addSubview(menuItemView)
            
            // Add menu item separator
            if addMenuItemSeparator && titleIndex + 1 < menuTitles.count{
                let menuItemSeparator = UIView(frame: CGRect(x: menuItemFrame.maxX + menuMargin/2 - (menuItemSeparatorWidth / 2), y: floor(menuHeight * ((1.0 - menuItemSeparatorPercentageHeight) / 2.0)), width: menuItemSeparatorWidth, height: floor(menuHeight * menuItemSeparatorPercentageHeight)))
                menuItemSeparator.backgroundColor = menuItemSeparatorColor
                if menuItemSeparatorRoundEdges {
                    menuItemSeparator.layer.cornerRadius = menuItemSeparator.frame.width / 2
                }
                menuScrollView.addSubview(menuItemSeparator)
            }
            menuItems.append(menuItemView)
            
            index += 1
        }
        
        // Set new content size for menu scroll view if needed
        if menuItemWidthBasedOnTitleTextWidth {
            menuScrollView.contentSize = CGSize(width: (totalMenuItemWidthIfDifferentWidths + menuMargin) + CGFloat(menuTitles.count) * menuMargin, height: menuHeight)
        }
        
        // Set selected color for title label of selected menu item
        if menuTitles.count > 0 {
            if menuItems[currentMenuIndex].titleLabel != nil {
                menuItems[currentMenuIndex].titleLabel!.textColor = selectedMenuItemLabelColor
            }
        }
        
        // Configure selection indicator view
        var selectionIndicatorFrame : CGRect = CGRect()
        if menuItemWidthBasedOnTitleTextWidth {
            selectionIndicatorFrame = CGRect(x: menuMargin, y: menuHeight - selectionIndicatorHeight, width: menuItemWidths[0], height: selectionIndicatorHeight)
        } else {
            if centerMenuItems  {
                selectionIndicatorFrame = CGRect(x: startingMenuMargin + menuMargin, y: menuHeight - selectionIndicatorHeight, width: menuItemWidth, height: selectionIndicatorHeight)
            } else {
                selectionIndicatorFrame = CGRect(x: menuMargin, y: menuHeight - selectionIndicatorHeight, width: menuItemWidth, height: selectionIndicatorHeight)
            }
        }
        
        selectionIndicatorView = UIView(frame: selectionIndicatorFrame)
        selectionIndicatorView.backgroundColor = selectionIndicatorColor
        menuScrollView.addSubview(selectionIndicatorView)
        
        if menuItemWidthBasedOnTitleTextWidth && centerMenuItems {
            self.configureMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            let leadingAndTrailingMargin = self.getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            selectionIndicatorView.frame = CGRect(x: leadingAndTrailingMargin, y: menuHeight - selectionIndicatorHeight, width: menuItemWidths[0], height: selectionIndicatorHeight)
        }
    }
    
    // Adjusts the menu item frames to size item width based on title text width and center all menu items in the center
    // if the menuItems all fit in the width of the view. Otherwise, it will adjust the frames so that the menu items
    // appear as if only menuItemWidthBasedOnTitleTextWidth is true.
    fileprivate func configureMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems() {
        // only center items if the combined width is less than the width of the entire view's bounds
        if menuScrollView.contentSize.width < self.bounds.width {
            // compute the margin required to center the menu items
            let leadingAndTrailingMargin = self.getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems()
            // adjust the margin of each menu item to make them centered
            for (index, menuItem) in menuItems.enumerated() {
                let menuTitle = menuTitles[index]
                let itemWidthRect = menuTitle.boundingRect(with: CGSize(width: 1000, height: 1000), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:menuItemFont], context: nil)
                menuItemWidth = itemWidthRect.width
                var margin: CGFloat
                if index == 0 {
                    // the first menu item should use the calculated margin
                    margin = leadingAndTrailingMargin
                } else {
                    // the other menu items should use the menuMargin
                    let previousMenuItem = menuItems[index-1]
                    let previousX = previousMenuItem.frame.maxX
                    margin = previousX + menuMargin
                }
                menuItem.frame = CGRect(x: margin, y: 0.0, width: menuItemWidth, height: menuHeight)
            }
        } else {
            // the menuScrollView.contentSize.width exceeds the view's width, so layout the menu items normally (menuItemWidthBasedOnTitleTextWidth)
            for (index, menuItem) in menuItems.enumerated() {
                var menuItemX: CGFloat
                if index == 0 {
                    menuItemX = menuMargin
                } else {
                    menuItemX = menuItems[index-1].frame.maxX + menuMargin
                }
                menuItem.frame = CGRect(x: menuItemX, y: 0.0, width: menuItem.bounds.width, height: menuItem.bounds.height)
            }
        }
    }
    
    // Returns the size of the left and right margins that are neccessary to layout the menuItems in the center.
    fileprivate func getMarginForMenuItemWidthBasedOnTitleTextWidthAndCenterMenuItems() -> CGFloat {
        let menuItemsTotalWidth = menuScrollView.contentSize.width - menuMargin * 2
        let leadingAndTrailingMargin = (self.bounds.width - menuItemsTotalWidth) / 2
        return leadingAndTrailingMargin
    }
    
    // MARK: - Handle Selection Indicator
    open func moveSelectionIndicator(_ pageIndex: Int) {
        if pageIndex >= 0 && pageIndex < menuItems.count {
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                var selectionIndicatorWidth : CGFloat = self.selectionIndicatorView.frame.width
                var selectionIndicatorX : CGFloat = 0.0
                if self.menuItemWidthBasedOnTitleTextWidth {
                    selectionIndicatorWidth = self.menuItemWidths[pageIndex]
                    selectionIndicatorX = self.menuItems[pageIndex].frame.minX
                } else {
                    if self.centerMenuItems && pageIndex == 0 {
                        selectionIndicatorX = self.startingMenuMargin + self.menuMargin
                    } else {
                        selectionIndicatorX = self.menuItemWidth * CGFloat(pageIndex) + self.menuMargin * CGFloat(pageIndex + 1) + self.startingMenuMargin
                    }
                }
                self.selectionIndicatorView.frame = CGRect(x: selectionIndicatorX, y: self.selectionIndicatorView.frame.origin.y, width: selectionIndicatorWidth, height: self.selectionIndicatorView.frame.height)
                // Switch newly selected menu item title label to selected color and old one to unselected color
                if self.menuItems.count > 0 {
                    if self.menuItems[self.lastPageIndex].titleLabel != nil && self.menuItems[self.currentMenuIndex].titleLabel != nil {
                        self.menuItems[self.lastPageIndex].titleLabel!.textColor = self.unselectedMenuItemLabelColor
                        self.menuItems[self.currentMenuIndex].titleLabel!.textColor = self.selectedMenuItemLabelColor
                    }
                }
            })
            if tapTimer != nil {
                tapTimer!.invalidate()
            }
            tapTimer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(scrollViewDidEndTapScrollingAnimation), userInfo: nil, repeats: false)
            if didTapMenuItemToScroll {
                delegate?.didMoveToMenu?(self, index: pageIndex)
            }
        }
    }
    
    @objc
    func scrollViewDidEndTapScrollingAnimation() {
        if menuScrollView.contentSize.width <= frame.width{
            return
        }
        let cx = selectionIndicatorView.frame.minX + selectionIndicatorView.frame.width/2
        let cxc = frame.minX + frame.width/2
        var xOffset:CGFloat =  cx - cxc
        if xOffset < 0{
            xOffset = 0
        }else if xOffset > menuScrollView.contentSize.width - frame.width{
            xOffset = menuScrollView.contentSize.width - frame.width
        }
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.menuScrollView.setContentOffset(CGPoint(x: xOffset, y: self.menuScrollView.contentOffset.y), animated: true)
        })
    }
    
    // MARK: - Tap gesture recognizer selector
    @objc
    func handleMenuItemTap(_ gestureRecognizer : UITapGestureRecognizer) {
        let tappedPoint : CGPoint = gestureRecognizer.location(in: menuScrollView)
        if tappedPoint.y < menuScrollView.frame.height {
            var itemIndex : Int = 0
            
            if menuItemWidthBasedOnTitleTextWidth {
                var menuItemLeftBound: CGFloat
                var menuItemRightBound: CGFloat
                // Base case being first item
                
                menuItemLeftBound = 0.0
                menuItemRightBound = menuItemWidths[0] + menuMargin + (menuMargin / 2)
                if !(tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound) {
                    for i in 1...menuItems.count - 1 {
                        menuItemLeftBound = menuItemRightBound + 1.0
                        menuItemRightBound = menuItemLeftBound + menuItemWidths[i] + menuMargin
                        
                        if tappedPoint.x >= menuItemLeftBound && tappedPoint.x <= menuItemRightBound {
                            itemIndex = i
                            break
                        }
                    }
                }
            } else {
                let rawItemIndex : CGFloat = ((tappedPoint.x - startingMenuMargin) - menuMargin / 2) / (menuMargin + menuItemWidth)
                // Prevent moving to first item when tapping left to first item
                if rawItemIndex < 0 {
                    itemIndex = -1
                } else {
                    itemIndex = Int(rawItemIndex)
                }
            }
            
            if itemIndex >= 0 && itemIndex < menuItems.count {
                // Update menu if changed
                if itemIndex != currentMenuIndex {
                    startingPageForScroll = itemIndex
                    lastPageIndex = currentMenuIndex
                    currentMenuIndex = itemIndex
                    didTapMenuItemToScroll = true
                    moveSelectionIndicator(itemIndex)
                }
            }
        }
    }
    /// 设置当前选中菜单项
    open func setCurrentMenu(_ itemIndex:Int){
        if itemIndex >= 0 && itemIndex < menuItems.count {
            if itemIndex != currentMenuIndex {
                startingPageForScroll = itemIndex
                lastPageIndex = currentMenuIndex
                currentMenuIndex = itemIndex
                didTapMenuItemToScroll = false
                moveSelectionIndicator(itemIndex)
            }
        }
    }
}


