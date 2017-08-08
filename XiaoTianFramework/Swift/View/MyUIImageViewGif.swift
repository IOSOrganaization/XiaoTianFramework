//
//  MyUIImageViewGif.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/7/28.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
import ImageIO
import MobileCoreServices

public class MyUIImageViewGif: UIImageView{
    var currentFrameIndex = 0// 当前位置
    var loopCountdown:Int = 0// 到计数器
    var currentFrame:UIImage?// 当前显示图片
    var displayLink:CADisplayLink?// CA显示链表,用于不停改变currentFrame的当前图片值
    var accumulator:TimeInterval = 0// 步进时间累加
    var kMaxTimeStep:TimeInterval = 1// 最大步进时间
    var animatedImage:UIImageGif?{
        didSet{
            if animatedImage == nil{
                layer.contents = nil
            }
        }
    }
    var runLoopMode = RunLoopMode.commonModes {
        didSet{
            if oldValue != runLoopMode{
                stopAnimating()
                displayLink?.remove(from: RunLoop.main, forMode: oldValue)//移除动画
                displayLink?.add(to: RunLoop.main, forMode: runLoopMode)//开始动画
                startAnimating()
            }
        }
    }
    /// 设置为UIImageGif图片则自动开始轮播
    public override var image: UIImage?{
        didSet{
            if oldValue == image{
                return
            }
            stopAnimating()
            currentFrameIndex = 0
            loopCountdown = 0
            accumulator = 0
            // 不是GIF图片或GIF只有一张图
            let imageGif = image as? UIImageGif
            if imageGif == nil || imageGif!.imagesGif.isEmpty{
                animatedImage = nil
                super.image = image
                layer.setNeedsDisplay()
                return
            }
            // 赋值第一张
            if let image = imageGif?.imagesGif[0]{
                super.image = image
            }else{
                super.image = nil
            }
            currentFrame = nil
            animatedImage = imageGif
            loopCountdown = animatedImage?.loopCount ?? Int.max
            startAnimating()
            layer.setNeedsDisplay()
        }
    }
    // 根据currentFrame刷新layer
    public override func display(_ layer: CALayer) {
        if animatedImage?.imagesGif.count ?? 0 == 0{
            return
        }
        // 显示当前图片
        if currentFrame != nil{
            layer.contents = currentFrame?.cgImage
        }
    }
    /// Move to window
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil{
            // window不存在,异步延时停止
            DispatchQueue.main.async {[weak self] in
                if self?.window == nil{
                    self?.stopAnimating()
                }
            }
        }else{
            startAnimating()
        }
    }
    // Move to super
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview == nil{
            //Doesn't have superview, let's check later if we need to remove the displayLink
            DispatchQueue.main.async {[weak self] in
                let _ = self?.createAndRunDisplayLink()
            }
        }else{
            // Has a superview, make sure it has a displayLink
            let _ = createAndRunDisplayLink()
        }
    }
    public override var isAnimating: Bool{
        return super.isAnimating || (displayLink != nil && !displayLink!.isPaused)
    }
    // 开始轮播
    public override func startAnimating() {
        if animatedImage == nil{
            super.startAnimating()
            return
        }
        if isAnimating{
            return
        }
        loopCountdown = animatedImage?.loopCount ?? Int.max
        displayLink?.isPaused = false
    }
    // 停止
    public override func stopAnimating() {
        if animatedImage == nil{
            super.stopAnimating()
            return
        }
        loopCountdown = 0
        displayLink?.isPaused = true
    }
    func createAndRunDisplayLink()-> CADisplayLink?{
        if superview != nil{
            if displayLink == nil && animatedImage != nil{
                displayLink = CADisplayLink(target: self, selector: #selector(changeKeyframe(_:)))// 创建显示链表动画
                displayLink?.add(to: RunLoop.main, forMode: self.runLoopMode)// 启动连接动画
            }
        }else{
            // 关闭链表动画,销毁
            displayLink?.invalidate()
            displayLink = nil
        }
        return displayLink
    }
    // 链表动画步进
    func changeKeyframe(_ displayLink:CADisplayLink){
        if let animatedImage = animatedImage{
            if currentFrameIndex >= animatedImage.imagesGif.count{
                return
            }
            accumulator += min(displayLink.duration, kMaxTimeStep)
            while accumulator >= animatedImage.frameDurations[currentFrameIndex] {
                accumulator -= animatedImage.frameDurations[currentFrameIndex]
                currentFrameIndex += 1
                if currentFrameIndex >= animatedImage.imagesGif.count{
                    // 0: 重复
                    loopCountdown -= 1
                    if loopCountdown == 0{
                        stopAnimating()
                        return
                    }
                    currentFrameIndex = 0
                }
                // 修改当前图片
                currentFrameIndex = min(currentFrameIndex, animatedImage.imagesGif.count - 1)
                currentFrame = animatedImage.getFrameWithIndex(currentFrameIndex)
                layer.setNeedsDisplay()//刷新UI,调用display方法重新赋值image
            }
        }
    }
    public func setHighLoghted(highlighted:Bool){
        if animatedImage != nil{
            super.isHighlighted = true
        }
    }
    // Gif UIImage
    public class UIImageGif:UIImage{
        var imagesGif:[UIImage?] = []
        var frameDurations:[TimeInterval] = []
        var totalDuration:TimeInterval = 0
        var loopCount = Int.max
        var imageSource:CGImageSource?
        var incrementalSource:CGImageSource?
        var readFrameQueue:DispatchQueue?
        var prefetchedNum = 10
        var imageScale:CGFloat = 1
        
        /// init Local Gif file
        public convenience init(name: String?){ //Main Bundle gif Name
            self.init(path: Bundle.main.path(forResource: name, ofType: "gif"))
        }
        public convenience init(path: String?){ //File Path
            self.init(data: path == nil ? nil : NSData(contentsOfFile: path!), scale:1)
        }
        @nonobjc
        public convenience init(data:NSData?, scale:CGFloat = 1){ //Data
            if let data = data{
                let imageSource = CGImageSourceCreateWithData(data, nil)
                if UIImageGif.imageSourceContainsAnimatedGif(imageSource){
                    self.init(imageSource: imageSource, scale: scale)
                }else{
                    self.init(data: data, scale: scale)
                }
            }else{
                self.init()
            }
        }
        public convenience init(imageSource:CGImageSource?, scale:CGFloat){//CGImageSource
            self.init()
            if let imageSource = imageSource{
                let numberOfFrames = CGImageSourceGetCount(imageSource)//Count
                let imageProperties = CGImageSourceCopyProperties(imageSource, nil) as? [String: Any]//Property
                let gifProperties = imageProperties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]//Gif Property
                loopCount = gifProperties?[kCGImagePropertyGIFLoopCount as String] as? Int ?? Int.max//Looper
                for index in 0 ..< numberOfFrames{
                    imagesGif.append(nil)
                    let frameDuration = UIImageGif.imageSourceGetGifFrameDelay(imageSource, index)
                    frameDurations.append(frameDuration)
                    self.totalDuration += frameDuration
                }
                // 预加载GIF前面几张图片
                let num = min(prefetchedNum, numberOfFrames)
                for index in 0 ..< num {
                    let image = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
                    imagesGif[index] = image == nil ? nil : UIImage(cgImage: image!)
                }
                self.imageScale = scale
                self.imageSource = imageSource
                self.readFrameQueue = DispatchQueue(label: "com.xiaotianframework.gifreadframe")
            }
        }
        func getFrameWithIndex(_ index:Int)-> UIImage?{
            var frame:UIImage?
            // sync target
            objc_sync_enter(imagesGif)
                frame = imagesGif[index]
            objc_sync_exit(imagesGif)
            // 图片为空,重新从图片源获取
            if frame == nil && imageSource != nil{
                if let image = CGImageSourceCreateImageAtIndex(imageSource!, index, nil){
                    frame = UIImage(cgImage: image, scale: scale, orientation: UIImageOrientation.up)
                }
            }
            // 预加载GIF后面几张图片(每次预加载几张)
            if imagesGif.count > prefetchedNum{
                if index != 0{
                    imagesGif[index] = nil
                }
                let nextReadIndex = index + prefetchedNum
                for i in index+1 ..< nextReadIndex{
                    let _index = i % imagesGif.count// 0~count looper
                    // 如果图片为空,则从数据源加载
                    if imagesGif[_index] == nil{
                        readFrameQueue?.async {[weak self] in
                            guard let wSelf = self else{
                                return
                            }
                            guard let imageSource = wSelf.imageSource else{
                                return
                            }
                            if let image = CGImageSourceCreateImageAtIndex(imageSource, _index, nil){
                                // sync target
                                objc_sync_enter(wSelf.imagesGif)
                                    wSelf.imagesGif[_index] = UIImage(cgImage: image, scale: wSelf.scale, orientation: UIImageOrientation.up)
                                objc_sync_exit(wSelf.imagesGif)
                            }
                        }
                    }
                }
            }
            return frame
        }
        //@inline:编译器是否自动把func的代码嵌入到调用func中而不是调用地址(never:从不嵌入,__always:永远嵌入代码而不是调用地址call)
        //use @inline(never) if your function is quite long and you want to avoid increasing your code segment size (use @inline(never))
        //use @inline(__always) if your function is rather small and you would prefer your app ran faster (note: it doesn't make that much of a differenence really)
        //don't use this keyword if you don't know what inlining of code actually means. read this first.
        @inline(never) static func imageSourceContainsAnimatedGif(_ imageSource:CGImageSource?)-> Bool{
            if let imageSource = imageSource{
                // (Type == GIF & Count > 1) -> GIF Animated
                return UTTypeConformsTo(CGImageSourceGetType(imageSource) ?? kUTTypeImage, kUTTypeGIF) && CGImageSourceGetCount(imageSource) > 1
            }
            return false
        }
        // 获取指定index的duration时间
        @inline(never) static func imageSourceGetGifFrameDelay(_ imageSource:CGImageSource,_ index:Int)-> TimeInterval{
            var frameDuration:TimeInterval = 0
            if let theImageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, nil) as? [String: Any]{
                if let gifProperties = theImageProperties[kCGImagePropertyGIFDictionary as String] as? [String: Any]{ // gif property
                    if let duration = gifProperties[kCGImagePropertyGIFUnclampedDelayTime as String] as? TimeInterval{
                        frameDuration = duration
                    }
                    if frameDuration <= 0{
                        if let duration = gifProperties[kCGImagePropertyGIFDelayTime as String] as? TimeInterval{
                            frameDuration = duration
                        }
                    }
                }
            }
            #if !OLExactGIFRepresentation
                if frameDuration < Double(0.02 - Float.ulpOfOne){
                    frameDuration = 0.1
                }
            #endif
            return frameDuration
        }
    }
}
