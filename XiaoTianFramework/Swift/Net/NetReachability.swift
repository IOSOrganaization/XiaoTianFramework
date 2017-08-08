//
//  NetReachability.swift
//  XiaoTianFramework
//
//  Created by guotianrui on 2017/8/8.
//  Copyright © 2017年 XiaoTian. All rights reserved.
//

import Foundation
import SystemConfiguration
// 全局常量
let NetReachability_Name_NetworkDidChange = "NetReachability_NotificationName_NetworkDidChange"

public class NetReachability:NSObject{
    public enum Status{ case wifi, wwan, not}
    private var networkReachability: SCNetworkReachability?
    private var notifying = false
    // SC Network Flags
    private var flags: SCNetworkReachabilityFlags{
        var flags = SCNetworkReachabilityFlags(rawValue: 0)
        if let reachability = networkReachability, withUnsafeMutablePointer(to: &flags, {
            SCNetworkReachabilityGetFlags(reachability, UnsafeMutablePointer($0))
        }) == true{
            return flags
        }else{
            return []
        }
    }
    // 当前连接状态
    public var currentReachabilityStatus:Status{
        if flags.contains(.reachable) == false{
            // The target host is not reachable.
            return .not
        }else if flags.contains(.isWWAN) == true{
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .wwan
        }else if flags.contains(.connectionRequired) == false{
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .wifi
        }else if flags.contains([.connectionOnDemand]) == true || flags.contains(.connectionOnTraffic) == true && flags.contains(.interventionRequired) == false{
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .wifi
        }else{
            return .not
        }
    }
    // 是否可连接
    public var isReachable:Bool{
        switch currentReachabilityStatus {
        case .not:
            return false
        case .wifi,.wwan:
            return true
        }
    }
    /// 通过域名初始化,域名没意义
    public init?(hostName:String) {
        networkReachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, (hostName as NSString).utf8String!)
        super.init()
        if networkReachability == nil{
            return nil
        }
    }
    /// 通过IP初始化,IP没意义
    public init?(hostAddress:sockaddr_in){
        //var ip = sockaddr_in()
        //ip.sin_len = UInt8(MemoryLayout.size(ofValue: ip))
        //ip.sin_family = sa_family_t(AF_INET)
        //IP转换为十六进制: 192.168.0.1 -> 0xC0A80001
        //ip.sin_addr.s_addr = 0xC0A80001
        var address = hostAddress
        guard let defaultRouteReachability = withUnsafePointer(to: &address, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, $0)
            }
        })else{
            return nil
        }
        networkReachability = defaultRouteReachability
        super.init()
        if networkReachability == nil{
            return nil
        }
    }
    /// 网络连接初始化
    public static func networkReachabilityForInternetConnection() -> NetReachability?{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        return NetReachability(hostAddress: zeroAddress)
    }
    /// WiFi连接初始化
    public static func networkReachabilityForLocalWiFi() -> NetReachability?{
        var localWifiAddress = sockaddr_in()
        localWifiAddress.sin_len = UInt8(MemoryLayout.size(ofValue: localWifiAddress))
        localWifiAddress.sin_family = sa_family_t(AF_INET)
        // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0 (0xA9FE0000).
        localWifiAddress.sin_addr.s_addr = 0xA9FE0000
        return NetReachability(hostAddress: localWifiAddress)
    }
    /// 开始侦听网络侦听
    @discardableResult
    public func startNotifier()-> Bool{
        guard notifying == false else {
            return false
        }
        // Notification Context
        var context = SCNetworkReachabilityContext()
        context.info = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()) // self -> UnsafeMutableRawPointer
        guard let reachability = networkReachability, SCNetworkReachabilitySetCallback(reachability, { (target, flags, context) in
            // 网络状态侦听回调
            if let currentInfo = context{
                // UnsafeMutablePointer<SCNetworkReachabilityContext>? -> self
                if let networkReachability = Unmanaged<AnyObject>.fromOpaque(currentInfo).takeUnretainedValue() as? NetReachability{
                    NotificationCenter.default.post(name: NetReachability.NetworkDidChangeName, object: networkReachability) // object transform current
                }
            }
        }, &context) else{
            return false
        }
        // SC Network Chanage Schedule
        guard SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue) == true else{
            return false
        }
        notifying = true
        return notifying
    }
    /// 停止侦听网络侦听
    public func stopNotifier(){
        if let reachability = networkReachability, notifying == true{
            // SC Network Chanage Un Schedule
            SCNetworkReachabilityUnscheduleFromRunLoop(reachability, CFRunLoopGetCurrent(), CFRunLoopMode.defaultMode.rawValue)
            notifying = false
        }
    }
    deinit {
        stopNotifier()
    }
    /// 网络状态改变侦听Name
    public static let NetworkDidChangeName = Notification.Name(rawValue: NetReachability_Name_NetworkDidChange)
}
