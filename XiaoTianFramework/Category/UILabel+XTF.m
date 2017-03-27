//
//  XTFUILabel.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 12/27/14.
//  Copyright (c) 2014 XiaoTian. All rights reserved.
//

#import "UILabel+XTF.h"

@implementation UILabel (XTFUILabel)

- (CGFloat) resizeLabel:(UILabel *)theLabel shrinkViewIfLabelShrinks:(BOOL)canShrink {
    CGRect frame = [theLabel frame];
    CGSize size = [theLabel.text sizeWithFont:theLabel.font
                            constrainedToSize:CGSizeMake(frame.size.width, 9999)
                                lineBreakMode:UILineBreakModeWordWrap];
    CGFloat delta = size.height - frame.size.height;
    frame.size.height = size.height;
    [theLabel setFrame:frame];

    CGRect contentFrame = self.frame;
    contentFrame.size.height = contentFrame.size.height + delta;
    if(canShrink || delta > 0) {
        [self setFrame:contentFrame];
    }
    return delta;
}

- (CGFloat) resizeLabel:(UILabel *)theLabel {
    return [self resizeLabel:theLabel shrinkViewIfLabelShrinks:YES];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
