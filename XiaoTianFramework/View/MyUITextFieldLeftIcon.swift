//
//  MyUITextField.swift
//  DriftBook
//
//  Created by 郭天蕊 on 2016/10/21.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import UIKit

@IBDesignable
class MyUITextFieldLeftIcon: UITextField{
    @IBInspectable var padding: CGFloat = 0
    
    // 自定义 Padding 的 TextField
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        let leftViewWidth: CGFloat? = self.leftView?.bounds.width
        var paddingX = padding
        if leftViewWidth != nil {
            paddingX = leftViewWidth!
        }
        return CGRectInset(bounds, paddingX, padding)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}


