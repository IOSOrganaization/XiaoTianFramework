//
//  FWSlideMenu.m
//  FWSideMenu_OC
//
//  Created by XiaoTian on 2020/4/1.
//  Copyright © 2020 xfg. All rights reserved.
//

#import "FWSlideMenu.h"

@interface FWSlideMenu()
@property(strong,nonatomic)FWSideMenuShadow* sideMenuShadow;
@property(assign,nonatomic)BOOL isViewHasLoad;//viewdidLoad标识
@property(strong,nonatomic)UIView* centerLeftPanView;
@property(strong,nonatomic)UIView* centerRightPanView;
@property(assign,nonatomic)BOOL menuSlideAnimationEnabled;
@property(assign,nonatomic)CGFloat menuSlideAnimationFactor;
@property(assign,nonatomic)BOOL centerMaskViewEnabled;
@property(assign,nonatomic)BOOL centerTapGestureEnabled;
@property(strong,nonatomic)UIView* centerMaskView;
@property(strong,nonatomic)UIView* menuContainerView;
@property(assign,nonatomic)CGFloat centerLeftPanViewWidth;
@property(assign,nonatomic)CGFloat centerRightPanViewWidth;
@property(strong,nonatomic)UITapGestureRecognizer* centerTapGestureRecognizer;
@property(strong,nonatomic)UIPanGestureRecognizer* centerLeftPanGestureRecognizer;
@property(strong,nonatomic)UIPanGestureRecognizer* centerRightPanGestureRecognizer;
@property(strong,nonatomic)UIPanGestureRecognizer* centerMaskPanGestureRecognizer;
@property(strong,nonatomic)UIPanGestureRecognizer* sideMenuPanGestureRecognizer;
@property(assign,nonatomic)CGPoint panGestureOrigin;
@property(assign,nonatomic)CGFloat panGestureVelocity;
@property(assign,nonatomic)CGFloat menuAnimationDefaultDuration;
@property(assign,nonatomic)CGFloat menuAnimationMaxDuration;
@end

