//
//  UtilLabel.swift
//  DriftBook
//
//  Created by XiaoTian on 16/7/19.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

@objc(UtilLabelXT)
class UtilLabel: NSObject{
    
    func setLabelMargin(){
        //UIButton *mButton = [[UIButton alloc] init];
        //[mButton setTitleEdgeInsets:UIEdgeInsetsMake(top, left, bottom, right)];
        //[mButton setTitle:@"Title" forState:UIControlStateNormal];
        //[self.view addSubView:mButton];
    }
    
    /// 创建标题Title的UILabel
    func genLabelTitle(text:String?) -> MyUILabel{
        let title = MyUILabel()
        title.text = text == nil ? "" : text
        title.textAlignment = NSTextAlignment.Left
        title.margin = 10
        title.textColor = .blackColor()
        title.font = utilShared.font.textTitle
        return title
    }
    /// 嵌入图片(生成图片属性文本)
    func genImageAttributeString(string:String?,_ image:UIImage?,_ position:Int) -> NSMutableAttributedString?{
        //
        let index = string?.startIndex.advancedBy(position)
        let preString = string?.substringToIndex(index!)
        let sufString = string?.substringFromIndex(index!)
        let mutableAttributeString = NSMutableAttributedString(string: preString!)
        // 图片依附
        let textAttachment = NSTextAttachment() // Text依附属性[嵌入]
        textAttachment.image = image
        let attributeString = NSAttributedString(attachment: textAttachment)
        //
        mutableAttributeString.appendAttributedString(attributeString)
        mutableAttributeString.appendAttributedString(NSAttributedString(string: sufString!))
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