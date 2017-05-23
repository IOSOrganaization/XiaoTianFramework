
//
//  HttpAsync.swift
//  DriftBook
//  网络异步任务
//  Created by XiaoTian on 16/7/2.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation

class HttpAsyncTask : NSObject {
    
    // 发起异步请求
    static func execute(_ params: NSDictionary?, doInBackground:@escaping (_ params: NSDictionary?) -> HttpResponse, onPostExecute: ((_ params: HttpResponse) -> Void)! = nil, onPreExecute: (() -> Void)! = nil) -> Void{
        // 系统并发多线程调度处理器
        DispatchQueue.global(qos: .userInitiated).async{
            // 执行异步任务前
            if onPreExecute != nil{
                DispatchQueue.main.async {
                    onPreExecute()
                }
            }
            // 执行异步任务
            let response = doInBackground(params)
            // 执行异步任务结束
            if onPostExecute != nil {
                DispatchQueue.main.async {
                    onPostExecute(response)
                }
            }
        }
    }
    //
    static func execute(_ params: NSDictionary?, doInBackground:@escaping (_ params: NSDictionary?)->HttpResponse, onPostExecute: ((_ params: HttpResponse) -> Void)! = nil){
        // 系统并发多线程调度处理器
        DispatchQueue.global(qos: .userInitiated).async{
            // 执行异步任务
            let response = doInBackground(params)
            // 执行异步任务结束
            DispatchQueue.main.async {
                onPostExecute(response)
            }
        }
    }
    //
    static func execute(_ params: NSDictionary?, doInBackground:@escaping (_ params: NSDictionary?) -> HttpResponse){
        // 系统并发多线程调度处理器
        DispatchQueue.global(qos: .userInitiated).async{
            // 执行异步任务
            let _ = doInBackground(params)
        }
    }
}
