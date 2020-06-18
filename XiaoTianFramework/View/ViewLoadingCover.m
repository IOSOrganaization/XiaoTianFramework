//
//  ViewLoadingCover.m
//  jjrcw
//
//  Created by XiaoTian on 2020/3/20.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "ViewLoadingCover.h"
@interface ViewLoadingCover()

@end

@implementation ViewLoadingCover

- (void)layoutSubviews{
    //1. init初始化不会触发layoutSubviews,但是是用initWithFrame 进行初始化时，当rect的值不为CGRectZero时,也会触发
    //2. addSubview会触发layoutSubviews
    //3、设置view的Frame会触发layoutSubviews，当然前提是frame的值设置前后发生了变化
    //4、滚动一个UIScrollView会触发layoutSubviews
    //5、旋转Screen会触发父UIView上的layoutSubviews事件
    //6、改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件
}


@end
