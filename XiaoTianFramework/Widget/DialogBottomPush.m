//
//  DialogBottomPush.m
//  jjrcw
//
//  Created by XiaoTian on 2020/3/12.
//  Copyright © 2020 XiaoTian. All rights reserved.
//

#import "DialogBottomPush.h"
#import "UtilEnvironment.h"
#import "ConstantsXT.h"

@interface DialogBottomPush()

@property(nonatomic,strong)UIView *contentView;
@property(strong,nonatomic)UIView* shareItemView;
@property(assign,nonatomic)CGFloat contentViewY;
@property(assign,nonatomic)BOOL isShow;

@end

@implementation DialogBottomPush

-(instancetype)init: (NSArray<NSString*>*) items delegate:(id<DialogBottomPushDeletgate>)delegate{
    if(self = [super init]){
        self.delegate = delegate;
        [self initView: items];
    }
    return self;
}

-(void)initView:(NSArray<NSString*>*) items{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    // 磨砂视图背景
    UIVisualEffectView *bgView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [self setFrame:[UIScreen mainScreen].bounds];
    [self setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];
    self.contentView = [[UIView alloc] init];
    // Items
    CGFloat originY = 0;
    for(int i=0; i<items.count; i++){
        [self.contentView addSubview:[self getButton:items[i] y:originY tag:i]];
        originY += 45;
        [self.contentView addSubview:[self getDriverView:originY]];
        originY += 1;
    }
    // Cancel
    UIButton* cancelBtn = [[UIButton alloc]init];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [cancelBtn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setFrame:CGRectMake(0, originY, self.frame.size.width, 45)];
    [cancelBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:cancelBtn];
    originY += 45;
    
    self.contentViewY = self.frame.size.height - originY;
    // y==self.frame.size.height :view在外面,第一个进入动态
    CGRect bottomViewFrame = CGRectMake(0, self.frame.size.height, self.frame.size.width, originY);
    if(isIPhoneX){
        self.contentViewY -= 34;
    }
    [self.contentView setFrame:bottomViewFrame];
    bgView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
    [self.contentView insertSubview:bgView atIndex:0];
    [self addSubview:self.contentView];
}

-(UIView*)getDriverView:(CGFloat)y{
    UIView *driverView =[[UIView alloc]initWithFrame:CGRectMake(0, y, self.frame.size.width, 1)];
    driverView.backgroundColor = [UIColor colorWithRed:183/255.0 green:183/255.0 blue:183/255.0 alpha:1];
    return driverView;
}
-(UIButton*)getButton:(NSString*)title y:(CGFloat) y tag:(int) tag{
    UIButton* btn = [[UIButton alloc] init];
    btn.tag = tag;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btn setFrame:CGRectMake(0, y, self.frame.size.width, 45)];
    [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
-(void)show{
    if(self.isShow) return;
    self.isShow = YES;
    [UIView animateWithDuration:0.3f animations:^{
        CGRect newFrame = self.contentView.frame;
        newFrame.origin.y = self.contentViewY;
        [self.contentView setFrame:newFrame];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

-(void)close{
    self.isShow = NO;
    [UIView animateWithDuration:0.3f animations:^{
        CGRect newFrame = self.contentView.frame;
        newFrame.origin.y = self.frame.size.height;
        [self.contentView setFrame:newFrame];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    } completion:^(BOOL finished) {
        if(finished){
            [self removeFromSuperview];
        }
    }];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(!self.isShow){
        return;
    }
    UITouch *touch = [touches anyObject];
    if([touch locationInView:self].y < self.contentView.frame.origin.y){
        [self close];
    }
}

-(void)itemClick:(UIButton*)sender{
    if(self.delegate) [self.delegate onClickItemDialogBottom:self item:sender.tag];
    [self close];
}

@end
