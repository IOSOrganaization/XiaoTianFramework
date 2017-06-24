//
//  MyViewLinePropress.swift
//  XiaoTianFramework
//  线性进度条
//  Created by guotianrui on 2017/6/20.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

@IBDesignable
@objc(MyViewLinePropressXT)
public class MyViewLinePropress : UIView{
    public enum Orientation{
        case horizontal
        case vertical
    }
    public var orientation:Orientation = .horizontal
    private var progressBar: UIView!
    @objc(progressPercent)
    public var progress: CGFloat = 0.0{
        didSet{
            progress = progress < 0 ? 0 : progress > 1 ? 1 : progress
            guard let progressBarView = self.progressBar else {
                return
            }
            let rect = self.bounds
            // 分割Rect (slice, remainder)(切下的部分,剩余的部分)
            switch orientation {
            case .horizontal:
                let (slice, _) = rect.divided(atDistance: rect.width * progress, from: .minXEdge) // 从X最小边界开始,距离
                if !slice.equalTo(progressBarView.frame){
                    progressBarView.frame = slice
                }
            case .vertical:
                let (slice, _) = rect.divided(atDistance: rect.height * progress, from: .minYEdge) // 从X最小边界开始,距离
                if !slice.equalTo(progressBarView.frame){
                    progressBarView.frame = slice
                }
            }
        }
    }
    public var barColor:UIColor = UIColor.gray{
        didSet{
            progressBar.backgroundColor = barColor
        }
    }
    // 重写frame改变刷新进度条
    public override var frame: CGRect{
        get{
            return super.frame
        }
        set{
            var frame = newValue
            // y值向上取整[C:ceil]
            frame.origin.y = frame.origin.y.rounded(.up)
            //let yr = ceil(frame.origin.y)
            // 高度向下取整[C:floor]
            frame.size.height = frame.size.height.rounded(.down)
            //let hd = floor(frame.size.height)
            super.frame = frame
            DispatchQueue.main.async{
                [weak self] in
                if let progress = self?.progress{
                    self?.progress = progress
                }
            }
        }
    }
    // 构造器
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.backgroundColor = UIColor(white: 0.667, alpha: 0.2)
        self.tintAdjustmentMode = .normal
        self.progressBar = UIView()
        self.progressBar.backgroundColor =  self.barColor
        self.addSubview(self.progressBar)
        self.progress = 0.0
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// Animation 百分比改变
    public func setPercentage(_ percentage:CGFloat,_ duration:Double = 0.5){
        // 从当前值开始,线性递增
        UIView.animate(withDuration: duration, delay: 0.1, options: [.beginFromCurrentState,.curveLinear], animations: {
            [weak self] in
            self?.progress = percentage / 100.0
        })
    }
    /// Animation 显示/隐藏
    public func setBarVisibility(_ visiable:Bool){
        UIView.animate(withDuration: 0.5, delay: 0.1, options: [.beginFromCurrentState,.curveLinear], animations: {
            [weak self] in
            self?.progressBar.alpha = visiable ? 1 : 0
        })
    }
    /// 创建NavigationBar进度条
    public static func navigationBarProgress(_ navigation:UINavigationController?,_ height:CGFloat = 2.5,_ barColor:UIColor = UIColor.gray,_ backgroundColor:UIColor = UIColor(white: 0.667, alpha: 0.2)) -> MyViewLinePropress?{
        if let navigationBar = navigation?.navigationBar{
            let progressBar = MyViewLinePropress(frame: navigationBar.bounds.divided(atDistance: height, from: .maxYEdge).slice)
            progressBar.barColor = barColor
            progressBar.backgroundColor = backgroundColor
            navigationBar.addSubview(progressBar)
            return progressBar
        }
        return nil
    }
    deinit {
        progressBar?.layer.removeAllAnimations()
    }
}
