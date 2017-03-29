//
//  UtilFile.swift
//  DriftBook
//
//  Created by 郭天蕊 on 2016/12/21.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
class UtilFile: NSObject{
    /// 缓存图片目录
    var cacheImageFolder: String!{
        let dataPath = "\(NSHomeDirectory())/Library/appdata/cache_image"
        let fm = NSFileManager.defaultManager()
        if !fm.fileExistsAtPath(dataPath){
            do{
                try fm.createDirectoryAtPath(dataPath, withIntermediateDirectories: true,attributes: nil)
            }catch{
                Mylog.log("创建缓存图片目录失败.")
                return nil
            }
        }
        return dataPath
    }
    /// 主目录
    static var homeDirectory:String{
        return NSHomeDirectory()
    }
    /// 用户文档目录
    static var userDocumentDirectory:String {
       return NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
    }
    /// 临时目录
    static var temporaryDirectory:String{
        return NSTemporaryDirectory()
    }
    /// Wrap 目录
    static func wrapUserDocumentDirectory(pathParam: String) ->String{
        let doc = UtilFile.userDocumentDirectory
        return "\(doc)/\(pathParam)"
    }
    /// 创建目录
    static func createUserDocumentDirectory(folder: String) ->String?{
        let doc = UtilFile.userDocumentDirectory
        let path = "\(doc)/\(folder)"
        do{
            if NSFileManager.defaultManager().fileExistsAtPath(path){
                return path
            }
            try NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil)
        }catch{
            return nil
        }
        return path
    }
    /// 获取目录下的子文件
    static func getSubFileInPath(path: String) ->[String]?{
        let manager = NSFileManager.defaultManager()
        if let subPath = manager.subpathsAtPath(path){
            var files:[String] = []
            for sp in subPath{
                var isDirectory:ObjCBool = false
                if manager.fileExistsAtPath("\(path)/\(sp)", isDirectory: &isDirectory){
                    if !isDirectory{
                        // File
                        files.append(sp)
                    }
                }
            }
            return files
        }
        return nil
    }
    
}