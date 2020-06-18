//
//  UtilMBProgressHUD.m
//  qiqidu
//
//  Created by XiaoTian on 2020/1/2.
//  Copyright © 2020 XiaoTian. All rights reserved.
//

#import "UtilMBProgressHUD.h"
#import"UIViewController+XT.h"
//#import "MBProgressHUD.h"

@implementation UtilMBProgressHUD
/*/// MBProgressHUD Toast 提示
+(void)showToast:(NSString *)toast{
    //[self showToast:toast with:[[UIApplication sharedApplication].windows lastObject]];
    [self showToast:toast view:[UIViewController getTopViewController].view];
}
/// BProgressHUD Toast 提示
+(void)showToast:(NSString *)toast view:(UIView *)view{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = toast;
    [hud hideAnimated:YES afterDelay:1.5f];
}
/// MBProgressHUD Toast 提示,上部图片
+(void)showToast:(NSString *)toast with:(NSString *)imageName textColor:(UIColor *)color{
    [self showToast:toast with:imageName textColor:color view:[UIViewController getTopViewController].view];
}
/// MBProgressHUD Toast 提示,上部图片
+(void)showToast:(NSString *)toast with:(NSString *)imageName textColor:(UIColor *)color view:(UIView *)view{
    //MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    //去掉磨砂
    [hud.bezelView.subviews[0] removeFromSuperview];
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    hud.label.textColor = color;
    // Optional label text.
    hud.label.text = toast;
    hud.label.font = [UIFont systemFontOfSize:15];
    
    [hud hideAnimated:YES afterDelay:1.5f];
}
/// 加载中提示
+(void)showLoading{
    //[self showLoading:[[UIApplication sharedApplication].windows lastObject]];
    [self showLoading:[UIViewController getTopViewController].view];
}
/// 加载中提示
+(void)showLoading:(UIView*)view{
    [MBProgressHUD showHUDAddedTo:view animated:YES];
}
/// 关闭加载中提示
+(void)closeLoading{
    //[self closeLoading:[[UIApplication sharedApplication].windows lastObject]];
    [self closeLoading:[UIViewController getTopViewController].view];
}
/// 关闭加载中提示
+(void)closeLoading:(UIView*)view{
    [MBProgressHUD hideHUDForView:view animated:YES];
}*/
@end