@implementation FWSlideMenu
+(instancetype)container:(UIViewController*)centerViewController left:(UIViewController*)left right:(UIViewController*)right{
    return [self container:centerViewController centerLeftPanViewWidth:UIScreen.mainScreen.bounds.size.width/2 left:left centerRightPanViewWidth:UIScreen.mainScreen.bounds.size.width/2 right:right];
}
+(instancetype)container:(UIViewController*)centerViewController centerLeftPanViewWidth:(CGFloat)centerLeftPanViewWidth left:(UIViewController*)left centerRightPanViewWidth:(CGFloat)centerRightPanViewWidth right:(UIViewController*)right{
    FWSlideMenu* menu = [[FWSlideMenu alloc] init];
    menu.centerViewController = centerViewController;
    menu.centerLeftPanViewWidth = centerLeftPanViewWidth;
    menu.centerRightPanViewWidth = centerRightPanViewWidth;
    menu.leftMenuViewController = left;
    menu.rightMenuViewController = right;
    [menu setupCommponent];
    return menu;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.leftMenuWidth = UIScreen.mainScreen.bounds.size.width * 0.8;
        self.rightMenuWidth = 270.0;
        self.menuSlideAnimationEnabled = YES;
        self.menuSlideAnimationFactor = 3.0;
        self.centerMaskViewEnabled = YES;
        self.sideMenuShadowEnabled = NO;
        self.centerTapGestureEnabled = YES;
        self.centerMaskView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        self.centerLeftPanView = [[UIView alloc] init];
        self.centerLeftPanView.backgroundColor = UIColor.clearColor;
        self.centerRightPanView = [[UIView alloc] init];
        self.centerRightPanView.backgroundColor = UIColor.clearColor;
        self.menuContainerView = [[UIView alloc] init];
        self.panGestureOrigin = CGPointZero;
        self.menuAnimationDefaultDuration = 0.2;
        self.menuAnimationMaxDuration = 0.4;
    }
    return self;
}
- (void)setupCommponent{
    self.centerTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(centerVCTapAction:)];
    self.centerTapGestureRecognizer.delegate = self;
    self.centerLeftPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    self.centerLeftPanGestureRecognizer.delegate = self;
    self.centerRightPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    self.centerRightPanGestureRecognizer.delegate = self;
    self.centerMaskPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    self.centerMaskPanGestureRecognizer.delegate = self;
    self.sideMenuPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    self.sideMenuPanGestureRecognizer.delegate = self;
}
- (void)viewDidLoad{
    [super viewDidLoad];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!self.isViewHasLoad){
        [self setupMenuContainerView];
        [self setLeftSideMenuFrameToClosedPosition];
        [self setRightSideMenuFrameToClosedPosition];
        [self addGestureRecognizers];
        self.isViewHasLoad = YES;
    }
}
-(void)setupMenuContainerView{
    if(self.menuContainerView.superview)return;
    self.menuContainerView.frame = self.view.bounds;
    self.menuContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:self.menuContainerView atIndex:0];
    if(self.leftMenuViewController && self.leftMenuViewController.view.superview == nil){
        [self.menuContainerView addSubview:self.leftMenuViewController.view];
    }
    if(self.rightMenuViewController && self.rightMenuViewController.view.superview == nil){
        [self.menuContainerView addSubview:self.rightMenuViewController.view];
    }
}
- (void)setCenterViewController:(UIViewController *)centerViewController{
    [self removeCenterGestureRecognizers];
    [self removeChildViewControllerFromContainer:_centerViewController];
    _centerViewController = centerViewController;
    if(centerViewController){
        [self addChildViewController:centerViewController];
        [self.view addSubview:centerViewController.view];
        [centerViewController didMoveToParentViewController:self];
        if(self.sideMenuShadowEnabled){
            if(self.sideMenuShadow){
                self.sideMenuShadow.shadowedView = centerViewController.view;
            }else{
                self.sideMenuShadow = [FWSideMenuShadow shadow:centerViewController.view];
            }
        }
    }
}
- (void)setLeftMenuViewController:(UIViewController *)leftMenuViewController{
    [self removeChildViewControllerFromContainer:_leftMenuViewController];
    _leftMenuViewController = leftMenuViewController;
    if(leftMenuViewController){
        [self addChildViewController:leftMenuViewController];
        [leftMenuViewController didMoveToParentViewController:self];
        if(self.isViewHasLoad){
            [self setLeftSideMenuFrameToClosedPosition];
        }
    }
}
- (void)setRightMenuViewController:(UIViewController *)rightMenuViewController{
    [self removeChildViewControllerFromContainer:_rightMenuViewController];
    _rightMenuViewController = rightMenuViewController;
    if(rightMenuViewController){
        [self addChildViewController:rightMenuViewController];
        [rightMenuViewController didMoveToParentViewController:self];
        if(self.isViewHasLoad){
            [self setRightSideMenuFrameToClosedPosition];
        }
    }
}
-(void)setRightSideMenuFrameToClosedPosition{
    if(!self.rightMenuViewController) return;
    CGRect rightFrame = self.rightMenuViewController.view.frame;
    rightFrame.size.width = self.rightMenuWidth;
    rightFrame.origin.y = 0;
    rightFrame.origin.x = self.menuContainerView.frame.size.width - self.rightMenuWidth;
    if(self.menuSlideAnimationEnabled){
        rightFrame.origin.x += self.rightMenuWidth/self.menuSlideAnimationFactor;
    }
    self.rightMenuViewController.view.frame = rightFrame;
    self.rightMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
}
-(void)removeCenterGestureRecognizers{
    if(self.centerViewController){
        [self.centerMaskView removeGestureRecognizer:self.centerTapGestureRecognizer];
        [self.centerMaskView removeGestureRecognizer:self.centerMaskPanGestureRecognizer];
        if(self.centerLeftPanViewWidth > 0){
            [self.centerLeftPanView removeGestureRecognizer:self.centerLeftPanGestureRecognizer];
        }
        if(self.centerRightPanViewWidth > 0){
            [self.centerRightPanView removeGestureRecognizer:self.centerRightPanGestureRecognizer];
        }
    }
}
-(void)removeChildViewControllerFromContainer:(UIViewController *)childViewController{
    if(!childViewController) return;
    [childViewController willMoveToParentViewController:nil];
    [childViewController removeFromParentViewController];
    [childViewController.view removeFromSuperview];
}
-(void)addGestureRecognizers{
    [self addCenterGestureRecognizers];
    [self.menuContainerView addGestureRecognizer:self.sideMenuPanGestureRecognizer];
}
-(void)addCenterGestureRecognizers{
    if(self.centerViewController){
        if (self.centerLeftPanViewWidth > 0) {
            self.centerLeftPanView.frame = CGRectMake(0, 0, self.centerLeftPanViewWidth, UIScreen.mainScreen.bounds.size.height);
            [self.centerViewController.view addSubview:self.centerLeftPanView];
            [self.centerLeftPanView addGestureRecognizer:self.centerLeftPanGestureRecognizer];
        }
        if (self.centerRightPanViewWidth > 0) {
            self.centerRightPanView.frame = CGRectMake(UIScreen.mainScreen.bounds.size.width-self.centerRightPanViewWidth, 0, self.centerRightPanViewWidth, UIScreen.mainScreen.bounds.size.height);
            [self.centerViewController.view addSubview:self.centerRightPanView];
            [self.centerRightPanView addGestureRecognizer:self.centerRightPanGestureRecognizer];
        }
        [self.centerMaskView  addGestureRecognizer:self.centerTapGestureRecognizer];
        [self.centerMaskView addGestureRecognizer:self.centerMaskPanGestureRecognizer];
    }
}
- (void)setSideMenuPanMode:(FWSideMenuPanMode)sideMenuPanMode{
    _sideMenuPanMode = sideMenuPanMode;
    if(sideMenuPanMode == FWSideMenuPanModeNone || sideMenuPanMode == FWSideMenuPanModeSideMenu){
        self.centerLeftPanView.userInteractionEnabled = NO;
        self.centerRightPanView.userInteractionEnabled = NO;
    }else{
        self.centerLeftPanView.userInteractionEnabled = YES;
        self.centerRightPanView.userInteractionEnabled = YES;
    }
}
-(void)setLeftSideMenuFrameToClosedPosition{
    if(!self.leftMenuViewController) return;
    CGRect leftFrame = self.leftMenuViewController.view.frame;
    leftFrame.size.width = self.leftMenuWidth;
    leftFrame.origin.x = self.menuSlideAnimationEnabled ? -leftFrame.size.width/self.menuSlideAnimationFactor : 0;
    leftFrame.origin.y = 0;
    self.leftMenuViewController.view.frame = leftFrame;
    self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([gestureRecognizer isMemberOfClass:UITapGestureRecognizer.class]){
        if(touch.view == self.centerLeftPanView || touch.view == self.centerRightPanView){
            return NO;
        }else{
            if(self.centerTapGestureEnabled){
                return YES;
            }else{
                return NO;
            }
        }
    }else{
        if(self.sideMenuPanMode == FWSideMenuPanModeDefaults){
            return YES;
        }else if(self.sideMenuPanMode == FWSideMenuPanModeNone){
            return NO;
        }else if(self.sideMenuPanMode == FWSideMenuPanModeCenterViewController){
            if(gestureRecognizer == self.centerLeftPanGestureRecognizer || gestureRecognizer == self.centerRightPanGestureRecognizer || gestureRecognizer == self.centerMaskPanGestureRecognizer){
                return YES;
            }else{
                return NO;
            }
        }else if(self.sideMenuPanMode == FWSideMenuPanModeSideMenu){
            if(gestureRecognizer == self.sideMenuPanGestureRecognizer){
                return YES;
            }else{
                return NO;
            }
        }
        return YES;
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}
-(void)centerVCTapAction:(UITapGestureRecognizer*) tap{
    if(self.sideMenuState != FWSideMenuStateClosed){
        [self setSideMenuState:FWSideMenuStateClosed completeBlock:nil];
    }
}
-(void)panAction:(UIPanGestureRecognizer*) pan{
    UIView* view = self.centerViewController.view;
    if(pan.state == UIGestureRecognizerStateBegan){
        self.panGestureOrigin = view.frame.origin;
        self.panGestureDirection = FWSideMenuPanDirectionNone;
    }
    if(self.panGestureDirection == FWSideMenuPanDirectionNone){
        CGPoint translatedPoint = [pan translationInView:view];
        if(translatedPoint.x > 0){
            self.panGestureDirection = FWSideMenuPanDirectionRight;
            if(self.leftMenuViewController != nil && self.sideMenuState == FWSideMenuStateClosed){
                [self leftMenuWillShow];
            }
        }else if(translatedPoint.x < 0){
            self.panGestureDirection = FWSideMenuPanDirectionLeft;
            if (self.rightMenuViewController != nil && self.sideMenuState == FWSideMenuStateClosed) {
                [self rightMenuWillShow];
            }
        }
    }
    if((self.sideMenuState == FWSideMenuStateLeftMenuOpen && self.panGestureDirection == FWSideMenuPanDirectionRight) ||
       (self.sideMenuState == FWSideMenuStateRightMenuOpen && self.panGestureDirection == FWSideMenuPanDirectionLeft)){
        self.panGestureDirection = FWSideMenuPanDirectionNone;
        return;
    }
    if(self.panGestureDirection == FWSideMenuPanDirectionLeft){
        [self handleLeftPan:pan];
    }else if(self.panGestureDirection == FWSideMenuPanDirectionRight){
        [self handleRightPan:pan];
    }
}
-(void)setSideMenuState:(FWSideMenuState)state completeBlock:(FWSideMenuVoidBlock)completeBlock{
    void(^innerCompleteBlock)(void) = ^(){
        typeof(self) wSelf = self;
        wSelf.sideMenuState = state;
        [wSelf setUserInteractionStateForCenterViewController];
        FWSideMenuStateEvent eventType = wSelf.sideMenuState == FWSideMenuStateClosed ? FWSideMenuStateEventDidClose : FWSideMenuStateEventDidOpen;
        [wSelf sendStateEventNotification:eventType];
        if(completeBlock) completeBlock();
    };
    switch (state) {
        case FWSideMenuStateClosed:{
            [self sendStateEventNotification:FWSideMenuStateEventWillClose];
            [self closeSideMenu:innerCompleteBlock];
            break;
        }
        case FWSideMenuStateLeftMenuOpen:{
            if(!self.leftMenuViewController)return;
            [self sendStateEventNotification:FWSideMenuStateEventWillOpen];
            [self leftMenuWillShow];
            [self openLeftSideMenu:innerCompleteBlock];
            break;
        }
        case FWSideMenuStateRightMenuOpen:{
            if(!self.rightMenuViewController)return;
            [self sendStateEventNotification:FWSideMenuStateEventWillOpen];
            [self rightMenuWillShow];
            [self openRightSideMenu:innerCompleteBlock];
            break;
        }
    }
}
-(void)leftMenuWillShow{
    [self.menuContainerView bringSubviewToFront:self.leftMenuViewController.view];
}
-(void)rightMenuWillShow{
    [self.menuContainerView bringSubviewToFront:self.rightMenuViewController.view];
}
-(void)handleLeftPan:(UIPanGestureRecognizer*) pan{
    if(self.rightMenuViewController == nil && self.sideMenuState == FWSideMenuStateClosed){
        return;
    }
    UIView* view = self.centerViewController.view;
    CGPoint translatedPoint = [pan translationInView:view];
    CGPoint adjustedOrigin = self.panGestureOrigin;
    translatedPoint = CGPointMake(adjustedOrigin.x+translatedPoint.x, adjustedOrigin.y+translatedPoint.y);
    translatedPoint.x = MAX(translatedPoint.x, -self.rightMenuWidth);
    translatedPoint.x = MIN(translatedPoint.x, self.leftMenuWidth);
    if(self.sideMenuState == FWSideMenuStateLeftMenuOpen){
        translatedPoint.x = MAX(translatedPoint.x, 0);
    }else{
        translatedPoint.x = MIN(translatedPoint.x, 0);
    }
    if(translatedPoint.x == 0.0){
        [self setSideMenuState:FWSideMenuStateClosed completeBlock:nil];
    }
    if(pan.state == UIGestureRecognizerStateEnded){
        CGPoint velocity = [pan velocityInView:view];
        CGFloat finalX = translatedPoint.x + (velocity.x * 0.35);
        CGFloat viewWidth = view.frame.size.width;
        if(self.sideMenuState == FWSideMenuStateClosed){
            BOOL showMenu = (finalX < -viewWidth/2) || (finalX < -self.rightMenuWidth/2);
            if(showMenu){
                self.panGestureVelocity = velocity.x;
                [self setSideMenuState:FWSideMenuStateRightMenuOpen completeBlock:nil];
            }else{
                self.panGestureVelocity = 0;
                [self setCenterViewControllerOffset:0 animated:YES additionalAnimationsBlock:nil completeBlock:nil];
            }
        }else{
            BOOL hideMenu = finalX < adjustedOrigin.x;
            if(hideMenu){
                self.panGestureVelocity = velocity.x;
                [self setSideMenuState:FWSideMenuStateClosed completeBlock:nil];
            }else{
                self.panGestureVelocity = 0;
                [self setCenterViewControllerOffset:adjustedOrigin.x animated:YES additionalAnimationsBlock:nil completeBlock:nil];
            }
        }
    }else{
        [self setCenterViewControllerOffset:translatedPoint.x time:0];
    }
}
-(void)handleRightPan:(UIPanGestureRecognizer*) pan{
    if(self.leftMenuViewController == nil && self.sideMenuState == FWSideMenuStateClosed){
        return;
    }
    UIView* view = self.centerViewController.view;
    CGPoint translatedPoint = [pan translationInView:view];
    CGPoint adjustedOrigin = self.panGestureOrigin;
    translatedPoint = CGPointMake(adjustedOrigin.x+translatedPoint.x, adjustedOrigin.y+translatedPoint.y);
    translatedPoint.x = MAX(translatedPoint.x, -self.rightMenuWidth);
    translatedPoint.x = MIN(translatedPoint.x, self.leftMenuWidth);
    if(self.sideMenuState == FWSideMenuStateRightMenuOpen){
        translatedPoint.x = MIN(translatedPoint.x, 0);
    }else{
        translatedPoint.x = MAX(translatedPoint.x, 0);
    }
    if(translatedPoint.x == 0.0){
        [self setSideMenuState:FWSideMenuStateClosed completeBlock:nil];
    }
    if(pan.state == UIGestureRecognizerStateEnded){
        CGPoint velocity = [pan velocityInView:view];
        CGFloat finalX = translatedPoint.x + (0.35*velocity.x);
        CGFloat viewWidth = view.frame.size.width;
        if(self.sideMenuState == FWSideMenuStateClosed){
            BOOL showMenu = (finalX > viewWidth/2) || (finalX > self.leftMenuWidth/2);
            if(showMenu){
                self.panGestureVelocity = velocity.x;
                [self setSideMenuState:FWSideMenuStateLeftMenuOpen completeBlock:nil];
            }else{
                self.panGestureVelocity = 0;
                [self setCenterViewControllerOffset:0 animated:YES additionalAnimationsBlock:nil completeBlock:nil];
            }
        }else{
            BOOL hideMenu = (finalX > adjustedOrigin.x);
            if(hideMenu){
                self.panGestureVelocity = velocity.x;
                [self setSideMenuState:FWSideMenuStateClosed completeBlock:nil];
            }else{
                self.panGestureVelocity = 0;
                [self setCenterViewControllerOffset:adjustedOrigin.x animated:YES additionalAnimationsBlock:nil completeBlock:nil];
            }
        }
        self.panGestureDirection = FWSideMenuPanDirectionNone;
    }else{
        [self setCenterViewControllerOffset:translatedPoint.x time:0];
    }
}
-(void)setCenterViewControllerOffset:(CGFloat)offset animated:(BOOL)animated additionalAnimationsBlock:(FWSideMenuVoidBlock)additionalAnimationsBlock completeBlock:(FWSideMenuVoidBlock)completeBlock{
    if(animated){
        int centerViewControllerXPosition = abs((int)self.centerViewController.view.frame.origin.x);
        NSTimeInterval duration = [self animationDurationFromStartPosition:centerViewControllerXPosition endPosition:offset];
        [UIView animateWithDuration:duration animations:^{
            [self setCenterViewControllerOffset:offset time:duration];
            if(additionalAnimationsBlock) additionalAnimationsBlock();
            float foffset = fabsf((float)offset);
            float percent = 0.0;
            if(offset > 0){
                percent = foffset / self.leftMenuWidth;
            }else{
                percent = foffset / self.rightMenuWidth;
            }
            percent = percent*0.4;
            self.centerMaskView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:percent];
        } completion:^(BOOL finished) {
            self.panGestureVelocity = 0.0;
            if(completeBlock) completeBlock();
        }];
    }else{
        [self setCenterViewControllerOffset:offset time:0];
        if(additionalAnimationsBlock) additionalAnimationsBlock();
        self.panGestureVelocity = 0.0;
        if(completeBlock) completeBlock();
    }
}
-(void)setCenterViewControllerOffset:(CGFloat)offset time:(NSTimeInterval)time{
    CGRect rect = self.centerViewController.view.frame;
    self.centerViewController.view.frame = CGRectMake(offset, rect.origin.y, rect.size.width, rect.size.height);
    float foffset = fabsf((float)offset);
    float percent = 0.0;
    if(offset > 0){
        percent = foffset / self.leftMenuWidth;
    }else{
        percent = foffset / self.rightMenuWidth;
    }
    percent = percent*0.4;
    if(foffset > 0 && self.centerMaskView.superview == nil){
        [self.centerViewController.view addSubview:self.centerMaskView];
        [self.centerViewController.view bringSubviewToFront:self.centerMaskView];
    }else if(foffset <= 0 && self.centerMaskView.superview != nil){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.centerMaskView removeFromSuperview];
        });
    }
    if(self.centerMaskViewEnabled && foffset > 0){
        self.centerMaskView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:percent];
    }
    if(!self.menuSlideAnimationEnabled) return;
    if(offset > 0){
        [self alignLeftMenuControllerWithCenterViewController];
        [self setRightSideMenuFrameToClosedPosition];
    }else if(offset < 0){
        [self alignRightMenuControllerWithCenterViewController];
        [self setLeftSideMenuFrameToClosedPosition];
    }else{
        [self setLeftSideMenuFrameToClosedPosition];
        [self setRightSideMenuFrameToClosedPosition];
    }
}
-(void)setUserInteractionStateForCenterViewController{
    if([self.centerViewController respondsToSelector:@selector(childViewControllers)]){
        NSArray* childVCs = self.centerViewController.childViewControllers;
        for(UIViewController* vc in childVCs){
            vc.view.userInteractionEnabled = (self.sideMenuState == FWSideMenuStateClosed);
        }
    }
}
-(void)sendStateEventNotification:(FWSideMenuStateEvent) eventType{
    if(self.centerTapGestureEnabled){
        if(eventType == FWSideMenuStateEventDidClose){
            self.centerTapGestureRecognizer.enabled = NO;
        }else{
            self.centerTapGestureRecognizer.enabled = YES;
        }
    }
    // 广播状态
    [NSNotificationCenter.defaultCenter postNotificationName:FWSideMenuStateNotificationEvent object:self userInfo:@{@"eventType":@(eventType)}];
}
-(void)closeSideMenu:(FWSideMenuVoidBlock)completeBolck{
    [self setCenterViewControllerOffset:0 animated:YES additionalAnimationsBlock:nil completeBlock:completeBolck];
}
-(void)openLeftSideMenu:(FWSideMenuVoidBlock)completeBolck{
    if(!self.leftMenuViewController)return;
    [self.menuContainerView bringSubviewToFront:self.leftMenuViewController.view];
    [self setCenterViewControllerOffset:self.leftMenuWidth animated:YES additionalAnimationsBlock:nil completeBlock:completeBolck];
}
-(void)openRightSideMenu:(FWSideMenuVoidBlock)completeBolck{
    if(!self.rightMenuViewController)return;
    [self.menuContainerView bringSubviewToFront:self.rightMenuViewController.view];
    [self setCenterViewControllerOffset:-self.rightMenuWidth animated:YES additionalAnimationsBlock:nil completeBlock:completeBolck];
}
-(void)toggleLeftSideMenu:(FWSideMenuVoidBlock)completeBolck{
    if ((self.sideMenuState == FWSideMenuStateLeftMenuOpen)) {
        [self setSideMenuState:FWSideMenuStateClosed completeBlock:completeBolck];
    }else{
        [self setSideMenuState:FWSideMenuStateLeftMenuOpen completeBlock:completeBolck];
    }
}
-(void)toggleRightSideMenu:(FWSideMenuVoidBlock)completeBolck{
    if ((self.sideMenuState == FWSideMenuStateRightMenuOpen)) {
        [self setSideMenuState:FWSideMenuStateClosed completeBlock:completeBolck];
    }else{
        [self setSideMenuState:FWSideMenuStateRightMenuOpen completeBlock:completeBolck];
    }
}
-(void)alignLeftMenuControllerWithCenterViewController{
    CGRect leftMenuFrame = self.leftMenuViewController.view.frame;
    leftMenuFrame.size.width = self.leftMenuWidth;
    CGFloat xOffset = self.centerViewController.view.frame.origin.x;
    CGFloat xPositionDivider = self.menuSlideAnimationEnabled ? self.menuSlideAnimationFactor : 1.0;
    leftMenuFrame.origin.x = xOffset/xPositionDivider - self.leftMenuWidth/xPositionDivider;
    self.leftMenuViewController.view.frame = leftMenuFrame;
}
-(void)alignRightMenuControllerWithCenterViewController{
    CGRect rightMenuFrame = self.rightMenuViewController.view.frame;
    rightMenuFrame.size.width = self.rightMenuWidth;
    CGFloat xOffset = self.centerViewController.view.frame.origin.x;
    CGFloat xPositionDivider = self.menuSlideAnimationEnabled ? self.menuSlideAnimationFactor : 1.0;
    rightMenuFrame.origin.x = self.menuContainerView.frame.size.width - self.rightMenuWidth + xOffset/xPositionDivider + self.rightMenuWidth/xPositionDivider;
    self.rightMenuViewController.view.frame = rightMenuFrame;
}

