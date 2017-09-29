//
//  MyStoreHouseRefreshControl(CBStoreHouseRefreshControl)修改plist格式{start point},{end point}
//  XiaoTianFramework
//  下拉合成,下拉渐出刷新动画
//  Created by guotianrui on 2017/6/28.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
// 1.通过IB生成预览图模式可以在XCode里面方便创建Path的List列表

open class MyStoreHouseRefreshControl: UIView{
    static let krelativeHeightFactor:CGFloat = 2.0/5.0
    public static let STATE_IDLE = 0
    public static let STATE_REFRESHING = 1
    public static let STATE_DISAPPEARING = 2
    
    var scrollView:UIScrollView!
    var target:AnyObject!
    var action:Selector!
    var plist:String!
    var color:UIColor!
    var lineWidth:CGFloat!
    var dropHeight:CGFloat!
    var horizontalRandomness:CGFloat! // 横向出现动画的最大范围
    var internalAnimationFactor:CGFloat!//进入出现动画因数
    var reverseAnimationLoading:Bool!//反向加载中动画
    var originalTopContentInset:CGFloat!//缓冲下拉前原来的Top Content Inser
    private var state: Int = STATE_IDLE
    private var barItems:[BarItem] = []
    private var displayLink:CADisplayLink?
    private var disappearProgress:CGFloat!
    
    /// Attach To ScrollView(Any Sub ScrollView)
    @discardableResult
    public static func attachToScrollView(_ scrollView:UIScrollView,_ target:AnyObject,_ refreshAction:Selector,_ plist:String,color:UIColor = UIColor.gray,lineWidth:CGFloat = 2,dropHeight:CGFloat = 80,scale:CGFloat = 1,horizontalRandomness:CGFloat = 150,reverseAnimationLoading:Bool = false,internalAnimationFactor:CGFloat = 0.7) -> MyStoreHouseRefreshControl{
        let refreshControl = MyStoreHouseRefreshControl()
        refreshControl.scrollView = scrollView
        refreshControl.target = target
        refreshControl.action = refreshAction
        refreshControl.plist = plist
        refreshControl.color = color
        refreshControl.lineWidth = lineWidth
        refreshControl.dropHeight = dropHeight
        refreshControl.horizontalRandomness = horizontalRandomness
        refreshControl.reverseAnimationLoading = reverseAnimationLoading
        refreshControl.internalAnimationFactor = internalAnimationFactor
        refreshControl.originalTopContentInset = 0
        scrollView.addSubview(refreshControl)
        //
        var width:CGFloat = 0
        var height:CGFloat = 0
        let plistPoints = NSArray(contentsOfFile: Bundle.main.path(forResource: plist, ofType: "plist")!)
        var barItemPoints:[Points] = []
        do{
            let regexPoint = try NSRegularExpression(pattern: "\\{(\\d|,|\\.)+?\\}", options: .caseInsensitive)
            for points in plistPoints!{
                if let startEndPoint = points as? String {
                    let matchedResult = regexPoint.matches(in: startEndPoint, options: .reportProgress, range: NSMakeRange(0, startEndPoint.characters.count))
                    if matchedResult.count == 2{
                        let start = matchedResult[0].range
                        let end = matchedResult[1].range
                        var startRange = startEndPoint.index(startEndPoint.startIndex, offsetBy: start.location)
                        var endRange = startEndPoint.index(startRange, offsetBy: start.length)
                        let startPoint = CGPointFromString(startEndPoint.substring(with: startRange..<endRange))
                        startRange = startEndPoint.index(startEndPoint.startIndex, offsetBy: end.location)
                        endRange = startEndPoint.index(startRange, offsetBy: end.length)
                        let endPoint = CGPointFromString(startEndPoint.substring(with: startRange..<endRange))
                        // 最大值
                        if startPoint.x > width {
                            width = startPoint.x
                        }
                        if endPoint.x > width {
                            width = endPoint.x
                        }
                        if startPoint.y > height {
                            height = startPoint.y
                        }
                        if endPoint.y > height {
                            height = endPoint.y
                        }
                        barItemPoints.append(Points(startPoint,endPoint))
                    }
                }
            }
        }catch{
            Mylog.log(error)
            return refreshControl
        }
        // 线宽
        width += lineWidth * 2
        height += lineWidth * 2
        refreshControl.frame = CGRect(x: 0, y: 0, width: width, height: height)
        for (index, points) in barItemPoints.enumerated(){
            let barItem = BarItem(refreshControl.frame, points, color, lineWidth, index)
            refreshControl.addSubview(barItem)
            refreshControl.barItems.append(barItem)
            barItem.setHorizontalRandomness(refreshControl.horizontalRandomness, refreshControl.dropHeight)
        }
        refreshControl.center = CGPoint(x:UIScreen.main.bounds.size.width/2.0, y:0)
        for barItem in refreshControl.barItems{
            barItem.setupWithFrame(refreshControl.frame)
        }
        refreshControl.transform = CGAffineTransform(scaleX: scale, y: scale)
        // KVO 侦听插入头内容,滚动,手指状态[不需要Delegate回调,比较装逼,实际功能一样]
        scrollView.addObserver(refreshControl, forKeyPath: "contentInset", context: nil)// ScrollView Top Content Inser
        scrollView.addObserver(refreshControl, forKeyPath: "contentOffset", context: nil)// ScrollView Offset Change
        scrollView.addObserver(refreshControl, forKeyPath: "pan.state",options: .new, context: nil)// Touch State Change
        return refreshControl
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        scrollViewDidAppear()
    }
    
