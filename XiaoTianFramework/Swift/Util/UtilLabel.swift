//
//  UtilLabel.swift
//  DriftBook
//
//  Created by XiaoTian on 16/7/19.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilLabelXT)
open class UtilLabel: NSObject{
    
    func setLabelMargin(){
        //UIButton *mButton = [[UIButton alloc] init];
        //[mButton setTitleEdgeInsets:UIEdgeInsetsMake(top, left, bottom, right)];
        //[mButton setTitle:@"Title" forState:UIControlStateNormal];
        //[self.view addSubView:mButton];
    }
    
    /// 创建标题Title的UILabel
    func genLabelTitle(_ text:String?) -> MyUILabel{
        let title = MyUILabel()
        title.text = text == nil ? "" : text
        title.textAlignment = NSTextAlignment.left
        title.margin = 10
        title.textColor = .black
        title.font = utilShared.font.textTitle
        return title
    }
    /// 嵌入图片(生成图片属性文本)
    func genImageAttributeString(_ string:String?,_ image:UIImage?,_ position:Int) -> NSMutableAttributedString?{
        //
        let index = string?.characters.index((string?.startIndex)!, offsetBy: position)
        let preString = string?.substring(to: index!)
        let sufString = string?.substring(from: index!)
        let mutableAttributeString = NSMutableAttributedString(string: preString!)
        // 图片依附
        let textAttachment = NSTextAttachment() // Text依附属性[嵌入]
        textAttachment.image = image
        let attributeString = NSAttributedString(attachment: textAttachment)
        //
        mutableAttributeString.append(attributeString)
        mutableAttributeString.append(NSAttributedString(string: sufString!))
        return mutableAttributeString
        
        // http://stackoverflow.com/questions/24666515/how-do-i-make-an-attributed-string-using-swift
        // NSAttributedString
        // NSMutableAttributedString
        // NSForegroundColorAttributeName
        // NSBackgroundColorAttributeName
        // NSUnderlineStyleAttributeName :NSUnderlineStyle.StyleDouble.rawValue
        ////
    }
}