-(NSTimeInterval)animationDurationFromStartPosition:(CGFloat)startPosition endPosition:(CGFloat)endPosition{
    float animationPositionDelta = fabsf((float)(endPosition-startPosition));
    NSTimeInterval duration = 0;
    if(fabsf((float)self.panGestureVelocity) > 1.0){
        duration = animationPositionDelta / fabsf((float)self.panGestureVelocity);
    }else{
        CGFloat menuWidth = MAX(self.leftMenuWidth, self.rightMenuWidth);
        float animationPerecent = (animationPositionDelta == 0) ? 0 : (menuWidth/animationPositionDelta);
        duration = self.menuAnimationDefaultDuration*animationPerecent;
    }
    return MIN(duration, self.menuAnimationMaxDuration);
}
+(FWSlideMenu*)getCurrentSlideMenu:(UIViewController*)vc{
    UIViewController* contrainerVC = vc;
    while (contrainerVC && ![contrainerVC isKindOfClass:FWSlideMenu.class]) {
        if([contrainerVC respondsToSelector:@selector(parentViewController)]){
            contrainerVC = contrainerVC.parentViewController;
        }
    }
    return (FWSlideMenu*)contrainerVC;
}
@end

@implementation FWSideMenuShadow

+(FWSideMenuShadow*)shadow:(UIView*)sdView{
    FWSideMenuShadow* fss = [[FWSideMenuShadow alloc] init];
    fss.shadowedView = sdView;
    return fss;
}
- (void)setEnabled:(BOOL)enabled{
    _enabled = enabled;
    [self draw];
}
- (void)setColor:(UIColor *)color{
    _color = color;
    [self draw];
}
- (void)setOpacity:(CGFloat)opacity{
    _opacity = opacity;
    [self draw];
}
- (void)setRadius:(CGFloat)radius{
    _radius = radius;
    [self draw];
}
- (void)setShadowedView:(UIView *)shadowedView{
    _shadowedView = shadowedView;
    [self draw];
}
-(void)show{
    if(!self.shadowedView)return;
    CGRect pathRect = self.shadowedView.bounds;
    pathRect.size = self.shadowedView.frame.size;
    self.shadowedView.layer.shadowPath = [UIBezierPath bezierPathWithRect:pathRect].CGPath;
    self.shadowedView.layer.shadowOpacity = self.opacity;
    self.shadowedView.layer.shadowRadius = self.radius;
    self.shadowedView.layer.shadowColor = self.color.CGColor;
    self.shadowedView.layer.rasterizationScale = UIScreen.mainScreen.scale;
}
-(void)hide{
    if(!self.shadowedView)return;
    self.shadowedView.layer.shadowOpacity = 0.0;
    self.shadowedView.layer.shadowRadius = 0.0;
}
-(void)draw{
    if(self.enabled){
        [self show];
    }else{
        [self hide];
    }
}
@end
