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
        let fm = FileManager.default
        if !fm.fileExists(atPath: dataPath){
            do{
                try fm.createDirectory(atPath: dataPath, withIntermediateDirectories: true,attributes: nil)
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
       return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
    }
    /// 临时目录
    static var temporaryDirectory:String{
        return NSTemporaryDirectory()
    }
    /// Wrap 目录
    static func wrapUserDocumentDirectory(_ pathParam: String) ->String{
        let doc = UtilFile.userDocumentDirectory
        return "\(doc)/\(pathParam)"
    }
    /// 创建目录
    static func createUserDocumentDirectory(_ folder: String) ->String?{
        let doc = UtilFile.userDocumentDirectory
        let path = "\(doc)/\(folder)"
        do{
            if FileManager.default.fileExists(atPath: path){
                return path
            }
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }catch{
            return nil
        }
        return path
    }
    /// 获取目录下的子文件
    static func getSubFileInPath(_ path: String) ->[String]?{
        let manager = FileManager.default
        if let subPath = manager.subpaths(atPath: path){
            var files:[String] = []
            for sp in subPath{
                var isDirectory:ObjCBool = false
                if manager.fileExists(atPath: "\(path)/\(sp)", isDirectory: &isDirectory){
                    if !isDirectory.boolValue {
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
