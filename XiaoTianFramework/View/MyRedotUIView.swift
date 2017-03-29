//
//  MyRedotImageView.swift
//  DriftBook
//  圆红点提示
//  Created by XiaoTian on 16/9/16.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

class MyRedotUIView: UIView {
    var colorTip: UIColor!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        colorTip = UtilColor().redColor
    }
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
        colorTip = UtilColor().redColor
    }
    
    func setColor(color:UIColor){
        colorTip = color
        self.setNeedsDisplay() // 刷新drawRect UIView
    }
    
    // 画椭圆[控制: width,height约束相等(圆)]
    override func drawRect(rect: CGRect){
        let ctx = UIGraphicsGetCurrentContext() // 绘图上下文
        CGContextAddEllipseInRect(ctx, rect) // 椭圆
        CGContextSetFillColor(ctx, CGColorGetComponents(colorTip.CGColor)) // 设置绘图上下文画笔填充颜色
        CGContextFillPath(ctx) // 填充
    }
}