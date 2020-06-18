//
//  UIImageView+XT.h
//  jjrcw
//
//  Created by XiaoTian on 2020/3/19.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView(XT)

///多图切换动画
-(void)startImageAnima:(NSArray<NSString*>*)images duration:(NSTimeInterval)duration;
///添加圆角Mask,当前Bound
-(void)addCornerLayerMask:(CGFloat)radius;
@end

NS_ASSUME_NONNULL_END
