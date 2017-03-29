//
//  MySeparatorView.swift
//  DriftBook
//  视图分割线View
//  Created by XiaoTian on 16/9/16.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@IBDesignable
class MySeparatorUIView : UIView {
    
    override init(frame: CGRect){
        super.init(frame: frame)
        backgroundColor = UtilColor().separatorColor
    }
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        backgroundColor = UtilColor().separatorColor
    }
    
    func setColor(color:UIColor){
        backgroundColor = color
    }
    
    func setMargin(top:CGFloat,left:CGFloat,bottom:CGFloat,right:CGFloat){
        
        //UIEdgeInsetsMake(top, left, bottom, right)
    }
}
