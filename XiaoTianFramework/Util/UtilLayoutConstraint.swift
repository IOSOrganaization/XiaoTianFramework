//
//  UtilLayoutConstraint.swift
//  DriftBook
//  约束方法,View的常用约束
//  Created by XiaoTian on 16/8/7.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilLayoutConstraintXT)
public class UtilLayoutConstraint: NSObject{
    /// Parent UIView context.
    internal weak var parent: UIView?

    /// Child UIView context.
    internal weak var child: UIView?
    
    /**
     An initializer that takes in a parent context.
     - Parameter parent: An optional parent UIView.
     */
    public init(parent: UIView?) {
        self.parent = parent
    }
    
    /**
     An initializer that takes in a parent context and child context.
     - Parameter parent: An optional parent UIView.
     - Parameter child: An optional child UIView.
     */
    public init(parent: UIView?, child: UIView?) {
        self.parent = parent
        self.child = child
    }
    
    /**
     Prints a debug message when the parent context is not available.
     - Parameter function: A String representation of the function that caused the issue.
     - Returns: The current Layout instance.
     */
    internal func debugParentNotAvailableMessage(function: String = #function) -> UtilLayoutConstraint {
        debugPrint("[UtilLayoutConstraint Layout Error: Parent view context is not available for \(function).")
        return self
    }
    
    /**
     Prints a debug message when the child context is not available.
     - Parameter function: A String representation of the function that caused the issue.
     - Returns: The current Layout instance.
     */
    internal func debugChildNotAvailableMessage(function: String = #function) -> UtilLayoutConstraint {
        debugPrint("[UtilLayoutConstraint Layout Error: Chld view context is not available for \(function).")
        return self
    }
    /// String Constraint Fromat [Visual Format Language(布局格式化语言) : VFL]
    /*
     //
     Here’s a step-by-step explanation of the VFL format string:
     Direction of your constraints, not required. Can have the following values:
     
     H: indicates horizontal orientation.
     
     V: indicates vertical orientation.
     
     Not specified: Auto Layout defaults to horizontal orientation.
     Leading connection to the superview, not required.
     Spacing between the top edge of your view and its superview’s top edge (vertical)
     Spacing between the leading edge of your view and its superview’s leading edge (horizontal)
     View you’re laying out, is required.
     Connection to another view, not required.
     Trailing connection to the superview, not required.
     Spacing between the bottom edge of your view and its superview’s bottom edge (vertical)
     Spacing between the trailing edge of your view and its superview’s trailing edge (horizontal)
     
     There are two special (orange) characters in the image and their definition is below:
     ? component is not required inside the layout string.
     * component may appear 0 or more times inside the layout string.
     //
     Available Symbols
     VFL uses a number of symbols to describe your layout:
     
     | superview
     - standard spacing (usually 8 points; value can be changed if it is the spacing to the edge of a superview)
     == equal widths (can be omitted)
     -20- non standard spacing (20 points)
     <= less than or equal to
     >= greater than or equal to
     @250 priority of the constraint; can have any value between 0 and 1000
     250 - low priority
     750 - high priority
     1000 - required priority
     //
     NSLayoutFormatOptions
     NSLayoutFormat Options Quick Reference
     Here are the options you've used in Grapevine:
     .AlignAllCenterX -- align interface elements using NSLayoutAttributeCenterX.
     .AlignAllCenterY -- align interface elements using NSLayoutAttributeCenterY.
     .AlignAllLeading -- align interface elements using NSLayoutAttributeLeading.
     .AlignAllTrailing -- align interface elements using NSLayoutAttributeTrailing.
     Below are some more of these options:
     .AlignAllLeft -- align interface elements using NSLayoutAttributeLeft.
     .AlignAllRight -- align interface elements using NSLayoutAttributeRight.
     .AlignAllTop -- align interface elements using NSLayoutAttributeTop.
     .AlignAllBottom -- align interface elements using NSLayoutAttributeBottom.
     .AlignAllBaseline -- align interface elements using NSLayoutAttributeBaseline.
     
     Example Format String
     H:|-[icon(==iconDate)]-20-[iconLabel(120@250)]-20@750-[iconDate(>=50)]-|
     
     Here's a step-by-step explanation of this string:
     H: horizontal direction.
     |-[icon icon's leading edge should have standard distance from its superview's leading edge.
     ==iconDate icon's width should be equal to iconDate's width.
     ]-20-[iconLabel icon's trailing edge should be 20 points from iconLabel's leading edge.
     [iconLabel(120@250)] iconLabel should have a width of 120 points. The priority is set to low, and Auto Layout can break this constraint if a conflict arises.
     -20@750- iconLabel's trailing edge should be 20 points from iconDate's leading edge. The priority is set to high, so Auto Layout shouldn't break this constraint if there's a conflict.
     [iconDate(>=50)] iconDate's width should be greater than or equal to 50 points.
     -| iconDate's trailing edge should have standard distance from its superview's trailing edge.
     
     Layout.constraint(format, options: [], metrics: metrics, views: views)
     format: 布局(H,V横竖向 [xxx] 视图变量key (xxx)值变量key - 连接器(空白10 Point) : 开始符 @权限符 ==赋值符 >= 大于等于 | 连接根View)
     options: 可选项
     metrics: 变量参数<String, Value>
     views: 视图变量参数<String, Value>
     Layout.constraint("H:|-(marginLeft)-[icon]-(marginRight)-|", options: [], metrics: ["marginLeft":10,"marginRight":10], views: ["icon",uiImageViewIcon])
     */
}

