//
//  ViewLoadingCover.h
//  jjrcw
//
//  Created by XiaoTian on 2020/3/20.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum{
    LOADING = 0,
    EMPTY = 1,
    ERROR = 2
} ViewLoadingCoverType;

@protocol ViewLoadingCoverTypeDelegate

@optional
-(void)onClickLoadingCoverReload;

@end

@interface ViewLoadingCover : UIView
//
@property(strong,nonatomic)NSString* textLoading;
@property(strong,nonatomic)NSString* textEmpty;
@property(strong,nonatomic)NSString* textError;
@property(strong,nonatomic)NSString* imageEmpty;
@property(strong,nonatomic)NSString* imageError;
@property(weak,nonatomic)id<ViewLoadingCoverTypeDelegate> delegate;
//
-(void)setType:(ViewLoadingCoverType)viewType;
-(void)remove;

@end

NS_ASSUME_NONNULL_END
