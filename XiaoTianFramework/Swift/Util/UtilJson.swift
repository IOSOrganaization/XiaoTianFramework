//
//  UtilJson.swift
//  XiaoTianFramework
//  Json 工具
//  Created by guotianrui on 2017/5/26.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation

open class UtilJson: XTFSerializerJson{
    // Type Support
    //  JSONObject -> NSDictionary
    //  JSONArray -> NSArray
    //  NSString, NSNumber, NSArray, NSDictionary, or NSNull
    //
    // 1.mutableContainers: JSONSerialization.ReadingOptions
    //  Specifies that arrays and dictionaries are created as mutable objects.
    // 2.mutableLeaves: JSONSerialization.ReadingOptions
    //  Specifies that leaf strings in the JSON object graph are created as instances of NSMutableString.
    // 3.allowFragments: JSONSerialization.ReadingOptions
    //  Specifies that the parser should allow top-level objects that are not an instance of NSArray or NSDictionary.
    //
}
