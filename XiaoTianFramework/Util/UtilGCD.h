//
//  UtilGCD.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 2019/12/5.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilGCD : NSObject
//Grand Central Dispatch
+(void)runInThread:(void(^)(void))thread on:(void(^)(void))mainThread;
+(void)post:(void (^)(void))mainThread;
+(void)postDelay:(void (^)(void))mainThread delay:(NSTimeInterval) delay;
+(dispatch_source_t)careateTimerScheduler:(void (^)(void)) secondHandler;
@end

NS_ASSUME_NONNULL_END
