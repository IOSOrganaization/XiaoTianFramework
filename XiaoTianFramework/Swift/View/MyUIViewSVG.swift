//
//  MyUIViewSVG.swift
//  XiaoTianFramework
//  支持加载SVG图片
//  Created by guotianrui on 2017/8/10.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
// IB可识别
@IBDesignable
public class MyUIViewSVG: UIView{
    // Draw SVG Shape
    var shapeLayer = CAShapeLayer()
    // IB可检索/可注入 项
    @IBInspectable public var svgName:String?{
        didSet{
            // 支持XIB 生成预览图
            #if TARGET_INTERFACE_BUILDER
                let bundle = Bundle(for: type(of: self))
            #else
                let bundle = Bundle.main
            #endif
            // 加载xxx.svg文件
            if let url = bundle.url(forResource: svgName, withExtension: "svg"){
                self.shapeLayer = CAShapeLayer(svgUrl: url)
                if shapeLayer.superlayer == nil{
                    layer.addSublayer(shapeLayer)
                }
            }
        }
    }
    public func getSVGSize()-> CGSize?{
        guard var width = objc_getAssociatedObject(shapeLayer, &CAShapeLayer.AssociateKey.width) as? String else{
            return nil
        }
        guard var height = objc_getAssociatedObject(shapeLayer, &CAShapeLayer.AssociateKey.height) as? String else{
            return nil
        }
        // 100px,100px
        if width.hasSuffix("px") {
            width.removeLast(2)
        }
        if height.hasSuffix("px") {
            height.removeLast(2)
        }
        return CGSize(width:CGFloat(strtof(width, nil)), height:CGFloat(strtof(height, nil)))
    }
}

extension MyUIViewSVG{
    public convenience init(svgName:String){
        self.init()
        self.svgName = svgName
    }
}

