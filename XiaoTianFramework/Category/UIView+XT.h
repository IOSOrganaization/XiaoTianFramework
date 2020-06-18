//
//  UIView+XT.h
//  qiqidu
//
//  Created by XiaoTian on 2020/1/2.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <Foundation/Foundation.h>
// 声明所有属性默认NONNULL
NS_ASSUME_NONNULL_BEGIN

@interface UIView(XT)
/// 新建一个实例UIView
+(instancetype)view;
/// 自动布局实例UIView
+(instancetype)autoView;
/// 新建一个实例设置背景色
+(instancetype)separator;
// 扩展属性

// 扩展方法
/// 移除当前UIView所有子视图
-(void)clearChildView;
/// 设置边框直角
-(void)setBorder:(CGFloat)border color:(UIColor*) color;
/// 设置边框圆角
-(void)setBorder:(CGFloat)border color:(UIColor*) color corner:(CGFloat)corner;
/// 设置圆角
-(void)setCorner:(CGFloat)corner;
/// 设置高度约束
-(void)setHeightConstraint:(CGFloat)height;
/// 移除高度约束
-(void)removeHeightConstraint;
/// 添加底部阴影线
-(void)addBottomLineShadow;
/// 添加边框阴影线
-(void)addBorderLineShadow;
/// 添加竖向灰色渐变半透明背景(上到下渐变透明)
-(void)addVerticalGrayGradientLayer;
/// UIView生成图片UIImage(UIScrollView移除头、脚的contentOffset)
-(UIImage*)captureImage;
@end

NS_ASSUME_NONNULL_END
