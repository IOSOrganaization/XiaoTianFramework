//
//  MyViewPieProgress.swift
//  XiaoTianFramework
//  圆饼进度条
//  Created by guotianrui on 2017/11/8.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
public class MyViewPieProgress: UIControl{
    @IBInspectable
    var progressAnimationDuration: TimeInterval = 0.5{
        didSet{
            self.progressLayer?.progressAnimationDuration = progressAnimationDuration
        }
    }
    @IBInspectable
    var progress: CGFloat = 0.0
    
    // 替换系统默认CALayer类(系统初始化)
    override public class var layerClass : AnyClass {
        return MyViewPieProgressLayer.self
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.yellow
        self.tintColor = UIColor.blue
        self.didInitialized()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.didInitialized()
        self.tintColorDidChange()
    }
    func didInitialized(){
        self.layer.contentsScale = UIScreen.main.scale// 要显示指定一个倍数
        self.layer.borderWidth = 1.0
        self.layer.needsDisplay()
    }
    public func setProgress(_ progress:CGFloat){
        setProgress(progress, false)
    }
    public func setProgress(_ progress:CGFloat,_ animate:Bool){
        self.progress = max(0.0, min(1.0, progress)) // 0.0~1.0
        if let layer = self.layer as? MyViewPieProgressLayer{
            layer.shouldChangeProgressWithAnimation = animate
            layer.progress = self.progress //触发KVO刷新
        }
        // ValueChanged Action Target
        sendActions(for: .valueChanged)
    }
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        // IB初始化,设置颜色
        self.progressLayer?.fillColor = tintColor;
        self.progressLayer?.borderColor = tintColor.cgColor;
    }
    var progressLayer:MyViewPieProgressLayer? {
        return self.layer as? MyViewPieProgressLayer
    }
}
class MyViewPieProgressLayer: CALayer{
    // KVO
    @NSManaged var fillColor:UIColor
    @NSManaged var progress:CGFloat
    
    var progressAnimationDuration:TimeInterval = 0.5
    var shouldChangeProgressWithAnimation:Bool = true
    //Yes, @NSManaged it kinda really acts like @dynamic(Ocjec-C) -- technically it might be identical even. Semantically there is a slight difference:
    //@dynamic says 'compiler, don't check if my properties are also implemented. There might be no code you can see but I guarantee it will work at runtime'
    //@NSManaged now says 'compiler, don't check those properties as I have Core Data to take care of the implementation - it will be there at runtime'
    //so you could even say: @NSManaged is syntactic sugar that is a more narrow version of dynamic :)
    
    override var frame: CGRect{
        didSet{
            let scale = UIScreen.main.scale
            let h = frame.height / 2
            cornerRadius = ceil(scale * h) / scale
        }
    }
    // KeyPath Action CALayer 特有
    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(progress) { //#keyPath变量模式获取 keyPath
            return true
        }
        return super.needsDisplay(forKey: key)
    }
    // KVO Action
    override func action(forKey event: String) -> CAAction? {
        if (event == #keyPath(progress) && shouldChangeProgressWithAnimation) {
            let animation:CABasicAnimation = CABasicAnimation(keyPath: event)
            animation.fromValue = presentation()?.value(forKey: event)
            animation.duration = progressAnimationDuration
            return animation
        }
        return super.action(forKey: event)
    }
    // 绘画
    override func draw(in context: CGContext) {
        if bounds.isEmpty{
            return
        }
        // 绘制扇形进度区域
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = min(center.x, center.y)
        let startAngle = -CGFloat(Double.pi)/2;
        let endAngle = CGFloat(Double.pi) * 2 * self.progress + startAngle;
        context.setFillColor(fillColor.cgColor)
        context.move(to: center)
        context.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise:false)
        context.closePath()
        context.fillPath()
        //
        super.draw(in: context)
    }
}
