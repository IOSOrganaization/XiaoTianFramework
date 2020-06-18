//
//  UtilDate.h
//  qiqidu
//
//  Created by XiaoTian on 2016/12/6.
//  Copyright © 2016 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilDate : NSObject
+(NSString*)format:(long)millisecond;
+(NSString*)betweenTime:(long)millisecond to:(long)toMillisecond;
+(NSString*)getCurrentMillisecond;
+(NSString*)getCurrentMonth;
+(NSString*)getCurrentDay;
+(NSString*)getCurrentWeekday;
+(BOOL)isClickFast;
+(void)resetClickFast;
@end

NS_ASSUME_NONNULL_END
