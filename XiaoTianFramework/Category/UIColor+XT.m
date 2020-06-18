//
//  UIColor+XT.m
//  jjrcw
//
//  Created by XiaoTian on 2020/3/12.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "UIColor+XT.h"

@implementation UIColor(XT)

+(UIColor*) randomColor{
    CGFloat red = (arc4random() % 255) / 255;
    CGFloat green = (arc4random() % 255) / 255;
    CGFloat blue = (arc4random() % 255) / 255;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}

@end
