//
//  UIImage+XT.m
//  qiqidu
//
//  Created by XiaoTian on 2020/1/2.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "UIImage+XT.h"

@implementation UIImage(XT)

+(instancetype)imageFromColor:(UIColor*)color size:(CGSize)size{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width,size.height);
    UIGraphicsBeginImageContext(size);//创建图片
    CGContextRef context = UIGraphicsGetCurrentContext();//创建图片上下文
    CGContextSetFillColorWithColor(context, [color CGColor]);//设置当前填充颜色的图形上下文
    CGContextFillRect(context, rect);//填充颜色
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
+(instancetype)imageFromColor:(UIColor *)color size:(CGSize)size radius:(CGFloat)radius{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    view.backgroundColor = color;
    view.layer.cornerRadius = radius;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否不透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数是屏幕密度
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
/// 对当前UIImage的图片指定颜色进行渲染
+(void)checkedMediaDevicePermission:(AVMediaType)type callback:(void (^)(BOOL,BOOL))callBack{
    AVAuthorizationStatus aVstatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (aVstatus) {
        case AVAuthorizationStatusAuthorized:
            callBack(YES,NO);
            break;
        case AVAuthorizationStatusDenied:
            callBack(NO,NO);
            break;
        case AVAuthorizationStatusNotDetermined:
            [UIImage requestPermission:type callback:callBack];
            break;
        case AVAuthorizationStatusRestricted:
            break;
    }
}

+(void)requestPermission:(AVMediaType)mediaType callback:(void (^)(BOOL,BOOL))callBack{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL isGrant){
        callBack(isGrant,YES);
    }];
}
+(BOOL)isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+(void)checkPhoto:(UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>*)ctr isNeedEdit:(BOOL)isNeedEdit{
    __block typeof(ctr) that = ctr;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =  [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [UIImage checkedMediaDevicePermission:AVMediaTypeVideo callback:^(BOOL isGrant,BOOL isFirstRequest){
                if(isGrant){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([UIImage isCameraAvailable]){
                            [UIImage openImageMedia:UIImagePickerControllerSourceTypeCamera ctr:that isNeedEdit:isNeedEdit];
                        }
                    });
                }else{
                    if(isFirstRequest){
                        return;
                    }
                    [UIImage showRejectTip:ctr];
                }
            }];
        }];
        
        UIAlertAction *galleryAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [UIImage openImageMedia:UIImagePickerControllerSourceTypePhotoLibrary ctr:that isNeedEdit:isNeedEdit];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:cameraAction];
        [alertController addAction:galleryAction];
        
        [ctr presentViewController:alertController animated:YES completion:nil];
    });
}

+(void)showRejectTip:(UIViewController*)ctr{//重新打开貌似会闪退
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示?" message:@"拍照权限被拒绝是否打开" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:url]){
            NSURL*url =[NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication]openURL:url];
            }
        }
    }];
    
    [alertController addAction:cancel];
    [alertController addAction:sure];
    [ctr presentViewController:alertController animated:YES completion:nil];
}

+(void)openImageMedia:(UIImagePickerControllerSourceType)type ctr:(UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>*)ctr isNeedEdit:(BOOL)isNeedEdit{
    UIImagePickerController *imagePickerCtl = [[UIImagePickerController alloc]init];
    imagePickerCtl.delegate = ctr;
    [imagePickerCtl.navigationBar setBarTintColor:[UIColor whiteColor]];
    [imagePickerCtl.navigationBar setTranslucent:NO];
    [imagePickerCtl.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:UIColor.blackColor}];
    [imagePickerCtl.navigationBar setTintColor:UIColor.blackColor];
    [imagePickerCtl setAllowsEditing:isNeedEdit];
    [imagePickerCtl setSourceType:type];
    [ctr presentViewController:imagePickerCtl animated:YES completion:nil];
}

- (UIImage *)clipRadius:(CGFloat)radius{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //Bezier Path
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx,path.CGPath);
    CGContextClip(ctx);
    //Image
    [self drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(UIImage *)clipTopRightOuterRadius:(CGFloat)radius{
    //1、开启上下文
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0);
    //2、设置裁剪区域
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    [path addArcWithCenter:CGPointMake(self.size.width, 0) radius:radius startAngle:- M_PI  endAngle:-M_2_PI clockwise:NO];//右上角圆角
    [path closePath];
    [path addClip];
    //3、绘制图片
    [self drawAtPoint:CGPointZero];
    //4、获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5、关闭上下文
    UIGraphicsEndImageContext();
    //6、返回新图片
    return newImage;
}
@end
