//
//  XTFUILabel.h
//  XiaoTianFramework
//  扩展UILabel
//  Created by XiaoTian on 12/27/14.
//  Copyright (c) 2014 XiaoTian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XTFMylog.h"

@interface UILabel (XTFUILabel)

// 必须要设置Text后调用,用于重新计算大小
- (CGFloat) resizeLabel:(UILabel *)theLabel;

- (CGFloat) resizeLabel:(UILabel *)theLabel shrinkViewIfLabelShrinks:(BOOL)canShrink;
@end
