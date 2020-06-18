//
//  DialogBottomPushInput.h
//  jjrcw
//
//  Created by XiaoTian on 2020/3/12.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DialogBottomPushInput;
@class DialogBottomPushInputTextView;
@protocol DialogBottomPushInputDelegate
@required
-(void)onClickDialogBottomInput:(DialogBottomPushInput*) dialog text:(NSString*)text;
@end

@interface DialogBottomPushInput : UIView
@property(strong,nonatomic) DialogBottomPushInputTextView *textView;
@property(weak,nonatomic) id<DialogBottomPushInputDelegate> delegate;
-(void)show;
-(void)close;
@end

@interface DialogBottomPushInputTextView : UITextView
@property(strong,nonatomic)UILabel *mPlaceHolder;
-(void)setPlaceHolder:(NSString*)placeHolder;
@end

NS_ASSUME_NONNULL_END
