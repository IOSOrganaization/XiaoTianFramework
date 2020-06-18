//
//  LoadingIndicator.m
//  jjrcw
//
//  Created by XiaoTian on 2020/3/19.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "LoadingIndicator.h"

@interface LoadingIndicator()
@property(strong,nonatomic)UIView *contentView;
@property(strong,nonatomic)UIActivityIndicatorView* indicatorView;
@property(strong,nonatomic)UILabel* lbHint;
@property(assign,nonatomic)BOOL isShow;
@end

@implementation LoadingIndicator
- (instancetype)init{
    self = [super init];
    if (self) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        self.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
        self.backgroundColor = UIColor.clearColor;
        [self initView:nil];
    }
    return self;
}
-(instancetype)init:(NSString*)hint{
    self = [super init];
    if (self) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        self.frame = CGRectMake(0, 0, bounds.size.width, bounds.size.height);
        self.backgroundColor = UIColor.clearColor;
        [self initView:hint];
    }
    return self;
}
-(void) initView:(NSString*)hint{
    // 点击关闭
    //UIButton* btn = [[UIButton alloc] initWithFrame:self.frame];
    //[btn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    //[self addSubview:btn];
    //
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicatorView.color = UIColor.grayColor;
    [self.indicatorView startAnimating];
    [self scaleIndicatorView];
    CGFloat width = self.indicatorView.frame.size.width+30;
    CGFloat height = self.indicatorView.frame.size.height+30;
    if(hint){
        // 文本提示
        self.lbHint = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width*0.8, self.frame.size.height*0.6)];
        self.lbHint.font = [UIFont systemFontOfSize:16];
        self.lbHint.textColor = UIColor.blackColor;
        self.lbHint.textAlignment = NSTextAlignmentCenter;
        self.lbHint.text = hint;
        self.lbHint.numberOfLines = 0;
        [self.lbHint sizeToFit];
        CGFloat lbWidth = MIN(self.frame.size.width*0.8, MAX(self.lbHint.frame.size.width, 80));
        CGFloat lbHeight = MIN(self.frame.size.height*0.6, MAX(self.lbHint.frame.size.height, 21));
        width = MAX(lbWidth+20, width);
        self.lbHint.frame = CGRectMake(10, height-15+10, lbWidth, lbHeight);
        height += lbHeight+15;
    }
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake((self.frame.size.width-width)/2.0, (self.frame.size.height-height)/2.0, width, height)];
    self.contentView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.layer.cornerRadius = 10;
    //
    self.indicatorView.frame = CGRectMake((width-self.indicatorView.frame.size.width)/2, 15, self.indicatorView.frame.size.width, self.indicatorView.frame.size.height);
    [self.contentView addSubview:self.indicatorView];
    //
    if(self.lbHint) [self.contentView addSubview:self.lbHint];
    [self addSubview:self.contentView];
}
-(void)show{
    if(self.isShow) return;
    self.isShow = YES;
    [self addShowAnimation];
    [[UIApplication sharedApplication].keyWindow addSubview:self];//window的视图
}
- (void)show:(UIView *)anchorView{
    if(self.isShow) return;
    self.isShow = YES;
    [self addShowAnimation];
    [anchorView addSubview:self];
}
-(void)addShowAnimation{
    self.contentView.alpha = 0.0;
    [UIView animateWithDuration:0.3f animations:^{
        self.contentView.alpha = 1.0;
    }];
}

-(void)close{
    self.isShow = NO;
    [self removeFromSuperview];
}
// 整个控件放大转换
-(void)scaleIndicatorView{
    CGAffineTransform transform = CGAffineTransformMakeScale(0.7, 0.7);
    self.indicatorView.transform = transform;
}
@end