// SVG Shape
fileprivate extension CAShapeLayer{
    struct AssociateKey {
        static var width = "MyUIViewSVG_CAShapeLayer_AssociateKey_width"
        static var height = "MyUIViewSVG_CAShapeLayer_AssociateKey_height"
    }
    convenience init(svgString:String){
        self.init()
        self.path = UIBezierPath(svgString:svgString).cgPath
    }
    convenience init(svgUrl:URL){
        self.init()
        let _ = SVGXMLParser(svgUrl: svgUrl, containerLayer: self)
    }
    convenience init(svgData:Data) {
        self.init()
        let _ = SVGXMLParser(svgData: svgData, containerLayer: self)
    }
}
// SVG Path
fileprivate extension UIBezierPath{
    convenience init(svgString:String){
        self.init()
        let _ = parseSVGPath(svgString, forPath: self)
    }
    static func pathWithSVGURL(_ svgUrl:URL)-> UIBezierPath?{
        return SVGXMLParser(svgUrl: svgUrl, containerLayer: nil, shouldParseSinglePathOnly: true).paths.first
    }
}
// SVGXML -> UIBezierPath
fileprivate class SVGXMLParser:NSObject,XMLParserDelegate{
    fileprivate var elementStack = MyStack<NSObject>()
    var containerLayer:CALayer?
    var paths = [UIBezierPath]()
    var shouldParseSinglePathOnly = false
    let tagMapping: [String:String] = ["path":"SVGXMLParserPath", "svg":"SVGXMLParserSVGElement"]
    
    convenience init(svgUrl:URL,containerLayer:CALayer? = nil,shouldParseSinglePathOnly:Bool = false){
        self.init(parser: XMLParser(contentsOf: svgUrl), containerLayer: containerLayer, shouldParseSinglePathOnly: shouldParseSinglePathOnly)
    }
    convenience init(svgData:Data,containerLayer:CALayer? = nil,shouldParseSinglePathOnly:Bool = false){
        self.init(parser: XMLParser(data: svgData), containerLayer: containerLayer, shouldParseSinglePathOnly: shouldParseSinglePathOnly)
    }
    init(parser:XMLParser?,containerLayer:CALayer? = nil,shouldParseSinglePathOnly:Bool = false){
        self.containerLayer = containerLayer
        self.shouldParseSinglePathOnly = shouldParseSinglePathOnly
        super.init()
        parser?.delegate = self
        parser?.parse()
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if let newElement = tagMapping[elementName]{
            let clazz = NSClassFromString(newElement) as! NSObject.Type
            let newInstance = clazz.init()
            let propertys = UtilAnyObject.getClassPropertyNames(clazz: clazz) ?? []
            for name in propertys{
                // tag attribute
                if let value = attributeDict[name]{
                    // Set Value(KVC)
                    newInstance.setValue(value, forKey: name)
                }
            }
            if newInstance is SVGXMLParserPath{
                if let path = newInstance as? SVGXMLParserPath{
                    // Add To Container Shape Layer
                    if let containerLayer = containerLayer{
                        containerLayer.addSublayer(path.shapeLayer)
                    }
                    // Cache Parsed Path
                    self.paths.append(path.path)
                    if shouldParseSinglePathOnly{
                        parser.abortParsing()
                    }
                }
            }
            if newInstance is SVGXMLParserSVGElement{
                // SVG width and height
                if let svg = newInstance as? SVGXMLParserSVGElement{
                    if let width = svg.width{
                        objc_setAssociatedObject(containerLayer, &CAShapeLayer.AssociateKey.width, width, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                    }
                    if let height = svg.width{
                        objc_setAssociatedObject(containerLayer, &CAShapeLayer.AssociateKey.height, height, .OBJC_ASSOCIATION_COPY_NONATOMIC)
                    }
                }
            }
            elementStack.push(newInstance)
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let last = elementStack.last{
            // elementName = tagKey (tagClassName -> tagKey)
            if let tagKey = allKeysForValue(tagMapping, valueToMatch: UtilAnyObject.getClassName(clazz: last.classForCoder))?.first{
                if elementName == tagKey{
                    let _ = elementStack.pop()
                }
            }
        }
    }
    internal func allKeysForValue<K,V:Equatable>(_ dic:[K:V], valueToMatch:V)-> [K]?{
        return dic.filter { $0.value == valueToMatch }.map{ $0.key } // filter equate to value and return the key
    }
}
/// XML 解释读取实体
@objc(SVGXMLParserGroup) private class SVGXMLParserGroup:NSObject{}
@objc(SVGXMLParserSVGElement) private class SVGXMLParserSVGElement:NSObject{
    var width:String?
    var height:String?
}
@objc(SVGXMLParserPath) private class SVGXMLParserPath:NSObject{
    var path = UIBezierPath()
    var shapeLayer = CAShapeLayer()
    // path->d (attribute)
    var d:String?{
        didSet{
            if let pathString = d{
                // String -> Path
                path = parseSVGPath(pathString)
                shapeLayer.path = path.cgPath
            }
        }
    }
    // path->fill (attribute)
    var fill:String?{
        didSet{
            if let hexColor = fill {
                self.shapeLayer.fillColor = UtilColor().color(hexColor)?.cgColor ?? UIColor.clear.cgColor
            }
        }
    }
}
// String->UIBezierPath
fileprivate func parseSVGPath(_ pathString:String, forPath:UIBezierPath? = nil)-> UIBezierPath{
    assert(pathString.hasPrefix("M") || pathString.hasPrefix("m"), "Path d attribute must being with MoveTo Command (M/m)")
    let workingString = pathString.hasSuffix("Z") == false && pathString.hasSuffix("z") == false ? pathString + "z" : pathString // end with z or add z to end
    let returnPath:UIBezierPath = forPath ?? UIBezierPath()
    // 开始解析画图
    autoreleasepool{
        var currentPathCommand = Path("M")
        var currentStackNumber = StackNumber()
        var previousParams:Previous?
        let pushCoordinateAndClear: ()->() = {
            if !currentStackNumber.isEmpty{
                if let value = currentStackNumber.asCGFloat{
                    if let params = currentPathCommand.pushCoordinateAndExecuteIfPossible(value, previousParams){
                        previousParams = params
                    }
                }
                currentStackNumber.clear()
            }
        }
        // 迭代字符
        for character in workingString{
            if let result = charachterDictionary[character]{
                if result is Path{
                    pushCoordinateAndClear()
                    currentPathCommand = result as! Path
                    currentPathCommand.path = returnPath
                    // 结束
                    if currentPathCommand.character == "Z" || currentPathCommand.character == "z"{
                        currentPathCommand.execute(path: returnPath, previousParams)
                    }
                }else if result is CharSeparator{
                    pushCoordinateAndClear()
                }else if result is CharSign{
                    pushCoordinateAndClear()
                    currentStackNumber = StackNumber(character)
                }else{
                    if currentStackNumber.isEmpty{
                        currentStackNumber = StackNumber(character)
                    }else{
                        currentStackNumber.push(character)
                    }
                }
            }else{
                assert(false, "Invalid character \"\(character)\" found")
            }
        }
    }
    return returnPath
}
// 支持的字符指令集合
fileprivate let charachterDictionary:[Character:Char] = [
    // 画图指令
    "M":MoveTo("M", .absolute),
    "m":MoveTo("m", .relative),
    "C":CurveTo("C", .absolute),
    "c":CurveTo("c", .relative),
    "S":SmoothCurveTo("S", .absolute),
    "s":SmoothCurveTo("s", .relative),
    "L":LineTo("L", .absolute),
    "l":LineTo("l", .relative),
    "H":HorizontalLineTo("H", .absolute),
    "h":HorizontalLineTo("h", .relative),
    "V":VerticalLineTo("V", .absolute),
    "v":VerticalLineTo("v", .relative),
    "Q":QuadraticCurveTo("Q", .absolute),
    "q":QuadraticCurveTo("q", .relative),
    "T":SmoothCurveTo("T", .absolute),
    "t":SmoothCurveTo("t", .relative),
    "Z":ClosePath("Z", .absolute),
    "z":ClosePath("z", .relative),
    //
    "-":CharSign("-"),
    // 数值
    ".":CharNumber("."),
    "0":CharNumber("0"),
    "1":CharNumber("1"),
    "2":CharNumber("2"),
    "3":CharNumber("3"),
    "4":CharNumber("4"),
    "5":CharNumber("5"),
    "6":CharNumber("6"),
    "7":CharNumber("7"),
    "8":CharNumber("8"),
    "9":CharNumber("9"),
    // 分隔符
    " ":CharSeparator(" "),
    ",":CharSeparator(",")
]
// 字符
fileprivate class Char{
    var character:Character?
    convenience init(_ character:Character?) {
        self.init()
        self.character = character
    }
}
fileprivate class CharNumber:Char {}
fileprivate class CharSign:Char {}
fileprivate class CharSeparator:Char {}
// 绘画
fileprivate protocol Command{
    var paramsCount:Int{ get }
    func execute(path:UIBezierPath,_ previous:Previous?)
}

fileprivate class Path:Char,Command{
    fileprivate enum PathType{ case absolute, relative }
    var paramsCount: Int{ return 0 }
    func execute(path: UIBezierPath, _ previous: Previous?) {
        assert(false,"Subclasses must implement this method")
    }
    //
    var pathType = PathType.absolute
    var params:[CGFloat] = Array()
    var path = UIBezierPath()
    var canExecute:Bool{
        if paramsCount == 0{
            return true
        }
        if params.count == 0{
            return false
        }
        if params.count % paramsCount != 0{
            return false
        }
        return true
    }
    
    convenience init(_ character:Character,_ pathType:PathType){
        self.init()
        self.character = character
        self.pathType = pathType
    }
    //
    func pushCoordinateAndExecuteIfPossible(_ coordinate:CGFloat,_ previous:Previous?)-> Previous?{
        self.params.append(coordinate)
        if canExecute{
            execute(path: path, previous)
            let returnParams = params
            params.removeAll(keepingCapacity: false)
            return Previous(command: String(character!), params: returnParams)
        }
        return nil
    }
    
    func pointForPathType(_ point:CGPoint)-> CGPoint{
        return pathType == .absolute ? point : CGPoint(x: point.x + path.currentPoint.x, y: point.y + path.currentPoint.y)
    }
}
fileprivate struct Previous{
    var command:String?
    var params:[CGFloat]?
}
fileprivate struct StackNumber{
    var character:String = ""
    var asCGFloat:CGFloat?{
        return isEmpty ? nil : CGFloat(strtod(character, nil))// String To Double
    }
    var isEmpty:Bool{
        return character.isEmpty
    }
    init(){}
    init(_ character:Character){
        self.character = String(character)
    }
    mutating func push(_ character:Character){
        self.character += String(character)
    }
    mutating func clear(){
        character = ""
    }
}
// 绘画形状
fileprivate class MoveTo: Path{
    override var paramsCount: Int { return 2 }
    override func execute(path: UIBezierPath, _ previous: Previous?) { path.move(to: pointForPathType(CGPoint(x: params[0], y:params[1]))) }
}
fileprivate class ClosePath: Path{
    override var paramsCount: Int { return 0 }
    override func execute(path: UIBezierPath, _ previous: Previous?) { path.close() }
}
fileprivate class LineTo: Path{
    override var paramsCount: Int { return 2 }
    override func execute(path: UIBezierPath, _ previous: Previous?) { path.addLine(to: pointForPathType(CGPoint(x: params[0], y:params[1]))) }
}
fileprivate class HorizontalLineTo: Path{
    override var paramsCount: Int { return 1 }
    override func execute(path: UIBezierPath, _ previous: Previous?) {
        switch pathType {
        case .absolute:
            path.addLine(to: CGPoint(x: params[0], y: path.currentPoint.y))
        case .relative:
            path.addLine(to: CGPoint(x: params[0] + path.currentPoint.x, y: path.currentPoint.y))
        }
    }
}
fileprivate class VerticalLineTo: Path{
    override var paramsCount: Int { return 1 }
    override func execute(path: UIBezierPath, _ previous: Previous?) {
        switch pathType {
        case .absolute:
            path.addLine(to: CGPoint(x: path.currentPoint.x, y: params[0]))
        case .relative:
            path.addLine(to: CGPoint(x: path.currentPoint.x, y: params[0] + path.currentPoint.y))
        }
    }
}
fileprivate class CurveTo: Path{
    override var paramsCount: Int { return 6 }
    override func execute(path: UIBezierPath, _ previous: Previous?) {
        let start = pointForPathType(CGPoint(x: params[0], y:params[1]))
        let end = pointForPathType(CGPoint(x: params[2], y:params[3]))
        let point = pointForPathType(CGPoint(x: params[4], y:params[5]))
        path.addCurve(to: point, controlPoint1: start, controlPoint2: end)
    }
}
fileprivate class SmoothCurveTo: Path{
    override var paramsCount: Int { return 4 }
    override func execute(path: UIBezierPath, _ previous: Previous?) {
        if let previousParams = previous?.params{
            let point = pointForPathType(CGPoint(x: params[2], y:params[3]))
            let end = pointForPathType(CGPoint(x: params[0], y:params[1]))
            let currentPoint = path.currentPoint
            var startX = currentPoint.x
            var startY = currentPoint.y
            if let char = previous?.command{
                switch char {
                case "C":
                    startX = currentPoint.x * 2.0 - previousParams[2]
                    startY = currentPoint.y * 2.0 - previousParams[3]
                case "c":
                    let old = CGPoint(x:currentPoint.x - previousParams[4],y:currentPoint.y - previousParams[5])
                    startX = currentPoint.x * 2.0 - previousParams[2] - old.x
                    startY = currentPoint.y * 2.0 - previousParams[3] - old.y
                case "S":
                    startX = currentPoint.x * 2.0 - previousParams[0]
                    startY = currentPoint.y * 2.0 - previousParams[1]
                case "s":
                    let old = CGPoint(x:currentPoint.x - previousParams[2],y:currentPoint.y - previousParams[3])
                    startX = currentPoint.x * 2.0 - previousParams[0] - old.x
                    startY = currentPoint.y * 2.0 - previousParams[1] - old.y
                default:
                    break
                }
                path.addCurve(to: point, controlPoint1: CGPoint(x:startX,y:startY), controlPoint2: end)
            }else{
                assert(false, "Must supply previous parameters for SmoothCurveTo")
            }
        }else{
            assert(false, "Must supply previous parameters for SmoothCurveTo")
        }
    }
}
fileprivate class QuadraticCurveTo: Path{
    override var paramsCount: Int { return 4 }
    override func execute(path: UIBezierPath, _ previous: Previous?) {
        let start = pointForPathType(CGPoint(x: params[0], y:params[1]))
        let point = pointForPathType(CGPoint(x: params[2], y:params[3]))
        path.addQuadCurve(to: point, controlPoint: start)
    }
}
fileprivate class SmoothQuadraticCurveTo: Path{
    override var paramsCount: Int { return 2 }
    override func execute(path: UIBezierPath, _ previous: Previous?) {
        if let previousParams = previous?.params{
            let point = pointForPathType(CGPoint(x: params[0], y:params[1]))
            var start = path.currentPoint
            if let char = previous?.command{
                let currentPoint = path.currentPoint
                switch char {
                case "Q":
                    start = CGPoint(x: currentPoint.x * 2.0 - previousParams[0], y: currentPoint.y * 2.0 - previousParams[1])
                case "q":
                    let old = CGPoint(x: currentPoint.x - previousParams[2], y: currentPoint.y - previousParams[3])
                   start = CGPoint(x: currentPoint.x * 2.0 - previousParams[0] - old.x, y: currentPoint.y * 2.0 - previousParams[1] - old.y)
                default:
                    break
                }
                path.addQuadCurve(to: point, controlPoint: start)
            }else{
                assert(false, "Must supply previous parameters for SmoothCurveTo")
            }
        }else{
            assert(false, "Must supply previous parameters for SmoothCurveTo")
        }
    }
}

