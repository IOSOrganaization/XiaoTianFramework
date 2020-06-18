//
//  FUILabel+XT.m
//  XiaoTianFramework
//
//  Created by XiaoTian on 12/27/14.
//  Copyright (c) 2014 XiaoTian. All rights reserved.
//

#import "UILabel+XT.h"
@import ObjectiveC.runtime;
@interface UILabelXTUITapGestureRecognizer:UITapGestureRecognizer <UIGestureRecognizerDelegate>
@end
@implementation UILabel (XT)

-(void)setIconLeft:(NSString*)left iconRight:(NSString*)right{
    [self setText:self.text withIconLeft:left iconRight:right];
}
-(void)setText:(NSString*)text withIconLeft:(NSString*)left iconRight:(NSString*)right{
    NSMutableAttributedString *completeText= [[NSMutableAttributedString alloc] initWithString:@""];
    if(left){
        // image left
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
        imageAttachment.image = [UIImage imageNamed:left];
        CGFloat imageOffsetY = -3.0;
        imageAttachment.bounds = CGRectMake(0, imageOffsetY, imageAttachment.image.size.width, imageAttachment.image.size.height);
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        [completeText appendAttributedString:attachmentString];
    }
    if(text){
        // text
        NSMutableAttributedString *textAfterIcon= [[NSMutableAttributedString alloc] initWithString:text];
        [completeText appendAttributedString:textAfterIcon];
    }else{
        NSMutableAttributedString *textAfterIcon= [[NSMutableAttributedString alloc] initWithString:self.text];
        [completeText appendAttributedString:textAfterIcon];
    }
    if(right){
        // image right
        NSTextAttachment *imageAttachment = [[NSTextAttachment alloc] init];
        imageAttachment.image = [UIImage imageNamed:right];
        CGFloat imageOffsetY = -3.0;
        imageAttachment.bounds = CGRectMake(0, imageOffsetY, imageAttachment.image.size.width, imageAttachment.image.size.height);
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:imageAttachment];
        [completeText appendAttributedString:attachmentString];
    }
    self.textAlignment=NSTextAlignmentRight;
    self.attributedText=completeText;
}
-(void)setText:(NSString*)text lineSpacing:(CGFloat)lineSpacing{
    if (!text) {
        self.text = @"";
        return;
    }
    self.numberOfLines = 0;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpacing;  //设置行间距
    paragraphStyle.lineBreakMode = self.lineBreakMode;
    paragraphStyle.alignment = self.textAlignment;
    paragraphStyle.firstLineHeadIndent = 0;//第一行缩进
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, [text length])];//NSMutableAttributedString字体大小会变
    self.attributedText = attributedString;
}
-(void)setFont:(UIFont*)font forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    [attributedString addAttribute:NSFontAttributeName value:font range:[[attributedString string] rangeOfString:text]];
    self.attributedText = attributedString;
}
-(void)setColor:(UIColor*)color forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:[[attributedString string] rangeOfString:text]];
    self.attributedText = attributedString;
}
-(void)setBackgroundColor:(UIColor*)color forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    [attributedString addAttribute:NSBackgroundColorAttributeName value:color range:[[attributedString string] rangeOfString:text]];
    self.attributedText = attributedString;
}
-(void)setChatSpace:(CGFloat)space forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    //[attributedString addAttribute:NSLigatureAttributeName value:@(0) range:[[attributedString string] rangeOfString:text]];//连体字符,0 表示没有连体字符，1 表示使用默认的连体字符
    [attributedString addAttribute:NSKernAttributeName value:@(space) range:[[attributedString string] rangeOfString:text]];
    self.attributedText = attributedString;
}
-(void)setDeleteLine:(UIColor*)color forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    NSRange range = [[attributedString string] rangeOfString:text];
    [attributedString addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];//NSUnderlineStyle线条样式:单线,双线,粗线,
    if(color) [attributedString addAttribute:NSStrikethroughColorAttributeName value:color range:range];
    self.attributedText = attributedString;
}
-(void)setUnderLine:(UIColor*)color forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    NSRange range = [[attributedString string] rangeOfString:text];
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
    if(color) [attributedString addAttribute:NSUnderlineColorAttributeName value:color range:range];
    self.attributedText = attributedString;
}
-(void)setStroke:(CGFloat)width color:(UIColor*)color forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    NSRange range = [[attributedString string] rangeOfString:text];
    [attributedString addAttribute:NSStrokeWidthAttributeName value:@(width) range:range];
    if(color) [attributedString addAttribute:NSStrokeColorAttributeName value:color range:range];
    self.attributedText = attributedString;
}
-(void)setShadow:(CGFloat)blurRadius color:(UIColor*)color offset:(CGSize)offset forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    NSShadow* shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = blurRadius;
    shadow.shadowColor = color;
    shadow.shadowOffset = offset;
    [attributedString addAttribute:NSShadowAttributeName value:shadow range:[[attributedString string] rangeOfString:text]];
    self.attributedText = attributedString;
}
-(void)setBaselineOffset:(CGFloat)offset forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    [attributedString addAttribute:NSBaselineOffsetAttributeName value:@(offset) range:[[attributedString string] rangeOfString:text]];
    self.attributedText = attributedString;
}
-(void)setItalic:(CGFloat)offset forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    [attributedString addAttribute:NSObliquenessAttributeName value:@(offset) range:[[attributedString string] rangeOfString:text]];
    self.attributedText = attributedString;
}
-(void)setExpansion:(CGFloat)scale forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    [attributedString addAttribute:NSExpansionAttributeName value:@(scale) range:[[attributedString string] rangeOfString:text]];
    self.attributedText = attributedString;
}
-(void)setDirection:(int)direction forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    //[attributedString addAttribute:NSVerticalGlyphFormAttributeName value:@(3) range:[[attributedString string] rangeOfString:text]];
    [attributedString addAttribute:NSWritingDirectionAttributeName value:@[@(direction)] range:[[attributedString string] rangeOfString:text]];
    self.attributedText = attributedString;
}
-(void)setLink:(NSURL*)url forText:(NSString*)text{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    [attributedString addAttribute:NSLinkAttributeName value:url range:[[attributedString string] rangeOfString:text]];
    self.attributedText = attributedString;
}
-(void)insertImage:(UIImage*)image bounds:(CGRect)bounds toIndex:(NSUInteger)index{
    NSMutableAttributedString *attributedString;
    if(self.attributedText){
        attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }else{
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    NSTextAttachment* attachmentImage = [[NSTextAttachment alloc] init];
    attachmentImage.image = image;
    if(CGRectEqualToRect(bounds, CGRectZero)){
        attachmentImage.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    }else{
        attachmentImage.bounds = bounds;
    }
    [attributedString insertAttributedString:[NSAttributedString attributedStringWithAttachment:attachmentImage] atIndex:index];
    self.attributedText = attributedString;
}
-(void)setClick:(XTAnonymityBlock)click forText:(NSString*)text{
    self.userInteractionEnabled = YES;// UITapGestureRecognizer可能被父类View拦截
    self.backgroundColor = UIColor.yellowColor;
    NSRange range;
    NSUInteger length;
    if(self.attributedText && self.attributedText.string.length > 0){
        range = [[self.attributedText string] rangeOfString:text];
        length = self.attributedText.string.length;
    }else{
        range = [self.text rangeOfString:text];
        length = self.text.length;
    }
    if(range.location == 0) range = NSMakeRange(1, range.length-1);
    if(range.location+range.length >= length) range = NSMakeRange(range.location-1, range.length-1);
    if(range.length == 0) {
        [Mylog info:@"not found text in uilable attributedText and text"];
        return;
    }
    UITapGestureRecognizer* tap = [[UILabelXTUITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleOnClickLabelContent:)];
    objc_setAssociatedObject(tap, @selector(setClick:forText:), [NSValue valueWithRange:range], OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(tap, @selector(handleOnClickLabelContent:), click, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addGestureRecognizer:tap];
}
-(void)handleOnClickLabelContent:(UITapGestureRecognizer*) tapGesture{
    NSLayoutManager* layoutManager = [[NSLayoutManager alloc] init];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = NSLineBreakByCharWrapping;//必须以NSLineBreakByCharWrapping/NSLineBreakByWordWrapping,self.lineBreakMode;
    textContainer.maximumNumberOfLines = self.numberOfLines;
    textContainer.size = self.bounds.size;
    // 查找点击位置
    CGPoint locationOfTouchInLabel = [tapGesture locationInView:tapGesture.view];
    CGSize labelSize = tapGesture.view.bounds.size;
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
    CGPoint textContainerOffset = CGPointMake((labelSize.width-textBoundingBox.size.width)*0.5 - textBoundingBox.origin.x, (labelSize.height-textBoundingBox.size.height)*0.5 - textBoundingBox.origin.y);
    CGPoint locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x-textContainerOffset.x, locationOfTouchInLabel.y-textContainerOffset.y);
    NSInteger indexOfCharacter = [layoutManager characterIndexForPoint:locationOfTouchInTextContainer inTextContainer:textContainer fractionOfDistanceBetweenInsertionPoints:nil];
    //
    NSRange linkRange = [objc_getAssociatedObject(tapGesture, @selector(setClick:forText:)) rangeValue];
    if(NSLocationInRange(indexOfCharacter, linkRange)){
        XTAnonymityBlock block = objc_getAssociatedObject(tapGesture, @selector(handleOnClickLabelContent:));
        if(block) block();
    }
}
-(void)add:(NSString*)key color:(UIColor*)color clickCallback:(XTAnonymityBlock)callback{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    NSRange range = [attributedString.string rangeOfString:key];
    //设置链接文本
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:range];
    [attributedString addAttribute:NSLinkAttributeName value:@"http://www.baidu.com" range:range];
//    [attributedString addAttribute:NSLinkAttributeName value:@"http://www.163.com" range:[[attributedString string] rangeOfString:bLink]];
//
//    [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:[[attributedString string] rangeOfString:link]];
//
//    //设置链接样式
//    self.linkTextAttributes = @{NSForegroundColorAttributeName: [UIColor redColor], NSUnderlineColorAttributeName: [UIColor clearColor], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
//
    self.attributedText = attributedString;
    
}
///
- (CGFloat) resizeLabel:(UILabel *)theLabel shrinkViewIfLabelShrinks:(BOOL)canShrink {
    CGRect frame = [theLabel frame];
    CGSize size = [theLabel.text sizeWithFont:theLabel.font constrainedToSize:CGSizeMake(frame.size.width, 9999) lineBreakMode:UILineBreakModeWordWrap];
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
- (UIImage *)createSpanImage:(NSString *)text background:(UIColor *)color textSize:(CGFloat)textSize textColor:(UIColor *)textColor{
    UIFont* font = [UIFont systemFontOfSize:textSize];
    CGSize fontSize = [text boundingRectWithSize: CGSizeMake(MAXFLOAT, 19) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    CGSize size = CGSizeMake(fontSize.width+8, 19);
    //UIGraphicsBeginImageContext(size);文字模糊
    UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen]scale]);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetAllowsFontSmoothing(context, YES);
    //画圆角背景色
    [self addRoundRect:context rect:CGRectMake(0, 0, size.width, size.height) radius:3];
    //画文字
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSTextAlignmentCenter];
    [text drawInRect:CGRectMake((size.width-fontSize.width)/2, (size.height-fontSize.height)/2, fontSize.width, fontSize.height) withAttributes:@{NSParagraphStyleAttributeName:style,NSFontAttributeName:font,NSForegroundColorAttributeName:textColor}];
    UIImage* colorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return colorImg;
}
-(void)addRoundRect:(CGContextRef)context rect:(CGRect)rect radius:(CGFloat) radius{
    float x1=rect.origin.x;
    float y1=rect.origin.y;
    float x2=x1+rect.size.width;
    float y2=y1;
    float x3=x2;
    float y3=y1+rect.size.height;
    float x4=x1;
    float y4=y3;
    CGContextMoveToPoint(context, x1, y1+radius);
    CGContextAddArcToPoint(context, x1, y1, x1+radius, y1, radius);
    CGContextAddArcToPoint(context, x2, y2, x2, y2+radius, radius);
    CGContextAddArcToPoint(context, x3, y3, x3-radius, y3, radius);
    CGContextAddArcToPoint(context, x4, y4, x4, y4-radius, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
}
-(void)setBackgroundRadius:(UIColor*)color radius:(CGFloat)radius{
    self.layer.backgroundColor = [UIColor grayColor].CGColor;
    self.layer.cornerRadius = radius;
}
@end

@implementation UILabelXTUITapGestureRecognizer
- (instancetype)initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        self.delegate = self;
    }
    return self;
}

// 响应所有的UIGestureRecognizer事件(多个)
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
@end
