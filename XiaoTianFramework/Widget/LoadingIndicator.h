//
//  LoadingIndicator.h
//  jjrcw
//  加载中-菊花
//  Created by XiaoTian on 2020/3/19.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadingIndicator : UIView

/// 带加载提示文本
-(instancetype)init:(NSString* _Nullable)hint;
/// 添加到当前Window的根View视图
-(void)show;
/// 添加指定视图
-(void)show:(UIView*)anchorView;
/// 关闭
-(void)close;

@end

NS_ASSUME_NONNULL_END
