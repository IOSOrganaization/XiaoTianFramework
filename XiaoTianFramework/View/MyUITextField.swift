//
//  MyUITextField.swift
//  DriftBook
//
//  Created by XiaoTian on 2016/11/21.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@IBDesignable
class MyUITextField: UITextField{
    
    // Nib 初始加载完成
    override func awakeFromNib() {
        self.textColor = utilShared.color.blackColor
        self.font = utilShared.font.textInput
    }
}