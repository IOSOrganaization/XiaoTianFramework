//
//  UtilAnimation.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/6/28.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

open class UtilAnimation: NSObject{
    /// View旋转PI的弧度
    public static func rotationPi(_ view: UIView?){
        if let view = view{
            UIView.animate(withDuration: 0.5, animations: { 
                view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            })
        }
    }
    /// View旋转2PI的弧度
    public static func rotation2Pi(_ view: UIView?){
        if let view = view{
            UIView.animate(withDuration: 0.5, animations: {
                view.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
            })
        }
    }
    /// View x/y放大动画,结束后还原
    public static func scale(_ view: UIView?,_ x:CGFloat,_ y:CGFloat,durantion:TimeInterval = 0.3){
        if let view = view{
            UIView.animate(withDuration: durantion, delay:0.0, options:.beginFromCurrentState, animations: {
                view.transform = CGAffineTransform(scaleX: x, y: y)
            },completion: { _ in
                UIView.animate(withDuration: durantion) {
                    view.transform = CGAffineTransform.identity
                }
            })
        }
    }
}
