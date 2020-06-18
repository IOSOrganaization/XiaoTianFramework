//
//  AppDelegateXT.h
//  jjrcw
//
//  Created by XiaoTian on 2020/5/26.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppDelegateXT :  UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

NS_ASSUME_NONNULL_END
/*
* 麦克风权限：Privacy - Microphone Usage Description 是否允许此App使用你的麦克风？

* 相机权限： Privacy - Camera Usage Description 是否允许此App使用你的相机？

* 相册权限： Privacy - Photo Library Usage Description 是否允许此App访问你的媒体资料库？

* 通讯录权限： Privacy - Contacts Usage Description 是否允许此App访问你的通讯录？

* 蓝牙权限：Privacy - Bluetooth Peripheral Usage Description 是否许允此App使用蓝牙？

* 语音转文字权限：Privacy - Speech Recognition Usage Description 是否允许此App使用语音识别？

* 日历权限：Privacy - Calendars Usage Description 是否允许此App使用日历？

* 定位权限：Privacy - Location When In Use Usage Description 我们需要通过您的地理位置信息获取您周边的相关数据

* 定位权限: Privacy - Location Always Usage Description 我们需要通过您的地理位置信息获取您周边的相关数据
*/
