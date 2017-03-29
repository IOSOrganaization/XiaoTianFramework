//
//  UtilStringAttribute.swift
//  DriftBook
//  String Attribute
//  Created by 郭天蕊 on 2016/11/2.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

class UtilAttributedString: NSObject{
    
    /// 设置匹配Pattern的字符串的前景色
    func genForegroundColor(string: String! = nil,_ pattern:String!,_ color: UIColor) -> NSMutableAttributedString{
        let attributeString = NSMutableAttributedString(string: string)
        if let matchedRanges = matchingPattern(string, pattern){
            for range in matchedRanges {
                attributeString.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
            }
        }
        return attributeString
    }
    
    /// 模式匹配
    private func matchingPattern(target:String,_ pattern: String) -> [NSRange]!{
        var ranges: [NSRange]! = nil
        do{
            let escapedPattern = NSRegularExpression.escapedPatternForString(pattern)
            let regex = try NSRegularExpression(pattern: escapedPattern, options: .CaseInsensitive)
            let matchs = regex.matchesInString(target, options: .ReportProgress, range: NSMakeRange(0, target.characters.count))
            if matchs.count > 0 {
                ranges = []
            }
            for match in matchs {
                ranges.append(match.range)
            }
        } catch {
            
        }
        return ranges
    }
    //
    //    Character Attributes
    //    let NSAttachmentAttributeName: String
    //    let NSBackgroundColorAttributeName: 背景色
    //    let NSBaselineOffsetAttributeName: String
    //    let NSExpansionAttributeName: String
    //    let NSFontAttributeName: 字体
    //    let NSForegroundColorAttributeName: 前景色
    //    let NSKernAttributeName: String
    //    let NSLigatureAttributeName: String
    //    let NSLinkAttributeName: String
    //    let NSObliquenessAttributeName: String
    //    let NSParagraphStyleAttributeName: String
    //    let NSShadowAttributeName: String
    //    let NSStrikethroughColorAttributeName: String
    //    let NSStrikethroughStyleAttributeName: String
    //    let NSStrokeColorAttributeName: String
    //    let NSStrokeWidthAttributeName: String
    //    let NSTextEffectAttributeName: String
    //    let NSUnderlineColorAttributeName: String
    //    let NSUnderlineStyleAttributeName: String
    //    let NSVerticalGlyphFormAttributeName: String
    //    let NSWritingDirectionAttributeName: String
    //
    //    Document Types
    //    let NSPlainTextDocumentType: String
    //    let NSRTFTextDocumentType: String
    //    let NSRTFDTextDocumentType: String
    //    let NSHTMLTextDocumentType: String
    //
    //    Document Attributes
    //    let NSBackgroundColorDocumentAttribute: String
    //    let NSCharacterEncodingDocumentAttribute: String
    //    let NSDefaultAttributesDocumentAttribute: String
    //    let NSDefaultTabIntervalDocumentAttribute: String
    //    let NSDocumentTypeDocumentAttribute: String
    //    let NSHyphenationFactorDocumentAttribute: String
    //    let NSPaperMarginDocumentAttribute: String
    //    let NSPaperSizeDocumentAttribute: String
    //    let NSReadOnlyDocumentAttribute: String
    //    let NSTextLayoutSectionsAttribute: String
    //    let NSViewModeDocumentAttribute: String
    //    let NSViewSizeDocumentAttribute: String
    //    let NSViewZoomDocumentAttribute: String
    //
    //    Text Layout Sections Attribute
    //    let NSTextLayoutSectionOrientation: String
    //    let NSTextLayoutSectionRange: String
}