//
//  MyCircularSlider.swift
//  XiaoTianFramework
//  圆形滑块(圆形时间选择,圆形百分比选择)
//  Created by guotianrui on 2017/7/26.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
public class MyCircularSlider: UIControl{
    public enum HandleType:Int {
        case circleWhite,circleBlack,centerOpen,centerClosed,circleBig
    }
    public var angle:Int = 0
    public var radius:CGFloat = 0
    public var fixedAngle:Int = 0
    public var snapToLabels = true
    public var lineWidth:CGFloat = 5
    public var minimumValue:CGFloat = 0
    public var currentValue:CGFloat = 0
    public var handleColor = UIColor.red
    public var filledColor = UIColor.red
    public var labelColor = UIColor.black
    public var maximumValue:CGFloat = 100
    public var unfilledColor = UIColor.black
    public var handleType:HandleType = .circleWhite
    public var labelFont = UIFont.systemFont(ofSize: 14)
    public var labelsInnerMarking:[String]?{ // 自动布局到等分圆位置[12,1,2,3,4,5,6,7,8,9,10,11]
        didSet{
            // Call Draw Func
            setNeedsDisplay()
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        radius = frame.size.height/2 - lineWidth/2 - 10
        backgroundColor = UIColor.clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        let center = CGPoint(x:frame.size.width/2,y:frame.size.height/2)
        // filled Circle
        context?.addArc(center: center, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: false)
        unfilledColor.setStroke()
        context?.setLineWidth(lineWidth)
        context?.setLineCap(.butt)
        context?.drawPath(using: .stroke)
        //
        if (handleType == .centerOpen || handleType == .centerClosed) && fixedAngle > 5{
            context?.addArc(center: center, radius: radius, startAngle: CGFloat(3*Double.pi/2), endAngle: CGFloat(3*Double.pi/2 - toRad(angle + 3)), clockwise: false)
        }else{
            context?.addArc(center: center, radius: radius, startAngle: CGFloat(3*Double.pi/2), endAngle: CGFloat(3*Double.pi/2 - toRad(angle)), clockwise: false)
        }
        filledColor.setStroke()
        context?.setLineWidth(lineWidth)
        context?.setLineCap(.butt)
        context?.drawPath(using: .stroke)
        // 圆环文本
        if let labelsEvenSpacing = labelsInnerMarking{
            if labelsEvenSpacing.isEmpty{
                return
            }
            let distanceToMove:Double = -15
            for (index, label) in labelsEvenSpacing.enumerated().reversed(){
                let text = label as NSString
                let percantageAlongCircle = CGFloat(index)/CGFloat(labelsEvenSpacing.count)
                let degressForLabel = percantageAlongCircle * 360
                let closestPointOnCircleToLabel = pointFromAngle(Int(degressForLabel))
                let labelSize = self.labelSize(text)
                var labelLocation = CGRect(x: closestPointOnCircleToLabel.x, y: closestPointOnCircleToLabel.y, width: labelSize.width, height: labelSize.height)
                let center = CGPoint(x:frame.size.width/2, y:frame.size.height/2)
                let radiansTowardsCenter = toRad(Int(angleFromNorth(center, closestPointOnCircleToLabel, false)))
                labelLocation.origin.x = labelLocation.origin.x + CGFloat(distanceToMove*cos(radiansTowardsCenter)) - labelLocation.size.width/4
                labelLocation.origin.y = labelLocation.origin.y + CGFloat(distanceToMove*sin(radiansTowardsCenter)) - labelLocation.size.height/4
                text.draw(in: labelLocation, withAttributes: [NSAttributedString.Key.font:labelFont, NSAttributedString.Key.foregroundColor:labelColor])
            }
        }
        //
        context?.saveGState()
        let handleCenter = pointFromAngle(angle)
        switch handleType {
        case .circleWhite:
            UIColor(white: 1.0, alpha: 0.7).set()
            context?.fillEllipse(in: CGRect(x: handleCenter.x, y: handleCenter.y, width: lineWidth, height: lineWidth))
        case .circleBlack:
            UIColor(white: 0.0, alpha: 0.7).set()
            context?.fillEllipse(in: CGRect(x: handleCenter.x, y: handleCenter.y, width: lineWidth, height: lineWidth))
        case .centerClosed:
            handleColor.set()
            context?.addArc(center: CGPoint(x:handleCenter.x+lineWidth/2,y:handleCenter.y+lineWidth/2), radius: lineWidth, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: false)
            context?.setLineWidth(7)
            context?.setLineCap(.butt)
            context?.drawPath(using: .stroke)
            context?.fillEllipse(in: CGRect(x: handleCenter.x, y: handleCenter.y, width: lineWidth-1, height: lineWidth-1))
        case .centerOpen:
            handleColor.set()
            context?.addArc(center: CGPoint(x:handleCenter.x+lineWidth/2,y:handleCenter.y+lineWidth/2), radius: 8, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: false)
            context?.setLineWidth(4)
            context?.setLineCap(.butt)
            context?.drawPath(using: .stroke)
            context?.addArc(center: CGPoint(x:handleCenter.x+lineWidth/2,y:handleCenter.y+lineWidth/2), radius: lineWidth/2, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: false)
            context?.setLineWidth(2)
            context?.setLineCap(.butt)
            context?.drawPath(using: .stroke)
        case .circleBig:
            handleColor.set()
            context?.fillEllipse(in: CGRect(x: handleCenter.x-2.5, y: handleCenter.y-2.5, width: lineWidth+5, height: lineWidth+5))
        }
        context?.restoreGState()
    }
    // UIControl
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        return true
    }
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        let lastPoint = touch.location(in: self)
        moveHandle(lastPoint)
        sendActions(for: .valueChanged)
        return true
    }
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if !snapToLabels{
            return
        }
        if let labelsEvenSpacing = labelsInnerMarking{
            var point:CGPoint = .zero
            var minDist:Int = 360
            for (index,_) in labelsEvenSpacing.enumerated().reversed(){
                let percentageAlongCircle = CGFloat(index) / CGFloat(labelsEvenSpacing.count)
                let degressForLabel = Int(percentageAlongCircle * 360)
                if abs(fixedAngle - degressForLabel) < minDist{
                    minDist = abs(fixedAngle - degressForLabel)
                    point = pointFromAngle(degressForLabel + 90 + 180)
                }
            }
            let center = CGPoint(x:frame.size.width/2,y:frame.size.height/2)
            angle = Int(floor(angleFromNorth(center, point, false)))
            currentValue = valueFromAngle()
            setNeedsDisplay()
        }
    }
    // Handle Func
    func toRad(_ deg:Int)-> Double{
        return Double.pi*Double(deg)/180
    }
    func toDeg(_ deg:CGFloat)-> CGFloat{
        return deg*180/CGFloat(Double.pi)
    }
    func pointFromAngle(_ angle:Int)->CGPoint{
        let center = CGPoint(x: frame.size.width/2 - lineWidth/2, y: frame.size.height/2 - lineWidth/2)
        return CGPoint(x: round(center.x + radius*CGFloat(cos(toRad(-angle-90)))), y: round(center.y + radius*CGFloat(sin(toRad(-angle-90)))))
    }
    func angleFromNorth(_ p1:CGPoint,_ p2:CGPoint,_ flipped:Bool)-> CGFloat{
        var v = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        let vmag = sqrt(v.x*v.x + v.y*v.y)
        var result:CGFloat = 0
        v.x /= vmag
        v.y /= vmag
        let radians = atan2(v.y, v.x)
        result = toDeg(radians)
        return result >= 0 ? result : result + 360
    }
    func labelSize(_ label:NSString)-> CGSize{
        let rect = label.boundingRect(with: CGSize(width:CGFloat.greatestFiniteMagnitude, height:CGFloat.greatestFiniteMagnitude), options:.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: labelFont], context:nil)
        return rect.size
    }
    func valueFromAngle()-> CGFloat{
        if angle < 0{
            currentValue = CGFloat(-angle)
        }else{
            currentValue = CGFloat(270-angle+90)
        }
        fixedAngle = Int(currentValue)
        return currentValue*(maximumValue-minimumValue)/360
    }
    func moveHandle(_ point:CGPoint){
        let center = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        let currentAngle = floor(angleFromNorth(center, point, false))
        angle = 360-90-Int(currentAngle)
        currentValue = valueFromAngle()
        setNeedsDisplay()
    }
}
