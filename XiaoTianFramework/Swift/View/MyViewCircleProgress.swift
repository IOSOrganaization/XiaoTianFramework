//
//  MyViewCircleProgress.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/7/26.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
public class MyViewCircleProgress: UIView{
    // lazy: self:
    lazy var maskLayer: CAShapeLayer = {
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.actions = ["path":NSNull(),"position":NSNull(),"bounds":NSNull()]
        self.layer.mask = maskLayer
        return maskLayer
    }()
    // 动画缓冲key
    let kRotationAnimation = "kRotationAnimation"
    // 动画形状层
    let shapeLayer = CAShapeLayer()
    lazy var identityTransform: CATransform3D={
       var transform = CATransform3DIdentity
        transform.m34 = CGFloat(1.0 / -500.0)
        transform = CATransform3DRotate(transform, CGFloat(-90).toRadians(), 0.0, 0.0, 1.0)
        return transform
    }()
    public override init(frame: CGRect) {
        super.init(frame: frame)
        shapeLayer.lineWidth = 1.0
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = tintColor.cgColor
        shapeLayer.actions = ["strokeEnd":NSNull(), "transform":NSNull()]
        shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        layer.addSublayer(shapeLayer)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 设置进度
    public func setCircleProgress(_ progress:CGFloat){
        shapeLayer.strokeEnd = min(0.9*progress, 0.9) // 最大到0.9,然后开始动画[有个一个10%距离的空白旋转]
        if progress > 1.0{
            let degrees = (progress - 1.0) * 200.0
            shapeLayer.transform = CATransform3DRotate(identityTransform, degrees.toRadians(), 0.0, 0.0, 1.0)
        }else{
            shapeLayer.transform = identityTransform
        }
    }
    /// 开始动画[从当前的进度位置开始旋转动画]
    public func startAnimating(){
        if shapeLayer.animation(forKey: kRotationAnimation) != nil{
            return
        }
        // rotation旋转动画
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = CGFloat(2*Double.pi) + currentDegree()
        rotationAnimation.duration = 1.0
        rotationAnimation.repeatCount = Float.infinity
        rotationAnimation.isRemovedOnCompletion = false
        rotationAnimation.fillMode = kCAFillModeForwards
        shapeLayer.add(rotationAnimation, forKey: kRotationAnimation)
    }
    /// 结束动画
    public func stopAnimating(){
        shapeLayer.removeAnimation(forKey: kRotationAnimation)
    }
    func currentDegree()-> CGFloat{
        return shapeLayer.value(forKeyPath: "transform.rotation.z") as! CGFloat
    }
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        shapeLayer.strokeColor = tintColor.cgColor
    }
    /// 刷新布局
    public override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        let inset = shapeLayer.lineWidth / 2.0
        shapeLayer.path = UIBezierPath(ovalIn: shapeLayer.bounds.insetBy(dx: inset, dy: inset)).cgPath
    }
}
fileprivate extension CGFloat{
    func toRadians()-> CGFloat{
        return self * CGFloat(Double.pi) / 180
    }
    func toDegrees()-> CGFloat{
        return self * 180 / CGFloat(Double.pi)
    }
}
