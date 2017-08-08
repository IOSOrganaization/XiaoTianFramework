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
        // 前景色: NSForegroundColorAttributeName: UIColor
        // 背景色: NSBackgroundColorAttributeName: UIColor
        // 下划线(单,双,分割,字符,单词线...): NSUnderlineStyleAttributeName :NSUnderlineStyle.StyleDouble.rawValue
        // 下划线颜色:NSUnderlineColorAttributeName:
        // 线条宽度:NSStrokeWidthAttributeName:2.0
        // 字体: NSFontAttributeName: UIFont
        // 文字效果:NSTextEffectAttributeName:NSTextEffectLetterpressStyle(文字凸出)
        // 阴影:NSShadowAttributeName:NSShadow {let shadow : NSShadow = NSShadow()shadow.shadowOffset = CGSizeMake(-2.0, -2.0)}
        // 段落样式:NSParagraphStyleAttributeName:
        // 字符连通(两个字符没间隔,连接一起):NSLigatureAttributeName:
        // 字符之间靠紧间隔:NSKernAttributeName:10
        // 删除线:NSStrikethroughStyleAttributeName:
        // 删除线颜色:NSStrikethroughColorAttributeName:
        // 文字线条宽度:NSStrokeWidthAttributeName:
        // 文字线条颜色:NSStrokeColorAttributeName:
        // 依附/嵌入:NSAttachmentAttributeName:
        // 超连接:NSLinkAttributeName:NSURL/NSString
        // 文字基线偏差:NSBaselineOffsetAttributeName:10
        // 倾斜度:NSObliquenessAttributeName:
        // 横向拉伸:NSExpansionAttributeName:1
        // 文字书写方向(Left-to-Right and Right-to-Left):NSWritingDirectionAttributeName:
        // 文字排布方向(0:横向,1:竖向):NSVerticalGlyphFormAttributeName:0/1
        //
        //If you need to render text vertically, attributed strings don’t seem to offer this solution just yet.
        //If you want to draw into a shape other than a rectangle, you will still have to use Core Text.
        //If you want to render your text on a non-horizontal line (such as a curved line), you will probably have to pick either Core Text or a CATextLayer.
        // https://www.invasivecode.com/weblog/foundation/attributed-string/
    }
}
