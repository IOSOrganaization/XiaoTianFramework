//
//  MyLogoIndicator.swift
//  DriftBook
//
//  Created by 郭天蕊 on 2017/1/3.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class MyLogoIndicator: UIView{
    // MARK - Variables
    lazy fileprivate var animationLayer : CALayer = {
        return CALayer()
    }()
    lazy fileprivate var backgroudLayer : CALayer = {
        return CALayer()
    }()
    
    var isAnimating : Bool = false
    var hidesWhenStopped : Bool = true
    var layoutFrame: CGRect!
    
    // MARK - Init
    init() {
        // 旋转 Bar
        let imageBar: UIImage! = UIImage(named: "loading_bar")
        layoutFrame = CGRect(x: 0.0, y: 0.0, width: imageBar.size.width, height: imageBar.size.height)
        super.init(frame: layoutFrame)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        //
        animationLayer.frame = layoutFrame
        animationLayer.contents = imageBar.cgImage
        animationLayer.masksToBounds = true
        // 背景 Logo
        let imageBarLogo = UIImage(named: "loading_bar_bg")
        backgroudLayer.frame = layoutFrame
        backgroudLayer.contents = imageBarLogo?.cgImage
        backgroudLayer.masksToBounds = true
        //
        self.layer.addSublayer(backgroudLayer)
        self.layer.addSublayer(animationLayer)
        
        addRotation(forLayer: animationLayer)
        pause(animationLayer)
        // 隐藏 View
        self.isHidden = true
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        // 旋转 Bar
        let imageBar: UIImage! = UIImage(named: "loading_bar")
        layoutFrame = CGRect(x: 0.0, y: 0.0, width: imageBar.size.width, height: imageBar.size.height)
        //
        animationLayer.frame = layoutFrame
        animationLayer.contents = imageBar.cgImage
        animationLayer.masksToBounds = true
        // 背景 Logo
        let imageBarLogo = UIImage(named: "loading_bar_bg")
        backgroudLayer.frame = layoutFrame
        backgroudLayer.contents = imageBarLogo?.cgImage
        backgroudLayer.masksToBounds = true
        //
        self.layer.addSublayer(backgroudLayer)
        self.layer.addSublayer(animationLayer)
        
        addRotation(forLayer: animationLayer)
        pause(animationLayer)
        // 隐藏 View
        self.isHidden = true
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
        rotation.isRemovedOnCompletion = false //完成后移除动画
        rotation.repeatCount = HUGE //重复次数 [darwin/c/math]
        rotation.fillMode = kCAFillModeForwards //填充模式
        rotation.fromValue = NSNumber(value: 0.0 as Float) //开始值
        rotation.toValue = NSNumber(value: 3.1415 * 2.0 as Float)//结束值
        //
        layer.add(rotation, forKey: "rotate") // 添加 Animation
    }
    /// 开始
    func startAnimating () {
        if isAnimating {
            return
        }
        if hidesWhenStopped {
            self.isHidden = false
        }
        resume(animationLayer)
    }
    /// 重新开始
    func resume(_ layer : CALayer) {
        let pausedTime : CFTimeInterval = layer.timeOffset
        
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
        
        isAnimating = true
    }
    /// 暂停
    func pause(_ layer : CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        
        layer.speed = 0.0
        layer.timeOffset = pausedTime
        
        isAnimating = false
    }
    /// 停止
    func stopAnimating () {
        if hidesWhenStopped {
            self.isHidden = true
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
