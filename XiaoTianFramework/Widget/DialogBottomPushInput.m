//
//  DialogBottomPushInput.m
//  jjrcw
//
//  Created by XiaoTian on 2020/3/12.
//  Copyright © 2020 jjrw. All rights reserved.
//

#import "DialogBottomPushInput.h"

@interface DialogBottomPushInput()<UITextViewDelegate>
@property(strong,nonatomic)UIView* containerView;
@property(strong,nonatomic)UIButton* btnPositive;
@property(assign,nonatomic)CGRect initFrame;
@end

@implementation DialogBottomPushInput

-(instancetype)init{
    if(self = [super init]){
        CGRect bounds = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3f];
        [self setFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height)];
        [self registerKeyboardNotification];
        [self initView];
        [self setHidden:YES];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self initView];
    [self registerKeyboardNotification];
}

-(void)initView{
    // 背景
    self.containerView = [[UIView alloc]initWithFrame: CGRectMake(0, self.frame.size.height , self.frame.size.width, 49)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.containerView];
    // 分割线
    UIView *horizontalLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 1)];
    [horizontalLine setBackgroundColor:UIColor.lightGrayColor];
    [self.containerView addSubview:horizontalLine];
    // 按钮
    self.btnPositive = [[UIButton alloc]init];
    self.btnPositive.enabled = NO;
    [self.btnPositive setTitle:@"确定" forState:UIControlStateNormal];
    [self.btnPositive.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.btnPositive setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.btnPositive setTitleColor:UIColor.lightGrayColor forState:UIControlStateDisabled];
    [self.btnPositive.titleLabel sizeToFit];
    [self.btnPositive addTarget:self action:@selector(onClickPositive:) forControlEvents:UIControlEventTouchUpInside];
    // 输入框
    self.textView = [[DialogBottomPushInputTextView alloc] initWithFrame:CGRectMake(15, 10, self.bounds.size.width - 45 - self.btnPositive.titleLabel.frame.size.width, 30)];
    self.textView.delegate = self;
    [self.containerView addSubview:self.textView];
    
    CGFloat sendBtnX = self.containerView.frame.size.width - 15 - self.btnPositive.titleLabel.frame.size.width;
    CGFloat sendBtnY = (self.containerView.frame.size.height - self.btnPositive.titleLabel.frame.size.height)/2;
    [self.btnPositive setFrame:CGRectMake(sendBtnX, sendBtnY, self.btnPositive.titleLabel.frame.size.width, self.btnPositive.titleLabel.frame.size.height)];
    [self.containerView addSubview:self.btnPositive];
    //
    self.initFrame = CGRectMake(self.containerView.frame.origin.x, self.containerView.frame.origin.y,
                                self.containerView.frame.size.width, self.containerView.frame.size.height);
}

-(void)textViewDidChange:(UITextView *)textView{
    NSString* text = [textView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self.btnPositive setEnabled: text.length > 0];
}

-(void)onClickPositive:(id)sender{
    if(self.delegate){
        [self.delegate onClickDialogBottomInput:self text:self.textView.text];
    }
    self.textView.text = @"";
    [self setHidden:YES];
    [self.textView resignFirstResponder];
}

-(void)registerKeyboardNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardShow:(NSNotification*)notification{
    CGFloat keyboardHeight = [[[notification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue].size.height;
//    NSLog(@"%f",keyboardHeight);
    [self updateFrame:YES keyboardHeight:keyboardHeight];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [event.allTouches anyObject];
    CGPoint location = [touch previousLocationInView:self];
    if(location.y < self.containerView.frame.origin.y){
        [self endEditing:YES];
        [self setHidden:YES];
    }
}

-(void)updateFrame:(BOOL)keyboardIsShow keyboardHeight:(CGFloat)height{
    CGRect newFrame = self.containerView.frame;
    if(keyboardIsShow){
//        NSLog(@"%f",self.frame.size.height);
        newFrame.origin.y = self.initFrame.origin.y - height - 49;
    }else{
        newFrame.origin.y = self.initFrame.origin.y;
    }
    [self.containerView setFrame:newFrame];
}

-(void)keyboardHide:(NSNotification*)notification{
    CGFloat keyboardHeight = [[[notification userInfo] objectForKey: UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    [self updateFrame:NO keyboardHeight:keyboardHeight];
}
-(void)show{
    [self setHidden:NO];
    [self.textView becomeFirstResponder];
}
-(void)close{
    [self setHidden:YES];
    [self.textView resignFirstResponder];
}
-(void)layoutSubviews{
    CGRect newFrame = self.containerView.frame;
    newFrame.origin.y = newFrame.origin.y - (self.textView.bounds.size.height + 19 - newFrame.size.height);
    newFrame.size.height = self.textView.bounds.size.height + 19;
    [self.containerView setFrame:newFrame];
    
    CGRect commentFrame = self.textView.frame;
    commentFrame.origin.y = (newFrame.size.height - 1 - commentFrame.size.height)/2;
    [self.textView setFrame:commentFrame];
    
    CGRect sendBtnFrame = self.btnPositive.frame;
    sendBtnFrame.origin.y = (newFrame.size.height - sendBtnFrame.size.height)/2;
    [self.btnPositive setFrame:sendBtnFrame];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
@end

@implementation DialogBottomPushInputTextView{
    NSString* _mPlaceHolderText;
    CGFloat _mMaxHeight;
}
-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
         _mMaxHeight = 80;
        [self initView];
    }
    return self;
}

-(void)initView{
    [self setFont:[UIFont systemFontOfSize:14]];
    // 系统TextView的PlaceHolder
    self.mPlaceHolder = [[UILabel alloc]init];
    [self.mPlaceHolder setFont:[UIFont systemFontOfSize:14]];
    [self.mPlaceHolder setTextColor:UIColor.lightGrayColor];
    if(_mPlaceHolderText) self.mPlaceHolder.text = _mPlaceHolderText;
    [self.mPlaceHolder sizeToFit];
    @try {
        [self setValue:self.mPlaceHolder forKey:@"_placeholderLabel"];
    }@catch (NSException *exception) {} @finally {}
    self.contentInset = UIEdgeInsetsZero;
    self.layer.cornerRadius = 3;
    self.layer.borderColor = UIColor.lightGrayColor.CGColor;
    self.layer.borderWidth = 1;
    self.bounces = YES;
}

-(void)insertedEmoji:(NSString*)name{
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    UIImage *emojiImage = [UIImage imageNamed:name];
    textAttachment.image = emojiImage;
    textAttachment.bounds  = CGRectMake(0, -4, emojiImage.size.width, emojiImage.size.height);
    [self.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:textAttachment] atIndex:self.textStorage.length];
}

-(void)layoutSubviews{
    CGFloat fixedWidth = self.frame.size.width;
    CGSize newSize = [self sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = self.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), MIN(newSize.height, _mMaxHeight));
    self.contentSize = CGSizeMake(newFrame.size.width, newSize.height);
    [self setFrame:newFrame];
    [self.superview.superview setNeedsLayout];
}

-(void)setPlaceHolder:(NSString *)placeHolder{
    _mPlaceHolderText = placeHolder;
    if(self.mPlaceHolder){
        self.mPlaceHolder.text = _mPlaceHolderText;
    }
}
@end
