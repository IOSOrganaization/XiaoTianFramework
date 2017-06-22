//
//  UtilUIView.swift
//  DriftBook
//  UIView 常用工具类
//  Created by XiaoTian on 16/7/10.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

@objc(UtilUIViewXT)
open class UtilUIView: NSObject {
    static var KEY_CONSTRAINT_HEIGHT: UnsafePointer<CGFloat>? = nil
    static var KEY_CONSTRAINT_WIDTH: UnsafePointer<CGFloat>? = nil
    
    /// 根据Restoration Identity Id 获取UIView
    public func findViewWidthRestorationId(_ stubView:UIView?,_ restorationId:String?) -> UIView?{
        if stubView == nil || restorationId == nil {
            return nil
        }
        let subviews = stubView?.subviews
        if subviews?.count < 1{
            return nil
        }
        for view in subviews!{
            let id = view.restorationIdentifier
            if id == nil {
                let finded = findViewWidthRestorationId(view, restorationId)
                if finded != nil{
                    return finded
                }
            } else if restorationId?.compare(id!) == .orderedSame{
                return view
            } else {
                let finded = findViewWidthRestorationId(view, restorationId)
                if finded != nil{
                    return finded
                }
            }
        }
        return nil
    }
    /// 设置UIView背景圆角
    public func setCornerRadius(_ view:UIView?,_ radius:CGFloat){
        view?.layer.masksToBounds = true // 边距遮住[用透明遮住其他圆角部分]
        view?.layer.cornerRadius = radius
    }
    /// 在 UIView 中获取指定类型的 Response
    public func findResponderClass<T>(_ view: UIView?,_ clazz: T.Type) -> T?{
        var responder = view!.next
        while responder != nil {
            if (responder?.isKind(of: T.self as! AnyClass))!{
                return responder as? T
            }
            responder = responder?.next
        }
        return nil
    }
    /// 隐藏 View 视图[找到 View 中的 Constraint 名为 Height,Width 的约束,设置为0,hidden = true]
    public func hiddenAndCleanHeightConstraint(_ uiview: UIView?){
        if uiview == nil {
            return
        }
        if uiview!.isHidden{
            return
        }
        // 获取当前 View 的所有约束[不包含子 View 约束]
        if let constraints = uiview?.constraints{
            for constraint in constraints{
                if constraint.identifier == "Height"{
                    if objc_getAssociatedObject(uiview, &UtilUIView.KEY_CONSTRAINT_HEIGHT) == nil{
                        // 保存约束的值到 UIView 中
                        objc_setAssociatedObject(uiview, &UtilUIView.KEY_CONSTRAINT_HEIGHT, constraint.constant, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);
                    }
                    constraint.constant = 0
                    uiview?.isHidden = true
                } else if constraint.identifier == "Width"{
                    if objc_getAssociatedObject(uiview, &UtilUIView.KEY_CONSTRAINT_WIDTH) == nil{
                        // 保存约束的值到 UIView 中
                        objc_setAssociatedObject(uiview, &UtilUIView.KEY_CONSTRAINT_WIDTH, constraint.constant, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);
                    }
                    constraint.constant = 0
                    uiview?.isHidden = true
                }
            }
        }
    }
    /// 显示重置你 View 视图[找到 View 中的 Constraint 名为 Height,Width 的约束,重设值,hidden = false]
    public func showAndResetHeightConstraint(_ uiview: UIView?){
        if uiview == nil {
            return
        }
        if !uiview!.isHidden{
            return
        }
        if let constraints = uiview?.constraints{
            for constraint in constraints {
                // 在 UIView 中获取到约束的值,重置回约束
                if constraint.identifier == "Height"{
                    if let constant = objc_getAssociatedObject(uiview, &UtilUIView.KEY_CONSTRAINT_HEIGHT) as? CGFloat{
                        constraint.constant = constant
                        uiview?.isHidden = false
                    }
                } else if constraint.identifier == "Width"{
                    if let constant = objc_getAssociatedObject(uiview, &UtilUIView.KEY_CONSTRAINT_WIDTH) as? CGFloat{
                        constraint.constant = constant
                        uiview?.isHidden = false
                    }
                }
            }
        }
    }
    /**
     创建一个分割线UIView
     - Returns :分割线(UIView)
     */
    public func genDividerView() -> UIView{
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor(colorLiteralRed: 188/255.0, green: 186/255.0, blue: 193/255.0, alpha: 1)
        return view
    }
    /// 设置 UIView 的背景为指定图片[默认等比拉伸(Icon 配置 Slicing 拉伸属性除外)]
    public func setUIViewBackgroundStretch(_ uiview:UIView?,_ image: UIImage?){
        if uiview == nil || image == nil{
            return
        }
        UIGraphicsBeginImageContext(uiview!.frame.size)
        image!.draw(in: uiview!.bounds)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        uiview!.backgroundColor = UIColor(patternImage: resultImage!)
    }
    /// 设置 UIView 的背景为居中图片(Icon 配置 Slicing 拉伸属性除外)
    public func setUIViewBackgroundCenter(_ uiview:UIView?,_ image: UIImage?,_ xOffset: CGFloat = 0,_ yOffset:CGFloat = 0){
        if uiview == nil || image == nil{
            return
        }
        let imageOriginalSize = image!.size
        let inSize = uiview!.frame.size
        if imageOriginalSize.width <= inSize.width && imageOriginalSize.height <= inSize.height{
            UIGraphicsBeginImageContext(uiview!.frame.size)
            image?.draw(in: CGRect(x: (inSize.width - imageOriginalSize.width) / 2.0 + xOffset, y: (inSize.height - imageOriginalSize.height) / 2.0 + yOffset, width: imageOriginalSize.width, height: imageOriginalSize.height))
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            uiview!.backgroundColor = UIColor(patternImage: resultImage!)
        } else {
            setUIViewBackgroundStretch(uiview, image)
        }
    }
    /// 获取嵌套的指定上层类型的UIResponder[View获取所在的VC]
    public func finResponder<T : UIResponder>(_ sender: UIResponder?,_ clazz: T.Type) -> T?{
        // responder chain
        if var sender = sender{
            repeat{
                // see the next object up the responder chain
                guard let next = sender.next else{
                    return nil
                }
                sender = next
            } while !(sender is T)
        }
        return nil
    }
    /// 快速创建指定高度的Rect
    public func createHeightRect(_ sourceRect:CGRect,_ height:CGFloat) -> CGRect {
        //分割Rect (slice, remainder)=(距离值,相对位置)(切下的部分,剩余的部分)[在源Rect基础上创建指定高度Rect,其他值不变]
        return sourceRect.divided(atDistance: height, from: .minYEdge).slice
        //frame: 位置+大小[支持动态改变,动态转换后,最好用bound+center刷新位置]
        //bound: 大小[ 大小 + center 固定位置]
    }
    /// 快速创建指定宽度的Rect
    public func createWidthRect(_ sourceRect:CGRect,_ width:CGFloat) -> CGRect{
        return sourceRect.divided(atDistance: width, from: .minXEdge).slice
    }
}
