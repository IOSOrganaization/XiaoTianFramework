//
//  UIImageView+XT.m
//  jjrcw
//
//  Created by XiaoTian on 2020/3/19.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "UIImageView+XT.h"

@implementation UIImageView(XT)

-(void)startImageAnima:(NSArray<NSString*>*)images duration:(NSTimeInterval)duration{
    // 单图
    if(images.count == 1){
        self.image = [UIImage imageNamed:images[0]];
        return;
    }
    // 多图
    NSMutableArray<UIImage*>* uiImages = [NSMutableArray arrayWithCapacity:images.count];
    for(NSString* name in images){
        [uiImages addObject:[UIImage imageNamed:name]];
    }
    // 无限循环
    self.animationImages = uiImages;
    self.animationDuration = duration;
    [self startAnimating];
}
-(void)addCornerLayerMask:(CGFloat)radius{
    if(self.layer.mask) return;
    // 添加圆角Mask
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    self.layer.mask = layer;
}
@end