/// 扩展公共方法
public extension UtilLayoutConstraint{
    /**
     Sets the width of a view.
     - Parameter child: A child UIView to layout.
     - Parameter width: A CGFloat value.
     - Returns: The current Layout instance.
     */
    public func width(child: UIView, width: CGFloat) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.width(v, child: child, width: width)
        return self
    }
    
    /**
     Sets the width of a view assuming a child context view.
     - Parameter width: A CGFloat value.
     - Returns: The current Layout instance.
     */
    public func width(width: CGFloat) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return self.width(v, width: width)
    }
    
    /**
     Sets the height of a view.
     - Parameter child: A child UIView to layout.
     - Parameter height: A CGFloat value.
     - Returns: The current Layout instance.
     */
    public func height(child: UIView, height: CGFloat) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.height(v, child: child, height: height)
        return self
    }
    
    /**
     Sets the height of a view assuming a child context view.
     - Parameter height: A CGFloat value.
     - Returns: The current Layout instance.
     */
    public func height(height: CGFloat) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return self.height(v, height: height)
    }
    /**
     设置子View宽相对于父View宽的比例约束.
     - Parameter child: 子View
     - Parameter multiplier: 比例(CGFloat).
     - Returns: 布局约束工具实例(UtilLayoutConstraint).
     */
    public func widthMultiplier(child: UIView, multiplier: CGFloat) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.width(v, child: child, multiplier: multiplier)
        return self
    }
    /**
     设置当前上下文子View宽相对于父View宽的比例约束.
     - Parameter multiplier: 比例(CGFloat).
     - Returns: 布局约束工具实例(UtilLayoutConstraint).
    */
    public func widthMultiplier(multiplier: CGFloat) -> UtilLayoutConstraint {
        guard let v: UIView = child else { // if let v and v != nil else { exit scope func }
             return debugChildNotAvailableMessage()
        }
        return self.widthMultiplier(v, multiplier: multiplier)
    }
    /**
     设置子View高相对于父View高的比例约束.
     - Parameter child: 子View
     - Parameter multiplier: 比例(CGFloat).
     - Returns: 布局约束工具实例(UtilLayoutConstraint).
     */
    public func heightMultiplier(child: UIView, multiplier: CGFloat) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.height(v, child: child, multiplier: multiplier)
        return self
    }
    /**
     设置当前上下文子View高相对于父View高的比例约束.
     - Parameter multiplier: 比例(CGFloat).
     - Returns: 布局约束工具实例(UtilLayoutConstraint).
     */
    public func heightMultiplier(multiplier: CGFloat) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return self.heightMultiplier(v, multiplier: multiplier)
    }
    /**
     Sets the width and height of a view.
     - Parameter child: A child UIView to layout.
     - Parameter width: A CGFloat value.
     - Parameter height: A CGFloat value.
     - Returns: The current Layout instance.
     */
    public func size(child: UIView, width: CGFloat, height: CGFloat) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.size(v, child: child, width: width, height: height)
        return self
    }
    
    /**
     Sets the width and height of a view assuming a child context view.
     - Parameter width: A CGFloat value.
     - Parameter height: A CGFloat value.
     - Returns: The current Layout instance.
     */
    public func size(width width: CGFloat, height: CGFloat) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return size(v, width: width, height: height)
    }
    
    /**
     A collection of children views are horizontally stretched with optional left,
     right padding and interim spacing.
     - Parameter children: An Array UIView to layout.
     - Parameter left: A CGFloat value for padding the left side.
     - Parameter right: A CGFloat value for padding the right side.
     - Parameter spacing: A CGFloat value for interim spacing.
     - Returns: The current Layout instance.
     */
    public func horizontally(children: Array<UIView>, left: CGFloat = 0, right: CGFloat = 0, spacing: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        UtilLayoutConstraint.horizontally(v, children: children, left: left, right: right, spacing: spacing)
        return self
    }
    
    /**
     A collection of children views are vertically stretched with optional top,
     bottom padding and interim spacing.
     - Parameter children: An Array UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Parameter spacing: A CGFloat value for interim spacing.
     - Returns: The current Layout instance.
     */
    public func vertically(children: Array<UIView>, top: CGFloat = 0, bottom: CGFloat = 0, spacing: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        UtilLayoutConstraint.vertically(v, children: children, top: top, bottom: bottom, spacing: spacing)
        return self
    }
    
    /**
     A child view is horizontally stretched with optional left and right padding.
     - Parameter child: A child UIView to layout.
     - Parameter left: A CGFloat value for padding the left side.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public func horizontally(child: UIView, left: CGFloat = 0, right: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.horizontally(v, child: child, left: left, right: right)
        return self
    }
    
    /**
     A child view is horizontally stretched with optional left and right padding.
     - Parameter left: A CGFloat value for padding the left side.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public func horizontally(left left: CGFloat = 0, right: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return horizontally(v, left: left, right: right)
    }
    
    /**
     A child view is vertically stretched with optional left and right padding.
     - Parameter child: A child UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Returns: The current Layout instance.
     */
    public func vertically(child: UIView, top: CGFloat = 0, bottom: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.vertically(v, child: child, top: top, bottom: bottom)
        return self
    }
    
    /**
     A child view is vertically stretched with optional left and right padding.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Returns: The current Layout instance.
     */
    public func vertically(top top: CGFloat = 0, bottom: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return vertically(v, top: top, bottom: bottom)
    }
    
    /**
     A child view is vertically and horizontally stretched with optional top, left, bottom and right padding.
     - Parameter child: A child UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter left: A CGFloat value for padding the left side.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public func edges(child: UIView, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.edges(v, child: child, top: top, left: left, bottom: bottom, right: right)
        return self
    }
    
    /**
     A child view is vertically and horizontally stretched with optional top, left, bottom and right padding.
     - Parameter child: A child UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter left: A CGFloat value for padding the left side.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public func edges(top top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return edges(v, top: top, left: left, bottom: bottom, right: right)
    }
    
    /**
     A child view is aligned from the top with optional top padding.
     - Parameter child: A child UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Returns: The current Layout instance.
     */
    public func top(child: UIView, top: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.top(v, child: child, top: top)
        return self
    }
    
    /**
     A child view is aligned from the top with optional top padding.
     - Parameter top: A CGFloat value for padding the top side.
     - Returns: The current Layout instance.
     */
    public func top(top: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return self.top(v, top: top)
    }
    
    /**
     A child view is aligned from the left with optional left padding.
     - Parameter child: A child UIView to layout.
     - Parameter left: A CGFloat value for padding the left side.
     - Returns: The current Layout instance.
     */
    public func left(child: UIView, left: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.left(v, child: child, left: left)
        return self
    }
    
    /**
     A child view is aligned from the left with optional left padding.
     - Parameter left: A CGFloat value for padding the left side.
     - Returns: The current Layout instance.
     */
    public func left(left: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return self.left(v, left: left)
    }
    
    /**
     A child view is aligned from the bottom with optional bottom padding.
     - Parameter child: A child UIView to layout.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Returns: The current Layout instance.
     */
    public func bottom(child: UIView, bottom: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.bottom(v, child: child, bottom: bottom)
        return self
    }
    
    /**
     A child view is aligned from the bottom with optional bottom padding.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Returns: The current Layout instance.
     */
    public func bottom(bottom: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return self.bottom(v, bottom: bottom)
    }
    
    
    /**
     A child view is aligned from the right with optional right padding.
     - Parameter child: A child UIView to layout.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public func right(child: UIView, right: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.right(v, child: child, right: right)
        return self
    }
    
    /**
     A child view is aligned from the right with optional right padding.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public func right(right: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return self.right(v, right: right)
    }
    
    /**
     A child view is aligned from the top left with optional top and left padding.
     - Parameter child: A child UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter left: A CGFloat value for padding the left side.
     - Returns: The current Layout instance.
     */
    public func topLeft(child: UIView, top: CGFloat = 0, left: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.topLeft(v, child: child, top: top, left: left)
        return self
    }
    
    /**
     A child view is aligned from the top left with optional top and left padding.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter left: A CGFloat value for padding the left side.
     - Returns: The current Layout instance.
     */
    public func topLeft(top top: CGFloat = 0, left: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return topLeft(v, top: top, left: left)
    }
    
    /**
     A child view is aligned from the top right with optional top and right padding.
     - Parameter child: A child UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public func topRight(child: UIView, top: CGFloat = 0, right: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.topRight(v, child: child, top: top, right: right)
        return self
    }
    
    /**
     A child view is aligned from the top right with optional top and right padding.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public func topRight(top top: CGFloat = 0, right: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return topRight(v, top: top, right: right)
    }
    
    /**
     A child view is aligned from the bottom left with optional bottom and left padding.
     - Parameter child: A child UIView to layout.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Parameter left: A CGFloat value for padding the left side.
     - Returns: The current Layout instance.
     */
    public func bottomLeft(child: UIView, bottom: CGFloat = 0, left: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.bottomLeft(v, child: child, bottom: bottom, left: left)
        return self
    }
    
    /**
     A child view is aligned from the bottom left with optional bottom and left padding.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Parameter left: A CGFloat value for padding the left side.
     - Returns: The current Layout instance.
     */
    public func bottomLeft(bottom bottom: CGFloat = 0, left: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return bottomLeft(v, bottom: bottom, left: left)
    }
    
    /**
     A child view is aligned from the bottom right with optional bottom and right padding.
     - Parameter child: A child UIView to layout.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public func bottomRight(child: UIView, bottom: CGFloat = 0, right: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.bottomRight(v, child: child, bottom: bottom, right: right)
        return self
    }
    
    /**
     A child view is aligned from the bottom right with optional bottom and right padding.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public func bottomRight(bottom bottom: CGFloat = 0, right: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return bottomRight(v, bottom: bottom, right: right)
    }
    
    /**
     A child view is aligned at the center with an optional offsetX and offsetY value.
     - Parameter child: A child UIView to layout.
     - Parameter offsetX: A CGFloat value for the offset along the x axis.
     - Parameter offsetX: A CGFloat value for the offset along the y axis.
     - Returns: The current Layout instance.
     */
    public func center(child: UIView, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.center(v, child: child, offsetX: offsetX, offsetY: offsetY)
        return self
    }
    
    /**
     A child view is aligned at the center with an optional offsetX and offsetY value.
     - Parameter offsetX: A CGFloat value for the offset along the x axis.
     - Parameter offsetX: A CGFloat value for the offset along the y axis.
     - Returns: The current Layout instance.
     */
    public func center(offsetX offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return center(v, offsetX: offsetX, offsetY: offsetY)
    }
    
    /**
     A child view is aligned at the center horizontally with an optional offset value.
     - Parameter child: A child UIView to layout.
     - Parameter offset: A CGFloat value for the offset along the x axis.
     - Returns: The current Layout instance.
     */
    public func centerHorizontally(child: UIView, offset: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.centerHorizontally(v, child: child, offset: offset)
        return self
    }
    
    /**
     A child view is aligned at the center horizontally with an optional offset value.
     - Parameter offset: A CGFloat value for the offset along the x axis.
     - Returns: The current Layout instance.
     */
    public func centerHorizontally(offset: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return centerHorizontally(v, offset: offset)
    }
    
    /**
     A child view is aligned at the center vertically with an optional offset value.
     - Parameter child: A child UIView to layout.
     - Parameter offset: A CGFloat value for the offset along the y axis.
     - Returns: The current Layout instance.
     */
    public func centerVertically(child: UIView, offset: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = parent else {
            return debugParentNotAvailableMessage()
        }
        self.child = child
        UtilLayoutConstraint.centerVertically(v, child: child, offset: offset)
        return self
    }
    
    /**
     A child view is aligned at the center vertically with an optional offset value.
     - Parameter offset: A CGFloat value for the offset along the y axis.
     - Returns: The current Layout instance.
     */
    public func centerVertically(offset: CGFloat = 0) -> UtilLayoutConstraint {
        guard let v: UIView = child else {
            return debugChildNotAvailableMessage()
        }
        return centerVertically(v, offset: offset)
    }
    
    /////////// 静态扩展方法构造器 view1.attr1 = view2.attr2 * multiplier + constant ///////////
    /**
     Sets the width of a view.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter width: A CGFloat value.
     */
    public class func width(parent: UIView, child: UIView, width: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1, constant: width))
    }
    
    public class func width(parent: UIView, child: UIView, multiplier: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Width, relatedBy: .Equal, toItem: parent, attribute: .Width, multiplier: multiplier, constant: 0))
    }
    /**
     Sets the height of a view.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter height: A CGFloat value.
     */
    public class func height(parent: UIView, child: UIView, height: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: height))
    }
    /**
     设置Child的宽度为指定Parent宽度的比例
     - Parameter parent: 上下文的父View.
     - Parameter child: 要约束的布局的子View.
     - Parameter multiplier: 子View占父View的比例值.
     */
    public class func height(parent: UIView, child: UIView, multiplier: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Height, relatedBy: .Equal, toItem: parent, attribute: .Height, multiplier: multiplier, constant: 0))
    }
    /**
     Sets the width and height of a view.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter width: A CGFloat value.
     - Parameter height: A CGFloat value.
     */
    public class func size(parent: UIView, child: UIView, width: CGFloat = 0, height: CGFloat = 0) {
        UtilLayoutConstraint.width(parent, child: child, width: width)
        UtilLayoutConstraint.height(parent, child: child, height: height)
    }
    
    /**
     A collection of children views are horizontally stretched with optional left,
     right padding and interim spacing.
     - Parameter parent: A parent UIView context.
     - Parameter children: An Array UIView to layout.
     - Parameter left: A CGFloat value for padding the left side.
     - Parameter right: A CGFloat value for padding the right side.
     - Parameter spacing: A CGFloat value for interim spacing.
     */
    public class func horizontally(parent: UIView, children: Array<UIView>, left: CGFloat = 0, right: CGFloat = 0, spacing: CGFloat = 0) {
        prepareForConstraint(parent, children: children)
        if 0 < children.count {
            parent.addConstraint(NSLayoutConstraint(item: children[0], attribute: .Left, relatedBy: .Equal, toItem: parent, attribute: .Left, multiplier: 1, constant: left))
            for i in 1..<children.count {
                parent.addConstraint(NSLayoutConstraint(item: children[i], attribute: .Left, relatedBy: .Equal, toItem: children[i - 1], attribute: .Right, multiplier: 1, constant: spacing))
                parent.addConstraint(NSLayoutConstraint(item: children[i], attribute: .Width, relatedBy: .Equal, toItem: children[0], attribute: .Width, multiplier: 1, constant: 0))
            }
            parent.addConstraint(NSLayoutConstraint(item: children[children.count - 1], attribute: .Right, relatedBy: .Equal, toItem: parent, attribute: .Right, multiplier: 1, constant: -right))
        }
    }
    
    /**
     A collection of children views are vertically stretched with optional top,
     bottom padding and interim spacing.
     - Parameter parent: A parent UIView context.
     - Parameter children: An Array UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Parameter spacing: A CGFloat value for interim spacing.
     */
    public class func vertically(parent: UIView, children: Array<UIView>, top: CGFloat = 0, bottom: CGFloat = 0, spacing: CGFloat = 0) {
        prepareForConstraint(parent, children: children)
        if 0 < children.count {
            parent.addConstraint(NSLayoutConstraint(item: children[0], attribute: .Top, relatedBy: .Equal, toItem: parent, attribute: .Top, multiplier: 1, constant: top))
            for i in 1..<children.count {
                parent.addConstraint(NSLayoutConstraint(item: children[i], attribute: .Top, relatedBy: .Equal, toItem: children[i - 1], attribute: .Bottom, multiplier: 1, constant: spacing))
                parent.addConstraint(NSLayoutConstraint(item: children[i], attribute: .Height, relatedBy: .Equal, toItem: children[0], attribute: .Height, multiplier: 1, constant: 0))
            }
            parent.addConstraint(NSLayoutConstraint(item: children[children.count - 1], attribute: .Bottom, relatedBy: .Equal, toItem: parent, attribute: .Bottom, multiplier: 1, constant: -bottom))
        }
    }
    
    /**
     A child view is horizontally stretched with optional left and right padding.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter left: A CGFloat value for padding the left side.
     - Parameter right: A CGFloat value for padding the right side.
     */
    public class func horizontally(parent: UIView, child: UIView, left: CGFloat = 0, right: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Left, relatedBy: .Equal, toItem: parent, attribute: .Left, multiplier: 1, constant: left))
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Right, relatedBy: .Equal, toItem: parent, attribute: .Right, multiplier: 1, constant: -right))
    }
    
    /**
     A child view is vertically stretched with optional left and right padding.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     */
    public class func vertically(parent: UIView, child: UIView, top: CGFloat = 0, bottom: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Top, relatedBy: .Equal, toItem: parent, attribute: .Top, multiplier: 1, constant: top))
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Bottom, relatedBy: .Equal, toItem: parent, attribute: .Bottom, multiplier: 1, constant: -bottom))
    }
    
    /**
     A child view is vertically and horizontally stretched with optional top, left, bottom and right padding.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter left: A CGFloat value for padding the left side.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Parameter right: A CGFloat value for padding the right side.
     */
    public class func edges(parent: UIView, child: UIView, top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        horizontally(parent, child: child, left: left, right: right)
        vertically(parent, child: child, top: top, bottom: bottom)
    }
    
    /**
     A child view is aligned from the top with optional top padding.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Returns: The current Layout instance.
     */
    public class func top(parent: UIView, child: UIView, top: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Top, relatedBy: .Equal, toItem: parent, attribute: .Top, multiplier: 1, constant: top))
    }
    
    /**
     A child view is aligned from the left with optional left padding.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter left: A CGFloat value for padding the left side.
     - Returns: The current Layout instance.
     */
    public class func left(parent: UIView, child: UIView, left: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Left, relatedBy: .Equal, toItem: parent, attribute: .Left, multiplier: 1, constant: left))
    }
    
    /**
     A child view is aligned from the bottom with optional bottom padding.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Returns: The current Layout instance.
     */
    public class func bottom(parent: UIView, child: UIView, bottom: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Bottom, relatedBy: .Equal, toItem: parent, attribute: .Bottom, multiplier: 1, constant: -bottom))
    }
    
    /**
     A child view is aligned from the right with optional right padding.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public class func right(parent: UIView, child: UIView, right: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .Right, relatedBy: .Equal, toItem: parent, attribute: .Right, multiplier: 1, constant: -right))
    }
    
    /**
     A child view is aligned from the top left with optional top and left padding.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter left: A CGFloat value for padding the left side.
     - Returns: The current Layout instance.
     */
    public class func topLeft(parent: UIView, child: UIView, top t: CGFloat = 0, left l: CGFloat = 0) {
        top(parent, child: child, top: t)
        left(parent, child: child, left: l)
    }
    
    /**
     A child view is aligned from the top right with optional top and right padding.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter top: A CGFloat value for padding the top side.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public class func topRight(parent: UIView, child: UIView, top t: CGFloat = 0, right r: CGFloat = 0) {
        top(parent, child: child, top: t)
        right(parent, child: child, right: r)
    }
    
    /**
     A child view is aligned from the bottom left with optional bottom and left padding.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Parameter left: A CGFloat value for padding the left side.
     - Returns: The current Layout instance.
     */
    public class func bottomLeft(parent: UIView, child: UIView, bottom b: CGFloat = 0, left l: CGFloat = 0) {
        bottom(parent, child: child, bottom: b)
        left(parent, child: child, left: l)
    }
    
    /**
     A child view is aligned from the bottom right with optional bottom and right padding.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter bottom: A CGFloat value for padding the bottom side.
     - Parameter right: A CGFloat value for padding the right side.
     - Returns: The current Layout instance.
     */
    public class func bottomRight(parent: UIView, child: UIView, bottom b: CGFloat = 0, right r: CGFloat = 0) {
        bottom(parent, child: child, bottom: b)
        right(parent, child: child, right: r)
    }
    
    /**
     A child view is aligned at the center with an optional offsetX and offsetY value.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter offsetX: A CGFloat value for the offset along the x axis.
     - Parameter offsetX: A CGFloat value for the offset along the y axis.
     - Returns: The current Layout instance.
     */
    public class func center(parent: UIView, child: UIView, offsetX: CGFloat = 0, offsetY: CGFloat = 0) {
        centerHorizontally(parent, child: child, offset: offsetX)
        centerVertically(parent, child: child, offset: offsetY)
    }
    
    /**
     A child view is aligned at the center horizontally with an optional offset value.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter offset: A CGFloat value for the offset along the y axis.
     - Returns: The current Layout instance.
     */
    public class func centerHorizontally(parent: UIView, child: UIView, offset: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .CenterX, relatedBy: .Equal, toItem: parent, attribute: .CenterX, multiplier: 1, constant: offset))
    }
    
    /**
     A child view is aligned at the center vertically with an optional offset value.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     - Parameter offset: A CGFloat value for the offset along the y axis.
     - Returns: The current Layout instance.
     */
    public class func centerVertically(parent: UIView, child: UIView, offset: CGFloat = 0) {
        prepareForConstraint(parent, child: child)
        parent.addConstraint(NSLayoutConstraint(item: child, attribute: .CenterY, relatedBy: .Equal, toItem: parent, attribute: .CenterY, multiplier: 1, constant: offset))
    }
    
    /**
     Creats an Array with a NSLayoutConstraint value.
     - Parameter format: The VFL format string.
     - Parameter options: Additional NSLayoutFormatOptions.
     - Parameter metrics: An optional Dictionary<String, AnyObject> of metric key / value pairs.
     - Parameter views: A Dictionary<String, AnyObject> of view key / value pairs.
     - Returns: The Array<NSLayoutConstraint> instance.
     */
    public class func constraint(format: String, options: NSLayoutFormatOptions, metrics: Dictionary<String, AnyObject>?, views: Dictionary<String, AnyObject>) -> Array<NSLayoutConstraint> {
        for (_, a) in views {
            if let v: UIView = a as? UIView {
                v.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        return NSLayoutConstraint.constraintsWithVisualFormat(
            format,
            options: options,
            metrics: metrics,
            views: views
        )
    }
    
    /**
     Prepares the relationship between the parent view context and child view
     to layout. If the child is not already added to the view hierarchy as the
     parent's child, then it is added.
     - Parameter parent: A parent UIView context.
     - Parameter child: A child UIView to layout.
     */
    private class func prepareForConstraint(parent: UIView, child: UIView) {
        if parent != child.superview {
            child.removeFromSuperview()
            parent.addSubview(child)
        }
        child.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /**
     Prepares the relationship between the parent view context and an Array of
     child UIViews.
     - Parameter parent: A parent UIView context.
     - Parameter children: An Array of UIViews.
     */
    private class func prepareForConstraint(parent: UIView, children: [UIView]) {
        for v in children {
            prepareForConstraint(parent, child: v)
        }
    }
}

/// A memory reference to the UtilLayoutConstraintKey instance for UIView extensions.
private var UtilLayoutConstraintKey: UInt8 = 0

/// UtilLayoutConstraint extension for UIView.
public extension UIView {
    /// UtilLayoutConstraint reference.
    public private(set) var utilLayoutConstant: UtilLayoutConstraint {
        get {
            return UtilAnyObject.associated(self, key: &UtilLayoutConstraintKey) {
                return UtilLayoutConstraint(parent: self)
            }
        }
        set(value) {
            UtilAnyObject.associate(self, key: &UtilLayoutConstraintKey, value: value)
        }
    }
    
    /**
     Used to chain UtilLayoutConstraint constraints on a child context.
     - Parameter child: A child UIView to layout.
     - Returns: The current UtilLayoutConstraint instance.
     */
    public func utilLayoutConstant(child: UIView) -> UtilLayoutConstraint {
        return UtilLayoutConstraint(parent: self, child: child)
    }
    
    /// Constraint By Identity
    public func findConstraintByIdentity(identity:String) -> NSLayoutConstraint?{
        for constraint in constraints where (constraint.identifier == identity) {
            return constraint
        }
        return nil
    }
    // Descendant Constraint By Identity
    public func findDescendantConstraintByIdentity(view:UIView! = nil,_ identity:String) -> NSLayoutConstraint?{
        for subView in (view == nil ? subviews : view.subviews) {
            for constraint in subView.constraints where (constraint.identifier == identity) {
                return constraint
            }
            findDescendantConstraintByIdentity(subView, identity)
        }
        return nil
    }
}