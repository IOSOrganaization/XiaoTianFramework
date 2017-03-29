//
//  UtilUIView.swift
//  DriftBook
//  UIView 常用工具类
//  Created by XiaoTian on 16/7/10.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilUIViewXT)
class UtilUIView: NSObject {
    static var KEY_CONSTRAINT_HEIGHT: UnsafePointer<CGFloat> = nil
    static var KEY_CONSTRAINT_WIDTH: UnsafePointer<CGFloat> = nil
    
    /// 根据Restoration Identity Id 获取UIView
    func findViewWidthRestorationId(stubView:UIView?,_ restorationId:String?) -> UIView?{
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
            } else if restorationId?.compare(id!) == .OrderedSame{
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
    func setCornerRadius(view:UIView?,_ radius:CGFloat){
        view?.layer.masksToBounds = true // 边距遮住[用透明遮住其他圆角部分]
        view?.layer.cornerRadius = radius
    }
    /// 在 UIView 中获取指定类型的 Response
    func findResponderClass<T>(view: UIView?,_ clazz: T.Type) -> T?{
        var responder = view!.nextResponder()
        while responder != nil {
            if (responder?.isKindOfClass(T.self as! AnyClass))!{
                return responder as? T
            }
            responder = responder?.nextResponder()
        }
        return nil
    }
    /// 隐藏 View 视图[找到 View 中的 Constraint 名为 Height,Width 的约束,设置为0,hidden = true]
    func hiddenAndCleanHeightConstraint(uiview: UIView?){
        if uiview == nil {
            return
        }
        if uiview!.hidden{
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
                    uiview?.hidden = true
                } else if constraint.identifier == "Width"{
                    if objc_getAssociatedObject(uiview, &UtilUIView.KEY_CONSTRAINT_WIDTH) == nil{
                        // 保存约束的值到 UIView 中
                        objc_setAssociatedObject(uiview, &UtilUIView.KEY_CONSTRAINT_WIDTH, constraint.constant, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY);
                    }
                    constraint.constant = 0
                    uiview?.hidden = true
                }
            }
        }
    }
    /// 显示重置你 View 视图[找到 View 中的 Constraint 名为 Height,Width 的约束,重设值,hidden = false]
    func showAndResetHeightConstraint(uiview: UIView?){
        if uiview == nil {
            return
        }
        if !uiview!.hidden{
            return
        }
        if let constraints = uiview?.constraints{
            for constraint in constraints {
                // 在 UIView 中获取到约束的值,重置回约束
                if constraint.identifier == "Height"{
                    if let constant = objc_getAssociatedObject(uiview, &UtilUIView.KEY_CONSTRAINT_HEIGHT) as? CGFloat{
                        constraint.constant = constant
                        uiview?.hidden = false
                    }
                } else if constraint.identifier == "Width"{
                    if let constant = objc_getAssociatedObject(uiview, &UtilUIView.KEY_CONSTRAINT_WIDTH) as? CGFloat{
                        constraint.constant = constant
                        uiview?.hidden = false
                    }
                }
            }
        }
    }
    /**
     创建一个分割线UIView
     - Returns :分割线(UIView)
     */
    func genDividerView() -> UIView{
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor(colorLiteralRed: 188/255.0, green: 186/255.0, blue: 193/255.0, alpha: 1)
        return view
    }
    /// 设置 UIView 的背景为指定图片[默认等比拉伸(Icon 配置 Slicing 拉伸属性除外)]
    func setUIViewBackgroundStretch(uiview:UIView?,_ image: UIImage?){
        if uiview == nil || image == nil{
            return
        }
        UIGraphicsBeginImageContext(uiview!.frame.size)
        image!.drawInRect(uiview!.bounds)
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        uiview!.backgroundColor = UIColor(patternImage: resultImage)
    }
    /// 设置 UIView 的背景为居中图片(Icon 配置 Slicing 拉伸属性除外)
    func setUIViewBackgroundCenter(uiview:UIView?,_ image: UIImage?,_ xOffset: CGFloat = 0,_ yOffset:CGFloat = 0){
        if uiview == nil || image == nil{
            return
        }
        let imageOriginalSize = image!.size
        let inSize = uiview!.frame.size
        if imageOriginalSize.width <= inSize.width && imageOriginalSize.height <= inSize.height{
            UIGraphicsBeginImageContext(uiview!.frame.size)
            image?.drawInRect(CGRectMake((inSize.width - imageOriginalSize.width) / 2.0 + xOffset, (inSize.height - imageOriginalSize.height) / 2.0 + yOffset, imageOriginalSize.width, imageOriginalSize.height))
            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            uiview!.backgroundColor = UIColor(patternImage: resultImage)
        } else {
            setUIViewBackgroundStretch(uiview, image)
        }
    }
}