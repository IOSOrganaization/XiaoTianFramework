//
//  Util.swift
//  DriftBook
//  Swift Util 工具类
//  Created by XiaoTian on 16/7/4.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

class UtilSwift: NSObject {
    
    /// 封装请求图片的URL
    func wrapRequestUrlImage(path:String) -> String{
        return "\(ConstantNet.HTTP_SERVER):\(ConstantNet.HTTP_PORT_IMAGE)\(path)"
    }
    //
    func stringAppName() -> String{
        return localizedString("APP Name")
    }
    //
    func localizedString(key:String) -> String{
        return NSLocalizedString(key, comment:"");
    }
    
//    /// 全屏浏览图片[网络图片]
//    func browserImageArray(vc: UIViewController,_ imageName:[String]?, selectedIndex: Int = 0, originImage: UIImage? = nil , animatedFromView: UIView? = nil, delegate:SKPhotoBrowserDelegate? = nil){
//        if imageName == nil{
//            Mylog.log("全屏浏览图片 -> 无图片.")
//            return
//        }
//        var arraySKPhoto:[SKPhotoProtocol] = []
//        for imageName in imageName!{
//            let photo = SKPhoto.photoWithImageURL(wrapRequestUrlImage(imageName))
//            photo.shouldCachePhotoURLImage = true
//            arraySKPhoto.append(photo)
//        }
//        var vcImageBrowser:SKPhotoBrowser! = nil
//        if originImage != nil && animatedFromView != nil {
//            // 打开时放大动态效果
//            vcImageBrowser = SKPhotoBrowser(originImage: originImage!, photos: arraySKPhoto, animatedFromView: animatedFromView!)
//        } else {
//            // 打开时没效果
//            vcImageBrowser = SKPhotoBrowser(photos: arraySKPhoto)
//        }
//        if delegate != nil{
//            // 回调函数
//            vcImageBrowser.delegate = delegate
//        }
//        vcImageBrowser.initializePageIndex(selectedIndex)
//        vcImageBrowser.displayDeleteButton = false
//        vcImageBrowser.displayAction = false
//        vcImageBrowser.displayToolbar = true
//        vcImageBrowser.displayCloseButton = true
//        vc.navigationController?.presentViewController(vcImageBrowser, animated: true, completion: {})
//    }
//    /// 全屏浏览图片[本地图片]
//    func browserImageArrayUIImage(vc: UIViewController,_ images:[UIImage]?, selectedIndex: Int = 0, originImage: UIImage? = nil , animatedFromView: UIView? = nil, delegate:SKPhotoBrowserDelegate? = nil){
//        if images == nil{
//            Mylog.log("全屏浏览图片 -> 无图片.")
//            return
//        }
//        var arraySKPhoto:[SKPhotoProtocol] = []
//        for image in images!{
//            let photo = SKPhoto.photoWithImage(image)
//            photo.shouldCachePhotoURLImage = true
//            arraySKPhoto.append(photo)
//        }
//        var vcImageBrowser:SKPhotoBrowser! = nil
//        if originImage != nil && animatedFromView != nil {
//            // 打开时放大动态效果
//            vcImageBrowser = SKPhotoBrowser(originImage: originImage!, photos: arraySKPhoto, animatedFromView: animatedFromView!)
//        } else {
//            // 打开时没效果
//            vcImageBrowser = SKPhotoBrowser(photos: arraySKPhoto)
//        }
//        if delegate != nil{
//            // 回调函数
//            vcImageBrowser.delegate = delegate
//        }
//        vcImageBrowser.initializePageIndex(selectedIndex)
//        vcImageBrowser.displayDeleteButton = false
//        vcImageBrowser.displayAction = false
//        vcImageBrowser.displayToolbar = true
//        vcImageBrowser.displayCloseButton = true
//        vc.navigationController?.presentViewController(vcImageBrowser, animated: true, completion: {})
//    }
//    /// 全屏浏览图片[本地/网络图片]
//    func browserImageArraySKPhoto(vc: UIViewController,_ sKPhotos:[SKPhotoProtocol]?, selectedIndex: Int = 0, originImage: UIImage? = nil , animatedFromView: UIView? = nil, delegate:SKPhotoBrowserDelegate? = nil){
//        if sKPhotos == nil{
//            Mylog.log("全屏浏览图片 -> 无图片.")
//            return
//        }
//        var vcImageBrowser:SKPhotoBrowser! = nil
//        if originImage != nil && animatedFromView != nil {
//            // 打开时放大动态效果
//            vcImageBrowser = SKPhotoBrowser(originImage: originImage!, photos: sKPhotos!, animatedFromView: animatedFromView!)
//        } else {
//            // 打开时没效果
//            vcImageBrowser = SKPhotoBrowser(photos: sKPhotos!)
//        }
//        if delegate != nil{
//            // 回调函数
//            vcImageBrowser.delegate = delegate
//        }
//        vcImageBrowser.initializePageIndex(selectedIndex)
//        vcImageBrowser.displayDeleteButton = false
//        vcImageBrowser.displayAction = false
//        vcImageBrowser.displayToolbar = true
//        vcImageBrowser.displayCloseButton = true
//        vc.navigationController?.presentViewController(vcImageBrowser, animated: true, completion: {})
//    }
}