//
//  UtilNet.h
//  jjrcw
//
//  Created by XiaoTian on 2020/5/20.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilNet : NSObject
@property(strong,nonatomic)NSDictionary* dictionary;//常用字典,效率高
@property(strong,nonatomic)NSCache* cache;//类似NSDictionary,采用缓存模式,当内存不足时会触发释放内存操作(效率低,用于大内存频繁操作的缓存:网络请求缓存,文件读取缓存)
@end

NS_ASSUME_NONNULL_END
