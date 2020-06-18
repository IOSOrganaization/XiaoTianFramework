//
//  UtilDate.m
//  qiqidu
//
//  Created by XiaoTian on 2016/12/6.
//  Copyright © 2016 XiaoTian. All rights reserved.
//

#import "UtilDate.h"

#define MONTH @[@"JAN",@"FEB",@"MAR",@"APR",@"MAY",@"JUN",@"JUL",@"AUG",@"SEP",@"OCT",@"NOV",@"DEC"]
#define WEEKDAY @[@"星期日",@"星期一",@"星期二",@"星期三",@"星期四",@"星期五",@"星期六"]

@implementation UtilDate

+(NSString*)format:(long)millisecond{
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return [format stringFromDate:[NSDate dateWithTimeIntervalSince1970:millisecond/1000.0]];
}

+(NSString*)betweenTime:(long)millisecond to:(long)toMillisecond{
    long spaceTime = toMillisecond - millisecond;
    int day = spaceTime % (24 * 60 * 60 * 1000);
    int hour = spaceTime % (60 * 60 * 1000);
    int minute = spaceTime % (60 * 1000);
    int seconds = spaceTime % 1000;
    if(day > 0){
        return [NSString stringWithFormat:@"%d天前",day];
    }
    if(hour > 0){
        return [NSString stringWithFormat:@"%d小时前",hour];
    }
    if(minute > 0){
        return [NSString stringWithFormat:@"%d分钟前",minute];
    }
    if(seconds > 0){
        return [NSString stringWithFormat:@"%d秒前",seconds == 0 ? 1 : seconds];
    }
    return @"刚刚";
}

+(NSString*)getCurrentMillisecond{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

+(NSString*)getCurrentMonth{
    NSInteger month = [self getDateComponents].month;
    return MONTH[month - 1];

}

+(NSString*)getCurrentWeekday{
    NSInteger weekday = [self getDateComponents].weekday;
    return WEEKDAY[weekday-1];
    
}

+(NSString*)getCurrentDay{
    NSString *currentDay = [NSNumber numberWithInteger:[self getDateComponents].day].stringValue;
    if(currentDay.length == 1){
        currentDay = [NSString stringWithFormat:@"%@%@",@"0",currentDay];
    }
    return currentDay;
}

+(NSDateComponents*)getDateComponents{
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    // 获取当前日期
    NSDate* dt = [NSDate date];
    // 定义一个时间字段的旗标，指定将会获取指定年、月、日、时、分、秒的信息
    unsigned unitFlags = NSCalendarUnitYear |
    NSCalendarUnitMonth |  NSCalendarUnitDay |
    NSCalendarUnitHour |  NSCalendarUnitMinute |
    NSCalendarUnitSecond | NSCalendarUnitWeekday;
    // 获取不同时间字段的信息
    NSDateComponents* comp = [gregorian components: unitFlags
                                          fromDate:dt];
    return comp;
}
static double preClickTime;
+(BOOL)isClickFast{
    if(CACurrentMediaTime() - preClickTime > 0.7){
        preClickTime = CACurrentMediaTime();
        return NO;
    }
    return YES;
}
+(void)resetClickFast{
    preClickTime = 0;
}
@end
