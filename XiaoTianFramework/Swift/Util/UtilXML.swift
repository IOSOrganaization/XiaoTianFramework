//
//  UtilXML.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/8/9.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
open class UtilXML:NSObject, XMLParserDelegate{
    // 读取堆栈
    fileprivate var elementStack = MyStack<Element>()
    fileprivate var elementResult:Element?
    private var parser:XMLParser?
    
    /// XML转换
    public func parse(bundle:Bundle = Bundle.main,name:String?){
        if let name = name{
            parse(path: bundle.path(forResource: name, ofType: "xml"))
        }
    }
    
    public func parse(path:String?){
        if let path = path{
            parse(url:URL(fileURLWithPath: path))
        }
    }
    
    public func parse(url:URL?){
        if let url = url{
            parser = XMLParser(contentsOf: url)
            parser?.delegate = self
            parser?.parse()
        }
    }
    public func parse(data:Data?){
        //<person type='80'><name>XiaoTian</name><sex>男</sex><age>28</age><weight>60.4</weight><class><level>17</level><group>3</group><name>Soft Ware</name></class></person>
        if let data = data{
            parser = XMLParser(data: data)
            parser?.delegate = self
            parser?.parse()
        }
    }
    public func parserDidStartDocument(_ parser: XMLParser) {
        Mylog.log("parserDidStartDocument")
    }
    /// 解析到开始元素
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        Mylog.log("开始解析元素:" + elementName)
        elementStack.push(Element(elementName: elementName, namespaceURI: namespaceURI, qualifiedName: qName, attributeDict: attributeDict))
    }
    /// 找到字符串
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        Mylog.log("解析到元素值:" + string)
        elementStack.last?.valueString = string
    }
    
    /// 解析到结束元素
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        Mylog.log("结束解析元素:" + elementName)
        repeat{
            elementResult = elementStack.pop()
            if let preElement = elementStack.last{
                preElement.valueElements.append(elementResult!)
            }
        }while(elementResult?.elementName ?? elementName != elementName)
    }
    /// 解析错误
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        Mylog.log("parseErrorOccurred:\(parseError)")
    }
    /// 校验语法错误
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error) {
        Mylog.log("validationErrorOccurred:\(validationError)")
    }
    /// 找到CDATA
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        
    }
    /// 找到Comment备注
    public func parser(_ parser: XMLParser, foundComment comment: String) {
        
    }
    public func parserDidEndDocument(_ parser: XMLParser) {
        Mylog.log("parserDidEndDocument")
        Mylog.log(elementResult)
    }
    
    /// 缓冲解析的Element
    public class Element:NSObject{
        var elementName:String
        var namespaceURI:String?
        var qualifiedName:String?
        var attributeDict:[String : String]
        var valueString:String?
        //
        var valueElements = [Element]()
        
        init(elementName:String,namespaceURI:String?,qualifiedName:String?,attributeDict:[String : String]) {
            self.elementName = elementName
            self.namespaceURI = namespaceURI
            self.qualifiedName = qualifiedName
            self.attributeDict = attributeDict
        }
        public override var description: String{
            return "{elementName:\(elementName),namespaceURI:\(namespaceURI ?? "nil"),qualifiedName:\(qualifiedName ?? "nil"),valueString:\(valueString ?? "nil"),attributeDict:\(attributeDict),elements:\(valueElements)}"
        }
    }
}
public class Person:NSObject{
    var type:String?
}
