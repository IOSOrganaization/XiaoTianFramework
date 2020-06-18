//
//  DialogBottomPush.h
//  jjrcw
//
//  Created by XiaoTian on 2020/3/12.
//  Copyright © 2020 XiaoTian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DialogBottomPush;

@protocol DialogBottomPushDeletgate <NSObject>
@required
-(void)onClickItemDialogBottom:(DialogBottomPush*) dialog item:(NSInteger) position;
@end
// [[[DialogBottomPush alloc] init:@[@"同意",@"不同意并退出"] delegate:nil] show];
@interface DialogBottomPush : UIView
@property(weak,nonatomic) id<DialogBottomPushDeletgate> delegate;
-(instancetype)init: (NSArray<NSString*>*) items delegate:(id<DialogBottomPushDeletgate>)delegate;

-(void)show;
-(void)close;
@end

NS_ASSUME_NONNULL_END
