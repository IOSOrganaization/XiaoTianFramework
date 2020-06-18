//
//  UIView+XT.m
//  qiqidu
//
//  Created by XiaoTian on 2020/1/2.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "UIView+XT.h"

@implementation UIView(XT)
+ (instancetype)view{
    return [[UIView alloc] init];
}

+ (instancetype)autoView{
    UIView* view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

+ (instancetype)separator{
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1];
    return view;
}

-(void)clearChildView{
    if(self.subviews.count > 0){
        for(UIView *childView in self.subviews){
            [childView removeFromSuperview];
        }
    }
}

-(void)setBorder:(CGFloat)border color:(UIColor*) color{
    //self.clipsToBounds = YES;//会离屏渲染
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = border;
}

-(void)setBorder:(CGFloat)border color:(UIColor*) color corner:(CGFloat)corner{
    self.clipsToBounds = NO;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = border;
    self.layer.cornerRadius = corner;
}

-(void)setCorner:(CGFloat)corner{
    self.clipsToBounds = NO;
    self.layer.cornerRadius = corner;
}

-(void)setHeightConstraint:(CGFloat)height{
    NSArray* constrains = self.constraints;
    for (NSLayoutConstraint* constraint in constrains) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            [self removeConstraint:constraint];
        }
    }
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:height]];
}

-(void)removeHeightConstraint{
    NSArray* constrains = self.constraints;
    for (NSLayoutConstraint* constraint in constrains) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            [self removeConstraint:constraint];
        }
    }
}

- (void)addBottomLineShadow{
    self.layer.masksToBounds = NO;//超出区域不剪
    self.layer.shadowOffset = CGSizeMake(0, 1);
    self.layer.shadowRadius = 1.5;
    self.layer.shadowOpacity = 0.1;
}

- (void)addBorderLineShadow{
    self.layer.masksToBounds = NO;//超出区域不剪
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowRadius = 1.5;
    self.layer.shadowOpacity = 0.1;
}

-(void)addVerticalGrayGradientLayer{
    CAGradientLayer* verticalGradientLayer = [CAGradientLayer layer];
    verticalGradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.6].CGColor,//颜色渐变,start->end
                                     (__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0].CGColor];
    verticalGradientLayer.startPoint = CGPointMake(0, 0);//x,y
    verticalGradientLayer.endPoint = CGPointMake(0, 1.0);//
    verticalGradientLayer.locations = @[@(0.0f), @(1.0f)];//颜色关键点位置
    verticalGradientLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self.layer addSublayer:verticalGradientLayer];
}

-(UIImage*)captureImage{
    if([self isKindOfClass: UIScrollView.class]){
        [Mylog info:@"去掉UIScrollView的contentOffset边距"];
        UIScrollView* sv = (UIScrollView*) self;
        CGRect cacheFrame = sv.frame;
        CGPoint cacheOffset = sv.contentOffset;
        CGSize size = sv.contentSize;
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        sv.contentOffset = CGPointZero;
        sv.frame = CGRectMake(0, 0, size.width, size.height);
        [sv.layer renderInContext:UIGraphicsGetCurrentContext()];
        sv.contentOffset = cacheOffset;
        sv.frame = cacheFrame;
    }else{
        CGSize size = self.bounds.size;
        // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了，关键就是第三个参数。
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
// frame bounds center 的区别,1.frame是相对于其它视图,2.bounds是相对于本身,本地坐标系,管理的是子视图添加进本视图的一个过程。(设置bounds为(-20,-20,...,...)如果子视图的frame是(0, 0, ..., ...)，那么就会以距左边界20，距上边界20这样的形式添加进来),因为子视图的frame坐标是以母视图的bounds坐标为准。
@end
