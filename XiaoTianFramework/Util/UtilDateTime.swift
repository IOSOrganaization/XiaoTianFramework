//
//  UtilDateTime.swift
//  DriftBook
//
//  Created by XiaoTian on 16/7/6.
//  Copyright © 2016年 XiaoTian. All rights reserved.
//

import Foundation
import UIKit

@objc(UtilDateTimeXT)
class UtilDateTime: NSObject {
    
    /// 格式化日期 (秒/s) [1990年1月1日]
    func formatMillisecondDate(dateMillisecond: NSNumber?) -> String?{
        if dateMillisecond == nil {
            return nil
        }
        // 时间格式化器
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日" // 日期格式:yyyy-MM-dd'T'HH:mm:ss.SSSZ
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone() // 默认时区
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(Double((dateMillisecond?.integerValue)!) / 1000.0)) // 毫秒 -> 秒
        return dateFormatter.stringFromDate(date) // 格式化
    }
    /// 格式化日期 (秒/s) [1月1日]
    func formatDateTime(dateMillisecond: NSNumber?) -> String?{
        if dateMillisecond == nil {
            return nil
        }
        // 时间格式化器
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM月dd日" // 日期格式
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone() // 默认时区
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(Double((dateMillisecond?.integerValue)!) / 1000.0)) // 毫秒 -> 秒
        return dateFormatter.stringFromDate(date) // 格式化
    }
    /// 格式化日期时间 (秒/s) [1990年1月1日 23:36:50]
    func formatMillisecondDateTime(dateMillisecond: NSNumber?) -> String?{
        if dateMillisecond == nil {
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone() //NSTimeZone(name: "UTC")
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(Double((dateMillisecond?.integerValue)!) / 1000.0))
        return dateFormatter.stringFromDate(date)
    }
    /// 格式化时间 (秒/s) [23:35:50]
    func formatMillisecondTime(dateMillisecond: NSNumber?) -> String?{
        if dateMillisecond == nil {
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone() //NSTimeZone(name: "UTC")
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(Double((dateMillisecond?.integerValue)!) / 1000.0))
        return dateFormatter.stringFromDate(date)
    }
    
    /// 格式化为指定时间格式[yyyy:四位年,MM:月,dd:日,HH:时,mm:分,ss:秒,SSS:毫秒,Z:时区]
    func formatMillisecond(pattern:String,_ dateMillisecond: NSNumber?) -> String?{
        if dateMillisecond == nil {
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = pattern
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(Double((dateMillisecond?.integerValue)!) / 1000.0))
        return dateFormatter.stringFromDate(date)
    }
    /// 格式化为指定时间格式
    func formatDateTime(pattern:String,_ date: NSDate?) -> String?{
        if date == nil {
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = pattern
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        return dateFormatter.stringFromDate(date!)
    }
    /// 时刻(无时区限制)
    func formatFunnyDate(dateMillisecond: NSNumber?) -> String?{
        if dateMillisecond == nil {
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(Double((dateMillisecond?.integerValue)!) / 1000.0)) // GMT 时间
        //
        let dateNow =  NSDate()
        let calander = NSCalendar.currentCalendar()
        calander.locale = NSLocale.currentLocale()
        calander.timeZone = NSTimeZone(name: "GMT")!
        // 10分钟之内,显示刚刚
        let minute = NSDateComponents()
        minute.minute = -10
        // options: OptionSetType(Option 集合类型,空: [] 或 OptionSetType(rawValue:0)))
        let minuteDate: NSDate! = calander.dateByAddingComponents(minute, toDate: dateNow, options: [])
        // 10分钟之内,显示刚刚
        let minuteCompareResult = calander.compareDate(date, toDate: minuteDate, toUnitGranularity: .Second)
        if minuteCompareResult == NSComparisonResult.OrderedDescending || minuteCompareResult == NSComparisonResult.OrderedSame { // date > minuteDate
            // toUnitGranularity: 日期需要进行比较的最小单位[年号,年,月,日,时,分,秒,微秒,周,周序号,月周,年周,日历组件...]
            return "刚刚"
        }
        // 一个小时内,显示多少分钟前
        let hour = NSDateComponents()
        hour.hour = -1
        let hourDate: NSDate! = calander.dateByAddingComponents(hour, toDate: dateNow, options: [])
        let hourCompareResult = calander.compareDate(date, toDate: hourDate, toUnitGranularity: .Second)
        if hourCompareResult == NSComparisonResult.OrderedDescending { // date > hourDate
            //let result = dateNow.minute - date.minute
            //return "\(result > 0 ? result : 60 + result)分钟前" // 跨过60分后从1开始[结果小于0], 其他结果大于0
            return "n分钟前"
        }
        // 今天内,显示几点几分
        let dayCompareResult = calander.compareDate(date, toDate: today, toUnitGranularity: .Second)
        if dayCompareResult == NSComparisonResult.OrderedDescending || dayCompareResult == NSComparisonResult.OrderedSame{ // date > dayDate
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.stringFromDate(date)
        }
        // 昨天显示昨天
        if calander.compareDate(date, toDate: yesterday, toUnitGranularity: .Second) == .OrderedDescending{
            return "昨天"
        }
        // 其他显示日期
        dateFormatter.dateFormat = "MM月dd日"
        return dateFormatter.stringFromDate(date)
    }
    /// 转换格式化时间为毫秒[相距1970年时间] 格式为:[1990年1月1日]
    func pasteStringMillisecond(date:String?) -> NSNumber?{
        if date == nil{
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let d = dateFormatter.dateFromString(date!)
        if d == nil {
            return nil
        }
        return NSNumber(unsignedLongLong: UInt64((d?.timeIntervalSince1970)! * 1000))
    }
    /// 转换NSDate为毫秒
    func pasteDateMillisecond(date:NSDate?) -> NSNumber?{
        if date == nil{
            return nil
        }
        return NSNumber(unsignedLongLong: UInt64((date?.timeIntervalSince1970)! * 1000))
    }
    /// 转换格式化时间为毫秒[相距1970年时间] 格式为:[1990年1月1日 23:36:50]
    func pasteDateTimeMillisecond(date:String?) -> NSNumber?{
        if date == nil{
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let d = dateFormatter.dateFromString(date!)
        if d == nil {
            return nil
        }
        return NSNumber(unsignedLongLong: UInt64((d?.timeIntervalSince1970)! * 1000))
    }
    /// 转换格式化时间为毫秒[相距1970年时间] 格式为:[23:35:50]
    func pasteTimeMillisecond(date:String?) -> NSNumber?{
        if date == nil{
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let d = dateFormatter.dateFromString(date!)
        if d == nil {
            return nil
        }
        return NSNumber(unsignedLongLong: UInt64((d?.timeIntervalSince1970)! * 1000))
    }
    /// 转换String格式化的时间为毫秒
    func pasteFormatDateMillisecond(pattern:String,_ date:String?) -> NSNumber?{
        if date == nil{
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = pattern
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        let d = dateFormatter.dateFromString(date!)
        if d == nil {
            return nil
        }
        return NSNumber(unsignedLongLong: UInt64((d?.timeIntervalSince1970)! * 1000))
    }
    /// 转换格式化日期时间 格式为:[yyyy年MM月dd日 HH:mm:ss]
    func pasteDateTime(dateTime:String?) -> NSDate?{
        if dateTime == nil{
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        return dateFormatter.dateFromString(dateTime!)
    }
    /// 转换格式化日期 格式为:[yyyy年MM月dd日]
    func pasteDate(date:String?) -> NSDate?{
        if date == nil{
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        return dateFormatter.dateFromString(date!)
    }
    /// 转换格式化时间 格式为:[HH:mm:ss]
    func pasteTime(time:String?) -> NSDate?{
        if time == nil{
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        return dateFormatter.dateFromString(time!)
    }
    /// 转换数字时间为 Date
    func translateToDate(dateMillisecond: NSNumber?) -> NSDate?{
        if dateMillisecond == nil {
            return nil
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm:ss"
        dateFormatter.timeZone = NSTimeZone.defaultTimeZone()
        return NSDate(timeIntervalSince1970: NSTimeInterval(Double((dateMillisecond?.integerValue)!) / 1000.0))
    }
    /// 获取时间的中文周
    func getChineseWeekDay(date: NSDate?) -> String?{
        if date != nil{
            return nil
        }
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let myComponents = calendar.components(.Weekday, fromDate: date!)
        let weekDay = myComponents.weekday
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
    /// 当前日期时间(当前时区时间[实质为重新设置 NSDate 时区])
    var currentDate: NSDate{
        let currentDate = NSDate() // GMT 时间
        let calander = NSCalendar.currentCalendar()
        calander.locale = NSLocale.currentLocale()
        calander.timeZone = NSTimeZone(name: "GMT")! // 设置 GMT 时区获取 NSDate 的时间
        let unitFlag: NSCalendarUnit = [NSCalendarUnit.TimeZone , NSCalendarUnit.Year , NSCalendarUnit.Month , NSCalendarUnit.Day, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second, NSCalendarUnit.Nanosecond]
        let todayComponents = calander.components(unitFlag, fromDate: currentDate) // Calander 根据 GMT 时区获取指定时间的组件
        //
        calander.timeZone = NSTimeZone.defaultTimeZone() // 转换为当前时区
        return calander.dateFromComponents(todayComponents)! // 当前时区的时间
    }
    /// 昨天(年月日0时0分0秒0微秒)
    var yesterday: NSDate{
        let calander = NSCalendar.currentCalendar()
        calander.locale = NSLocale.currentLocale()
        calander.timeZone = NSTimeZone.defaultTimeZone()
        let dayAdd = NSDateComponents()
        dayAdd.day = -1
        return calander.dateByAddingComponents(dayAdd, toDate: self.today, options:  NSCalendarOptions.WrapComponents)!
    }
    /// 今天(年月日0时0分0秒0微秒)
    var today: NSDate{
        let currentDate = NSDate() // NSDate 得到的永远是 GMT 的时间
        let calander = NSCalendar.currentCalendar()
        calander.locale = NSLocale.currentLocale()
        calander.timeZone = NSTimeZone(name: "GMT")! // 设置 GMT 时区获取 NSDate 的时间
        let unitFlag: NSCalendarUnit = [NSCalendarUnit.TimeZone, NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day]
        let todayComponents = calander.components(unitFlag, fromDate: currentDate) // Calander 根据 GMT 时区获取指定时间的组件
        calander.timeZone = NSTimeZone.defaultTimeZone() // 转换为当前时区
        let date = calander.dateFromComponents(todayComponents)! // 当前时区的时间
        // 清空时分秒微秒(当前时区日期只获取年月日)
        return calander.dateFromComponents(calander.components(unitFlag, fromDate: date))!
    }
    /// 明天(年月日0时0分0秒0微秒)
    var tomorrow: NSDate{
        let calander = NSCalendar.currentCalendar()
        calander.locale = NSLocale.currentLocale()
        calander.timeZone = NSTimeZone.defaultTimeZone()
        let dayAdd = NSDateComponents()
        dayAdd.day = 1
        return calander.dateByAddingComponents(dayAdd, toDate: self.today, options:  NSCalendarOptions.WrapComponents)!
    }
    /// 创建日期(相对于当前时区)
    func createDate(year:Int,_ month:Int,_ day:Int,_ hour: Int,_ minute: Int,_ second: Int) -> NSDate{
        let calander = NSCalendar.currentCalendar()
        calander.locale = NSLocale.currentLocale()
        calander.timeZone = NSTimeZone.defaultTimeZone()
        let component = NSDateComponents()
        component.year = year
        component.month = month
        component.day = day
        component.hour = hour
        component.minute = minute
        component.second = second
        return calander.dateFromComponents(component)!
    }
}