//
//  UtilMBProgressHUD.h
//  qiqidu
//  MBProgressHUD 辅助类
//  Created by XiaoTian on 2020/1/2.
//  Copyright © 2020 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UtilMBProgressHUD : NSObject
+(void)showLoading;
+(void)closeLoading;
+(void)showLoading:(UIView*)view;
+(void)closeLoading:(UIView*)view;
+(void)showToast:(NSString*)toast;
+(void)showToast:(NSString*)toast view:(UIView*)view;
+(void)showToast:(NSString *)toast with:(NSString *)imageName textColor:(UIColor*)color;
+(void)showToast:(NSString *)toast with:(NSString *)imageName textColor:(UIColor*)color view:(UIView*)view;;
@end

NS_ASSUME_NONNULL_END
