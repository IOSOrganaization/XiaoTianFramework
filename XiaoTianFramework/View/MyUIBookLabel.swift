//
//  MyUIBookLabel.swift
//  DriftBook
//  图书标签UILabel,选中:绿色圆角背景,不选中:灰色圆角背景
//  Created by XiaoTian on 16/9/21.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

class MyUIBookLabel: UILabel {
    // Property 属性
    var selected: Bool = false {
        willSet { // 改变前侦听
            if newValue == selected {
                return
            }
            if newValue {
                backgroundColor = selectedBackgroundColor
            } else {
                backgroundColor = unSelectBackgroundColor
            }
        }
    }
    var selectedBackgroundColor: UIColor!{
        didSet{
            if selected{
                backgroundColor = selectedBackgroundColor
            }
        }
    }
    var unSelectBackgroundColor: UIColor!{
        didSet{
            if selected{
                backgroundColor = unSelectBackgroundColor
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPropertys()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //fatalError("init(coder:) has not been implemented")
        super.init(coder: aDecoder)
        setupPropertys()
    }
    
    func setupPropertys(){
        selected = false
        selectedBackgroundColor = utilShared.color.textGray
        unSelectBackgroundColor = utilShared.color.primaryColor
        textColor = utilShared.color.whileColor
        layer.masksToBounds = true
        layer.cornerRadius = 5
        backgroundColor = unSelectBackgroundColor
    }
    
}