
//
//  HttpAsync.swift
//  DriftBook
//  网络异步任务
//  Created by XiaoTian on 16/7/2.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

class HttpAsyncTask : NSObject {
    static let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    
    // 发起异步请求
    static func execute(params: NSDictionary?, doInBackground:(params: NSDictionary?) -> HttpResponse, onPostExecute: ((params: HttpResponse) -> Void)! = nil, onPreExecute: (() -> Void)! = nil) -> Void{
        // 系统并发多线程调度处理器
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // 执行异步任务前
            if onPreExecute != nil{
                dispatch_async(dispatch_get_main_queue()) {
                    onPreExecute()
                }
            }
            // 执行异步任务
            let response = doInBackground(params: params)
            // 执行异步任务结束
            if onPostExecute != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    onPostExecute(params:response)
                }
            }
        }
    }
    //
    static func execute(params: NSDictionary?, doInBackground:(params: NSDictionary?)->HttpResponse, onPostExecute: ((params: HttpResponse) -> Void)! = nil){
        // 系统并发多线程调度处理器
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // 执行异步任务
            let response = doInBackground(params: params)
            // 执行异步任务结束
            dispatch_async(dispatch_get_main_queue()) {
                onPostExecute(params:response)
            }
        }
    }
    //
    static func execute(params: NSDictionary?, doInBackground:(params: NSDictionary?)->HttpResponse){
        // 系统并发多线程调度处理器
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // 执行异步任务
            doInBackground(params: params)
        }
    }
}