    // UIScrollView Delegate
    public func scrollViewDidAppear(){
        if originalTopContentInset == 0{
            originalTopContentInset = scrollView.contentInset.top
        }
    }
    /// 滚动回调
    public func scrollViewDidScroll(){
        center = CGPoint(x: UIScreen.main.bounds.size.width/2, y: realContentOffsetY * MyStoreHouseRefreshControl.krelativeHeightFactor)
        if state == MyStoreHouseRefreshControl.STATE_IDLE{
            updateBarItemsWithProgress(progress: animationProgress)
        }
    }
    /// 放手回调
    public func scrollViewDidEndDragging(){
        if state == MyStoreHouseRefreshControl.STATE_IDLE && realContentOffsetY < dropHeight{
            if animationProgress == 1{
                state = MyStoreHouseRefreshControl.STATE_REFRESHING
            }
            if state == MyStoreHouseRefreshControl.STATE_REFRESHING{
                // ScrollView 插入头部下拉高度
                var newInsets = scrollView.contentInset
                newInsets.top = originalTopContentInset + dropHeight
                let contentOffset = scrollView.contentOffset
                scrollView.removeObserver(self, forKeyPath: "contentInset")
                UIView.animate(withDuration: 0, animations: { [weak self] in
                    self?.scrollView.contentInset = newInsets
                    self?.scrollView.contentOffset = contentOffset
                }, completion:{ [weak self] (finished) in
                        if let wSelf = self {
                            wSelf.scrollView.addObserver(wSelf, forKeyPath: "contentInset", context: nil)
                        }
                })
                // 执行加载Selector
                let _ = target?.perform(action, with: self)
                startLoadingAnimation()
            }
        }
    }
    private func updateBarItemsWithProgress(progress:CGFloat){
        for (index, barItem) in barItems.enumerated(){
            let startPadding:CGFloat = (1.0 - internalAnimationFactor) / CGFloat(barItems.count) * CGFloat(index)
            let endPadding:CGFloat = 1.0 - internalAnimationFactor - startPadding
            if progress == 1 || progress >= 1 - endPadding{
                barItem.transform = .identity // 重置Transform状态
                barItem.alpha = 0.8
            }else if progress == 0{
                barItem.setHorizontalRandomness(horizontalRandomness, dropHeight)
            }else{
                var realProgress:CGFloat = 0
                if progress <= startPadding{
                    realProgress = 0
                }else{
                    realProgress = CGFloat.minimum(1, (progress - startPadding) / internalAnimationFactor)
                }
                // 移动,旋转,放大
                barItem.transform = CGAffineTransform(translationX: barItem.translationX * (1 - realProgress), y: -dropHeight * (1.0 - realProgress)).rotated(by: CGFloat(Double.pi) * realProgress).scaledBy(x: realProgress, y: realProgress)
                barItem.alpha = realProgress *  0.8
            }
        }
    }
    private func startLoadingAnimation(){
        // 循环改每个Item的透明度,达到动态效果
        if reverseAnimationLoading{
            for (index,barItem) in barItems.enumerated().reversed(){
                let delay:TimeInterval = Double(barItems.count - index - 1) * 0.1
                perform(#selector(barItemAnimation(_:)), with: barItem, afterDelay: delay, inModes: [.commonModes])
            }
        }else{
            for (index,barItem) in barItems.enumerated(){
                let delay:TimeInterval = Double(index) * 0.1
                perform(#selector(barItemAnimation(_:)), with: barItem, afterDelay: delay, inModes: [.commonModes])
            }
        }
    }
    @objc(barItemAnimation:)
    private func barItemAnimation(_ barItem:BarItem){
        if  state == MyStoreHouseRefreshControl.STATE_REFRESHING {
            barItem.alpha = 1
            barItem.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.8, animations: {
                barItem.alpha = 0
            }, completion: { (finished) in
                UIView.animate(withDuration: 0.8, animations: {
                    barItem.alpha = 1
                })
            })
            // 如果是最后一个,重新开始
            var isLastOne = false
            if reverseAnimationLoading{
                isLastOne = barItem.tag == 0
            }else{
                isLastOne = barItem.tag == barItems.count - 1
            }
            if isLastOne && state == MyStoreHouseRefreshControl.STATE_REFRESHING{
                startLoadingAnimation()
            }
        }
    }
    public func finishingLoading(){
        if state == MyStoreHouseRefreshControl.STATE_REFRESHING{
            state = MyStoreHouseRefreshControl.STATE_DISAPPEARING
            scrollView.removeObserver(self, forKeyPath: "contentInset")
            var newInsets = scrollView.contentInset
            newInsets.top = originalTopContentInset
            UIView.animate(withDuration: 1.2, animations: { [weak self] in
                self?.scrollView.contentInset = newInsets
            },completion:{ [weak self] (finished) in
                guard let wSelf = self else{
                    return
                }
                wSelf.state = MyStoreHouseRefreshControl.STATE_IDLE
                wSelf.displayLink?.invalidate()
                wSelf.disappearProgress = 1
                wSelf.scrollView.addObserver(wSelf, forKeyPath: "contentInset", context: nil)
            })
            for barItem in barItems{
                barItem.layer.removeAllAnimations()
                barItem.alpha = 0.8
            }
            displayLink = CADisplayLink(target: self, selector: #selector(updateDisappearAnimation))
            displayLink?.add(to: RunLoop.main, forMode: .commonModes)
            disappearProgress = 1
        }
    }
    func updateDisappearAnimation(){
        if let progress = disappearProgress{
            if progress >= 0 && progress <= 1{
                disappearProgress = disappearProgress - CGFloat(1.0/60.0 / 1.2)
                //60.f means this method get called 60 times per second
                updateBarItemsWithProgress(progress: disappearProgress)
            }
        }
    }
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath! {
        case "contentInset":
            scrollViewDidAppear()
            break
        case "contentOffset":
            scrollViewDidScroll()
            break
        case "pan.state":
            if let state = change?[NSKeyValueChangeKey.newKey] as? Int{
                if state == UIGestureRecognizerState.ended.rawValue {
                    scrollViewDidEndDragging()
                }
            }
            break
        default:
            break
        }
    }
    
    var animationProgress:CGFloat{
        // 放手时触发: 0~1
        return CGFloat(Float.minimum(1.0, Float.maximum(0, fabsf(Float(realContentOffsetY / dropHeight)))))
    }
    // Y 方向内容间距
    var realContentOffsetY:CGFloat{
        get{
            if scrollView.contentOffset.y + originalTopContentInset > 0{
                if self.alpha != 0 {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {[weak self] in
                        self?.alpha = 0
                    })
                }
            }else{
                if self.alpha != 1 {
                    UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {[weak self] in
                        self?.alpha = 1
                    })
                }
            }
            return scrollView.contentOffset.y + originalTopContentInset
        }
    }
    deinit {
        scrollView.removeObserver(self, forKeyPath: "contentInset")
        scrollView.removeObserver(self, forKeyPath: "contentOffset")
        scrollView.removeObserver(self, forKeyPath: "pan.state")
    }
    // 一条线一个BarItem
    fileprivate class BarItem: UIView{
        var points: Points!
        var color:UIColor!
        var lineWidth:CGFloat!
        var middlePoint:CGPoint!
        var translationX:CGFloat!
        
        convenience init(_ frame: CGRect,_ points:Points,_ color:UIColor,_ lineWidth:CGFloat,_ index:Int) {
            self.init(frame: frame)
            self.color = color
            self.points = points
            self.lineWidth = lineWidth
            let centerX = (points.startPoint.x + points.endPoint.x)/2.0
            let centerY = (points.startPoint.y + points.endPoint.y)/2.0
            self.middlePoint = CGPoint(x:centerX, y:centerY)
            self.alpha = 0
            self.tag = index
            self.backgroundColor = UIColor.clear
        }
        func setupWithFrame(_ rect:CGRect){
            layer.anchorPoint = CGPoint(x: middlePoint.x/frame.size.width, y: middlePoint.y/frame.size.height)
            let x = frame.origin.x + middlePoint.x - frame.size.width / 2.0
            let y = frame.origin.y + middlePoint.y - frame.size.height / 2.0
            frame = CGRect(x: x, y: y, width: frame.size.width, height: frame.size.height)
        }
        func setHorizontalRandomness(_ random:CGFloat,_ dropHeight:CGFloat){
            let randomNumber = arc4random() % UInt32(random) * 2
            translationX = -random + CGFloat(randomNumber)
            transform = CGAffineTransform(translationX: CGFloat(translationX), y: -dropHeight)
        }
        override func draw(_ rect: CGRect) {
            let bezierPath = UIBezierPath()
            bezierPath.move(to: points.startPoint)
            bezierPath.addLine(to: points.endPoint)
            color.setStroke()
            bezierPath.lineWidth = lineWidth
            bezierPath.stroke()
        }
    }
    fileprivate class Points{
        var endPoint:CGPoint!
        var startPoint:CGPoint!
        
        init(_ endPoint:CGPoint,_ startPoint:CGPoint) {
            self.endPoint = endPoint
            self.startPoint = startPoint
        }
    }
}
/// 用于画图预览 UIView
@IBDesignable
public class MyStoreHouseRefreshControlIBDrawableView: UIView{
    // 把View加到Xib中,直接在下面方法可以画图了
    // 快捷键: Comment+Alt++ 刷新Xib页面
    public override func draw(_ rect: CGRect) {
        // 开始画吧
        drawLine("{0,0}{10,10}")
        drawLine("{2,9}{7,15}")
    }
    // 便捷划线😘
    // 预览画线
    let color:UIColor = UIColor.black
    let lineWidth:CGFloat = 2
    @nonobjc
    func drawLine(_ startEndPoint:String){ // {0,0}{1,1}
        let matchedResult = regexPoint.matches(in: startEndPoint, options: .reportProgress, range: NSMakeRange(0, startEndPoint.characters.count))
        if matchedResult.count == 2{
            let start = matchedResult[0].range
            let end = matchedResult[1].range
            var startRange = startEndPoint.index(startEndPoint.startIndex, offsetBy: start.location)
            var endRange = startEndPoint.index(startRange, offsetBy: start.length)
            let startPoint = CGPointFromString(startEndPoint.substring(with: startRange..<endRange))
            startRange = startEndPoint.index(startEndPoint.startIndex, offsetBy: end.location)
            endRange = startEndPoint.index(startRange, offsetBy: end.length)
            let endPoint = CGPointFromString(startEndPoint.substring(with: startRange..<endRange))
            drawLine(startPoint.x,startPoint.y,endPoint.x,endPoint.y)
        }
    }
    func drawLine(_ startX:CGFloat,_ startY:CGFloat,_ endX:CGFloat,_ endY:CGFloat){ // 0,0,1,1
        color.setStroke()
        let path = UIBezierPath()
        path.move(to: CGPoint(x:startX, y:startY))
        path.addLine(to: CGPoint(x:endX, y:endY))
        path.lineWidth = lineWidth
        path.stroke()
    }
    public override func prepareForInterfaceBuilder() {
        // 设置预览属性,在这里
        let borderColor:CGColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        self.layer.borderColor = borderColor
        self.layer.borderWidth = 0.5
    }
    var _regexPoint:NSRegularExpression!
    @nonobjc
    var regexPoint: NSRegularExpression{
        get{
            if _regexPoint != nil{
                return _regexPoint
            }
            do{
                _regexPoint = try NSRegularExpression(pattern: "\\{(\\d|,|\\.)+?\\}", options: .caseInsensitive)
            }catch{}
            return _regexPoint
        }
    }
}
