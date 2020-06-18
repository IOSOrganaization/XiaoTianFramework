//
//  UIViewController+XTSelectPhoto.h
//  qiqidu
//
//  Created by XiaoTian on 2020/1/2.
//  Copyright © 2020 XiaoTian. All rights reserved.
//

#import <Foundation/Foundation.h>
// 声明所有属性默认NONNULL
NS_ASSUME_NONNULL_BEGIN

@interface UIViewController(XTSelectPhoto)

-(void) checkPhotoWithCount:(int)maxCount;
-(void) checkPhotoOrPicture;
@end

NS_ASSUME_NONNULL_END
