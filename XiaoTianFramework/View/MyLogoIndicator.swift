//
//  MyLogoIndicator.swift
//  DriftBook
//
//  Created by 郭天蕊 on 2017/1/3.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

@IBDesignable
class MyLogoIndicator: UIView{
    // MARK - Variables
    lazy private var animationLayer : CALayer = {
        return CALayer()
    }()
    lazy private var backgroudLayer : CALayer = {
        return CALayer()
    }()
    
    var isAnimating : Bool = false
    var hidesWhenStopped : Bool = true
    var layoutFrame: CGRect!
    
    // MARK - Init
    init() {
        // 旋转 Bar
        let imageBar: UIImage! = UIImage(named: "loading_bar")
        layoutFrame = CGRectMake(0.0, 0.0, imageBar.size.width, imageBar.size.height)
        super.init(frame: layoutFrame)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        //
        animationLayer.frame = layoutFrame
        animationLayer.contents = imageBar.CGImage
        animationLayer.masksToBounds = true
        // 背景 Logo
        let imageBarLogo = UIImage(named: "loading_bar_bg")
        backgroudLayer.frame = layoutFrame
        backgroudLayer.contents = imageBarLogo?.CGImage
        backgroudLayer.masksToBounds = true
        //
        self.layer.addSublayer(backgroudLayer)
        self.layer.addSublayer(animationLayer)
        
        addRotation(forLayer: animationLayer)
        pause(animationLayer)
        // 隐藏 View
        self.hidden = true
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        // 旋转 Bar
        let imageBar: UIImage! = UIImage(named: "loading_bar")
        layoutFrame = CGRectMake(0.0, 0.0, imageBar.size.width, imageBar.size.height)
        //
        animationLayer.frame = layoutFrame
        animationLayer.contents = imageBar.CGImage
        animationLayer.masksToBounds = true
        // 背景 Logo
        let imageBarLogo = UIImage(named: "loading_bar_bg")
        backgroudLayer.frame = layoutFrame
        backgroudLayer.contents = imageBarLogo?.CGImage
        backgroudLayer.masksToBounds = true
        //
        self.layer.addSublayer(backgroudLayer)
        self.layer.addSublayer(animationLayer)
        
        addRotation(forLayer: animationLayer)
        pause(animationLayer)
        // 隐藏 View
        self.hidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.layer.bounds
        if layoutFrame == nil || layoutFrame.width != bounds.width || layoutFrame.height != bounds.height{
            layoutFrame = bounds
            animationLayer.frame = layoutFrame
            backgroudLayer.frame = layoutFrame
        }
    }
    
    /// 添加旋转 Animation 到 CALayer 中
    func addRotation(forLayer layer : CALayer) {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath:"transform.rotation.z") //Animation 的 KeyPath
        // CALayout 动画[一个 View 中的一个 CALayout]
        rotation.duration = 1.0 //动画持续时间
        rotation.removedOnCompletion = false //完成后移除动画
        rotation.repeatCount = HUGE //重复次数 [darwin/c/math]
        rotation.fillMode = kCAFillModeForwards //填充模式
        rotation.fromValue = NSNumber(float: 0.0) //开始值
        rotation.toValue = NSNumber(float: 3.1415 * 2.0)//结束值
        //
        layer.addAnimation(rotation, forKey: "rotate") // 添加 Animation
    }
    /// 开始
    func startAnimating () {
        if isAnimating {
            return
        }
        if hidesWhenStopped {
            self.hidden = false
        }
        resume(animationLayer)
    }
    /// 重新开始
    func resume(layer : CALayer) {
        let pausedTime : CFTimeInterval = layer.timeOffset
        
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) - pausedTime
        layer.beginTime = timeSincePause
        
        isAnimating = true
    }
    /// 暂停
    func pause(layer : CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), fromLayer: nil)
        
        layer.speed = 0.0
        layer.timeOffset = pausedTime
        
        isAnimating = false
    }
    /// 停止
    func stopAnimating () {
        if hidesWhenStopped {
            self.hidden = true
        }
        pause(animationLayer)
    }
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil{
            startAnimating()
        }else{
            stopAnimating()
        }
    }
    override func didMoveToWindow(){
        super.didMoveToWindow()
        if self.window != nil{
            startAnimating()
        }else{
            stopAnimating()
        }
    }
    override func removeFromSuperview(){
        super.removeFromSuperview()
        stopAnimating()
    }
    // IB 显示
    override func prepareForInterfaceBuilder() {
        let bar = UIImageView(image: UtilPrepareForInterfaceBuilder.loadImage("loading_bar", self.classForCoder, self.traitCollection))
        bar.frame = self.frame
        let bg = UIImageView(image: UtilPrepareForInterfaceBuilder.loadImage("loading_bar_bg", self.classForCoder, self.traitCollection))
        bg.frame = self.frame
        self.addSubview(bar)
        self.addSubview(bg)
    }
}