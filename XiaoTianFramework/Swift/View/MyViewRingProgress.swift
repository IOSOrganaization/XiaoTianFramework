//
//  MyViewRingProgress.swift
//  XiaoTianFramework
//  渐变圆环加载进度条
//  Created by guotianrui on 2017/6/23.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
public class MyViewRingProgress: UIView{
    /// 内部圆半径
    @IBInspectable
    public var radius:CGFloat = 30{
        didSet{
            if let animateShapeLayouer = createAnimatedLayer(){
                animateShapeLayouer.removeFromSuperlayer()
                self.animateShapeLayouer = nil
            }
            if self.superview != nil{
                self.addAnimatedLayer()
            }
        }
    }
    /// 圆外边框颜色
    @IBInspectable
    public var storeColor:UIColor = UIColor.darkGray{
        didSet{
            animateShapeLayouer?.strokeColor = storeColor.cgColor
        }
    }
    /// 圆外边框宽度
    @IBInspectable
    public var storeThickness: CGFloat = 10{
        didSet{
            animateShapeLayouer?.lineWidth = storeThickness
        }
    }
    /// 动画图形层
    var animateShapeLayouer: CAShapeLayer?
    /// 重写Frame
    public override var frame: CGRect{
        didSet{
            if self.superview != nil{
                self.addAnimatedLayer()
            }
        }
    }
    // 构造器
    public convenience init(_ origin:CGPoint,_ radius:CGFloat = 30,_ storeColor:UIColor = UIColor.darkGray,_ storeThickness:CGFloat = 10) {
        self.init(frame: CGRect.zero)
        self.radius = radius
        self.storeColor = storeColor
        self.storeThickness = storeThickness
        let size = self.calculateFrameSize()
        self.frame = CGRect(x: origin.x,y:origin.y,width:size.width,height:size.height)
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            addAnimatedLayer()
        }else{
            animateShapeLayouer?.removeFromSuperlayer()
            animateShapeLayouer = nil
        }
    }
    private func addAnimatedLayer(){
        if let animateShapeLayouer = createAnimatedLayer(){
            self.animateShapeLayouer = animateShapeLayouer
            self.layer.addSublayer(animateShapeLayouer)
            //self.animateShapeLayouer?.position = CGPoint(x: (self.bounds.width - animateShapeLayouer.bounds.width) / 2, y: (self.bounds.height - animateShapeLayouer.bounds.height) / 2)
        }
    }
    private func createAnimatedLayer() -> CAShapeLayer?{
        if animateShapeLayouer != nil {
            return animateShapeLayouer
        }
        let shapeLayout = CAShapeLayer()
        let arcCenter = CGPoint(x: radius + storeThickness/2, y: radius + storeThickness/2) // 边界线/2 :控制边界在内部
        let rect = CGRect(x: 0.0, y: 0.0, width: arcCenter.x * 2.0, height: arcCenter.y * 2.0)
        let smoothPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: CGFloat(Double.pi * 3.0 / 2.0), endAngle: CGFloat(Double.pi / 2.0 + Double.pi * 5.0), clockwise: true)// 顺时针
        shapeLayout.contentsScale = UIScreen.main.scale
        shapeLayout.frame = rect
        shapeLayout.fillColor = UIColor.clear.cgColor// 其他填充颜色
        shapeLayout.strokeColor = storeColor.cgColor// 圆弧颜色
        shapeLayout.lineWidth = storeThickness
        shapeLayout.lineCap = kCALineCapRound // 圆弧连接圆角
        shapeLayout.lineJoin = kCALineJoinBevel // 圆弧连接斜面(渐变)
        shapeLayout.path = smoothPath.cgPath // 画圆弧
        //
        let maskLayer = CALayer()
        maskLayer.contents = UtilBundle().imageInBundleXiaoTian("angle-mask")?.cgImage
        maskLayer.frame = shapeLayout.bounds
        shapeLayout.mask = maskLayer // 遮蔽，遮盖层,遮圆弧[不透明:不遮蔽(不遮蔽背景),透明:遮蔽(遮蔽背景)]
        // 遮蔽层旋转
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = 1
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.isRemovedOnCompletion = false
        animation.repeatCount = 0x1e50f
        animation.fillMode = kCAFillModeForwards
        animation.autoreverses = false
        shapeLayout.mask?.add(animation, forKey: "rotate")
        // 圆弧层
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1
        animationGroup.repeatCount = 0x1e50f
        animationGroup.isRemovedOnCompletion = false
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        // 圆弧动画(圆角)
        let storeStartAnimation = CABasicAnimation(keyPath: "strokeStart")// 圆弧起始位置[0~1]
        storeStartAnimation.fromValue = 0.015
        storeStartAnimation.toValue = 0.515
        let storeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")// 圆弧结束位置[0~1]
        storeEndAnimation.fromValue = 0.485
        storeEndAnimation.toValue = 0.985
        animationGroup.animations = [storeStartAnimation,storeEndAnimation]
        //
        shapeLayout.add(animationGroup, forKey: "progress")
        return shapeLayout
    }
    public func calculateFrameSize() -> CGSize{
        return CGSize(width: (radius + storeThickness / 2) * 2, height: (radius + storeThickness / 2) * 2)
    }
}
