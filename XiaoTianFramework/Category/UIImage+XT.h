//
//  UIImage+XT.h
//  qiqidu
//
//  Created by XiaoTian on 2020/1/2.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;
// 声明所有属性默认NONNULL
NS_ASSUME_NONNULL_BEGIN

@interface UIImage(XT)
// 扩展属性
// 扩展方法
//
/// 创建指定颜色和大小的图片
+(instancetype)imageFromColor:(UIColor*)color size:(CGSize)size;
/// 创建指定颜色和大小的圆角图片
+(instancetype)imageFromColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius;
/// 检测读取相册权限
+(void)checkedMediaDevicePermission:(AVMediaType)type callback:(void(^)(BOOL,BOOL))callBack;
/// 支持相机
+(BOOL)isCameraAvailable;
/// 选取一张照片
+(void)checkPhoto:(UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>*)ctr isNeedEdit:(BOOL)isNeedEdit;
/// 切圆角图片
- (UIImage *)clipRadius:(CGFloat)radius;
/// 切右上外圆角图片(Core Graphics)
-(UIImage *)clipTopRightOuterRadius:(CGFloat)radius;
//
@end

NS_ASSUME_NONNULL_END
