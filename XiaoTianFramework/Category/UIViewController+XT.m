//
//  UIViewController+XT.h
//  XiaoTianFramework
//
//  Created by XiaoTian on 1/14/15.
//  Copyright (c) 2015 XiaoTian. All rights reserved.
//

#import "UIViewController+XT.h"
#import <objc/runtime.h>

@implementation UIViewController (XT)
+ (instancetype)getInstance{
    return [[UIViewController alloc] init];
}

// dynamic Property Associsted Get/Set(not auto property value)
@dynamic callBackViewDidLoad;
-(ViewControllerCallBack) callBackViewDidLoad{
    return objc_getAssociatedObject(self, @selector(callBackViewDidLoad));
}
- (void)setCallBackViewDidLoad:(ViewControllerCallBack)callBackViewDidLoad{
    objc_setAssociatedObject(self, @selector(callBackViewDidLoad), callBackViewDidLoad, OBJC_ASSOCIATION_COPY);
}
@dynamic callBackViewDidAppear;
- (ViewControllerCallBack)callBackViewDidAppear{
    return objc_getAssociatedObject(self, @selector(callBackViewDidAppear));
}
- (void)setCallBackViewDidAppear:(ViewControllerCallBack)callBackViewDidAppear{
     objc_setAssociatedObject(self, @selector(callBackViewDidAppear), callBackViewDidAppear, OBJC_ASSOCIATION_COPY);
}
@dynamic callBackViewWillAppear;
- (ViewControllerCallBack)callBackViewWillAppear{
    return objc_getAssociatedObject(self, @selector(callBackViewWillAppear));
}
- (void)setCallBackViewWillAppear:(ViewControllerCallBack)callBackViewWillAppear{
    objc_setAssociatedObject(self, @selector(callBackViewWillAppear), callBackViewWillAppear, OBJC_ASSOCIATION_COPY);
}
@dynamic callBackViewWillDisappear;
- (ViewControllerCallBack)callBackViewWillDisappear{
    return objc_getAssociatedObject(self, @selector(callBackViewWillDisappear));
}
- (void)setCallBackViewWillDisappear:(ViewControllerCallBack)callBackViewWillDisappear{
    objc_setAssociatedObject(self, @selector(callBackViewWillDisappear), callBackViewWillDisappear, OBJC_ASSOCIATION_COPY);
}
@dynamic callBackViewDidDisappear;
- (ViewControllerCallBack)callBackViewDidDisappear{
    return objc_getAssociatedObject(self, @selector(callBackViewDidDisappear));
}
- (void)setCallBackViewDidDisappear:(ViewControllerCallBack)callBackViewDidDisappear{
    objc_setAssociatedObject(self, @selector(callBackViewDidDisappear), callBackViewDidDisappear, OBJC_ASSOCIATION_COPY);
}
@dynamic callBackDealloc;
- (ViewControllerCallBack)callBackDealloc{
     return objc_getAssociatedObject(self, @selector(callBackDealloc));
}
- (void)setCallBackDealloc:(ViewControllerCallBack)callBackDealloc{
    objc_setAssociatedObject(self, @selector(callBackDealloc), callBackDealloc, OBJC_ASSOCIATION_COPY);
}
@end
