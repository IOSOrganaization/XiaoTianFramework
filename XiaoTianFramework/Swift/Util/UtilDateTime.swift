//
//  UtilDateTime.swift
//  DriftBook
//  时间日期工具
//  Created by XiaoTian on 16/7/6.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
import UIKit

@objc(UtilDateTimeXT)
open class UtilDateTime: NSObject {
    open static let PATTERN_DATE = "yyyy年MM月dd日"
    open static let PATTERN_DATE_TIME = "yyyy年MM月dd日 HH:mm"
    open static let PATTERN_DATE_TIME_SECOND = "yyyy年MM月dd日 HH:mm:ss"
    open static let PATTERN_DATE_TIME_SECOND_MILLISE = "yyyy年MM月dd日 HH:mm:ss.SSS XXXXX" // 2017年05月26日 10:21:09.733 +08:00
    open static let PATTERN_DATE_TIME_LOCAL = "dMMMMyyyyhmmaz" // July 16, 2015, 7:44 AM PDT.
    private var cacheCurrentDate: Date?
    private static var preClickTimeInterval: TimeInterval = 0
    /// 格式化日期 (秒/s) [1990年1月1日]
    open func formatMillisecondDate(_ dateMillisecond: NSNumber?) -> String?{
        return formatMillisecond("yyyy年MM月dd日", dateMillisecond)
    }
    /// 格式化日期 (秒/s) [1月1日]
    open func formatMillisecondDateSimple(_ dateMillisecond: NSNumber?) -> String?{
        return formatMillisecond("MM月dd日", dateMillisecond)
    }
    /// 格式化日期时间 (秒/s) [1990年1月1日 23:36:50]
    open func formatMillisecondDateTime(_ dateMillisecond: NSNumber?) -> String?{
        return formatMillisecond("yyyy年MM月dd日 HH:mm:ss", dateMillisecond)
    }
    /// 格式化时间 (秒/s) [23:35:50]
    open func formatMillisecondTime(_ dateMillisecond: NSNumber?) -> String?{
        return formatMillisecond("HH:mm:ss", dateMillisecond)
    }
    
    /// 格式化为指定时间格式[yyyy:四位年,MM:月,dd:日,HH:时,mm:分,ss:秒,SSS:毫秒,Z:时区]
    open func formatMillisecond(_ pattern:String,_ dateMillisecond: NSNumber?) -> String?{
        if dateMillisecond == nil {
            return nil
        }
        // 时间格式化器
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern // 日期格式
        dateFormatter.timeZone = TimeZone.current // 默认时区[零时区: NSTimeZone(name: "UTC")]
        let timeInterval = dateMillisecond!.doubleValue / 1000.0  // 毫秒 -> 秒
        let date = Date(timeIntervalSince1970: timeInterval)
        return dateFormatter.string(from: date) // 格式化
    }
    /// 格式化为指定时间格式
    open func formatDateTime(_ pattern:String,_ date: Date?) -> String?{
        if date == nil {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: date!)
    }
    /// 时刻(无时区限制)
    open func formatFunnyDate(_ dateMillisecond: NSNumber?) -> String?{
        if dateMillisecond == nil {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        let date = Date(timeIntervalSince1970: TimeInterval(Double((dateMillisecond?.intValue)!) / 1000.0)) // GMT 时间
        //
        let dateNow =  Date()
        var calander = Calendar.current
        calander.locale = Locale.current
        calander.timeZone = TimeZone(identifier: "GMT")!
        // 10分钟之内,显示刚刚
        var minute = DateComponents()
        minute.minute = -10
        // options: OptionSetType(Option 集合类型,空: [] 或 OptionSetType(rawValue:0)))
        let minuteDate: Date! = (calander as NSCalendar).date(byAdding: minute, to: dateNow, options: [])
        // 10分钟之内,显示刚刚
        let minuteCompareResult = (calander as NSCalendar).compare(date, to: minuteDate, toUnitGranularity: .second)
        if minuteCompareResult == ComparisonResult.orderedDescending || minuteCompareResult == ComparisonResult.orderedSame { // date > minuteDate
            // toUnitGranularity: 日期需要进行比较的最小单位[年号,年,月,日,时,分,秒,微秒,周,周序号,月周,年周,日历组件...]
            return "刚刚"
        }
        // 一个小时内,显示多少分钟前
        var hour = DateComponents()
        hour.hour = -1
        let hourDate: Date! = (calander as NSCalendar).date(byAdding: hour, to: dateNow, options: [])
        let hourCompareResult = (calander as NSCalendar).compare(date, to: hourDate, toUnitGranularity: .second)
        if hourCompareResult == ComparisonResult.orderedDescending { // date > hourDate
            //let result = dateNow.minute - date.minute
            //return "\(result > 0 ? result : 60 + result)分钟前" // 跨过60分后从1开始[结果小于0], 其他结果大于0
            return "n分钟前"
        }
        // 今天内,显示几点几分
        let dayCompareResult = (calander as NSCalendar).compare(date, to: today, toUnitGranularity: .second)
        if dayCompareResult == ComparisonResult.orderedDescending || dayCompareResult == ComparisonResult.orderedSame{ // date > dayDate
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: date)
        }
        // 昨天显示昨天
        if (calander as NSCalendar).compare(date, to: yesterday, toUnitGranularity: .second) == .orderedDescending{
            return "昨天"
        }
        // 其他显示日期
        dateFormatter.dateFormat = "MM月dd日"
        return dateFormatter.string(from: date)
    }
    /// 转换格式化时间为毫秒[相距1970年时间] 格式为:[1990年1月1日]
    open func pasteStringMillisecond(_ date:String?) -> NSNumber?{
        return pasteFormatDateMillisecond("yyyy年MM月dd日", date)
    }
    /// 转换格式化时间为毫秒[相距1970年时间] 格式为:[1990年1月1日 23:36:50]
    open func pasteDateTimeMillisecond(_ date:String?) -> NSNumber?{
        return pasteFormatDateMillisecond("yyyy年MM月dd日 HH:mm:ss", date)
    }
    /// 转换格式化时间为毫秒[相距1970年时间] 格式为:[23:35:50]
    open func pasteTimeMillisecond(_ date:String?) -> NSNumber?{
        return pasteFormatDateMillisecond("HH:mm:ss", date)
    }
    /// 转换String格式化的时间为毫秒
    open func pasteFormatDateMillisecond(_ pattern:String,_ date:String?) -> NSNumber?{
        if let date = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = pattern
            dateFormatter.timeZone = TimeZone.current
            if let d = dateFormatter.date(from: date){
                return pasteDateMillisecond(d)
            }
        }
        return nil
    }
    /// 转换NSDate为毫秒
    open func pasteDateMillisecond(_ date:Date?) -> NSNumber?{
        if let date = date {
            let timeInterval: TimeInterval = date.timeIntervalSince1970 * 1000
            return NSNumber(value: timeInterval)
        }
        return nil
    }
    /// 转换格式化日期时间 格式为:[yyyy年MM月dd日 HH:mm:ss]
    open func pasteDateTime(_ dateTime:String?) -> Date?{
        return pasteDateTime("yyyy年MM月dd日 HH:mm:ss", dateTime)
    }
    /// 转换格式化日期 格式为:[yyyy年MM月dd日]
    open func pasteDate(_ date:String?) -> Date?{
        return pasteDateTime("yyyy年MM月dd日", date)
    }
    /// 转换格式化时间 格式为:[HH:mm:ss]
    open func pasteTime(_ time:String?) -> Date?{
        return pasteDateTime("HH:mm:ss", time)
    }
    /// 转换为指定格式化日期
    open func pasteDateTime(_ format:String,_ dateTime:String?) -> Date?{
        if let dateTime = dateTime {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format
            dateFormatter.timeZone = TimeZone.current
            return dateFormatter.date(from: dateTime)
        }
        return nil
    }
    /// 转换数字时间为 Date
    open func translateToDate(_ dateMillisecond: NSNumber?) -> Date?{
        if let dateMillisecond = dateMillisecond {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
            dateFormatter.timeZone = TimeZone.current
            let timeInterval: TimeInterval = dateMillisecond.doubleValue / 1000
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }
    /// 获取时间的中文周
    open func getChineseWeekDay(_ date: Date?) -> String?{
        if let date = date {
            let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            let myComponents = calendar.dateComponents([.weekday], from: date)
            if let weekDay = myComponents.weekday{
                switch weekDay {
                    case 1: return "周一"
                    case 2: return "周二"
                    case 3: return "周三"
                    case 4: return "周四"
                    case 5: return "周五"
                    case 6: return "周六"
                    case 7: return "周日"
                    default: return nil
                }
            }
        }
        return nil
    }
    /// 当前日期时间(当前时区时间[实质为重新设置 NSDate 时区])
    open var currentDate: Date{
        let currentDate = Date() // GMT 时间
        var calander = Calendar.current
        calander.locale = Locale.current
        calander.timeZone = TimeZone(identifier: "GMT")! // 设置 GMT 时区获取 NSDate 的时间
        //let unitFlag: NSCalendar.Unit = [NSCalendar.Unit.timeZone , NSCalendar.Unit.year , NSCalendar.Unit.month , NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.nanosecond]
        //let todayComponents = (calander as NSCalendar).components(unitFlag, from: currentDate) // Calander 根据 GMT 时区获取指定时间的组件
        //calander.dateComponents(unitFlag, from: currentDate)
        let unitSet:Set<Calendar.Component> = [.timeZone, .year, .month, .day, .hour, .minute, .second, .nanosecond]
        let todayComponents = calander.dateComponents(unitSet, from: currentDate)
        calander.timeZone = TimeZone.current // 转换为当前时区
        return calander.date(from: todayComponents)! // 当前时区的时间
    }
    /// 昨天(年月日0时0分0秒0微秒)
    open var yesterday: Date{
        var calander = Calendar.current
        calander.locale = Locale.current
        calander.timeZone = TimeZone.current
        //var dayAdd = DateComponents()
        //dayAdd.day = -1
        //return (calander as NSCalendar).date(byAdding: dayAdd, to: self.today, options:  NSCalendar.Options.wrapComponents)!
        return calander.date(byAdding: .day, value: -1, to: self.today)!
    }
    /// 今天(年月日0时0分0秒0微秒)
    open var today: Date{
        let currentDate = Date() // NSDate 得到的永远是 GMT 的时间
        var calander = Calendar.current
        calander.locale = Locale.current
        calander.timeZone = TimeZone(identifier: "GMT")! // 设置 GMT 时区获取 NSDate 的时间
        //let unitFlag: NSCalendar.Unit = [NSCalendar.Unit.timeZone, NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day]
        //let todayComponents = (calander as NSCalendar).components(unitFlag, from: currentDate) // Calander 根据 GMT 时区获取指定时间的组件
        let unitSet: Set<Calendar.Component> = [.timeZone, .year, .month, .day]
        let todayComponents = calander.dateComponents(unitSet, from: currentDate)
        calander.timeZone = TimeZone.current // 转换为当前时区
        let date = calander.date(from: todayComponents)! // 当前时区的时间
        // 清空时分秒微秒(当前时区日期只获取年月日)
        //return calander.date(from: (calander as NSCalendar).components(unitFlag, from: date))!
        return calander.date(from: calander.dateComponents(unitSet, from: date))!
    }
    /// 明天(年月日0时0分0秒0微秒)
    open var tomorrow: Date{
        var calander = Calendar.current
        calander.locale = Locale.current
        calander.timeZone = TimeZone.current
        //var dayAdd = DateComponents()
        //dayAdd.day = 1
        //return (calander as NSCalendar).date(byAdding: dayAdd, to: self.today, options:  NSCalendar.Options.wrapComponents)!
        return calander.date(byAdding: .day, value: 1, to: self.today)!
    }
    /// 创建日期(相对于当前时区)
    open func createDate(_ year:Int,_ month:Int,_ day:Int,_ hour: Int,_ minute: Int,_ second: Int) -> Date{
        var calander = Calendar.current
        calander.locale = Locale.current
        calander.timeZone = TimeZone.current
        var component = DateComponents()
        component.year = year
        component.month = month
        component.day = day
        component.hour = hour
        component.minute = minute
        component.second = second
        return calander.date(from: component)!
    }
    /// 地域格式输出时间日期
    open func localDate(_ date: Date) -> String{
        return date.description(with: Locale.current)
    }
    /// 最后的时间间隔[S]
    open func currentTimeInterval(_ date:Date?) -> TimeInterval{
        if let date = date{
            if let cacheDate = cacheCurrentDate{
                let timeInterval = date.timeIntervalSince1970 - cacheDate.timeIntervalSince1970
                cacheCurrentDate = date
                return timeInterval
            }
            cacheCurrentDate = date
            return date.timeIntervalSince1970
        }
        return -1.0
    }
    // NSDate,NSDateComponents,NSCalendar,NSDateFormatter
    /// 判断点击太快
    open static func isClickFast() -> Bool{
        let current = Date().timeIntervalSince1970
        if current - preClickTimeInterval < 0.5{ //0.5秒
            return true;
        }
        preClickTimeInterval = current
        return false;
    }
}
