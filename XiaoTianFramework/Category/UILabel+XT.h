//
//  FUILabel+XT.h
//  XiaoTianFramework
//  扩展UILabel
//  Created by XiaoTian on 12/27/14.
//  Copyright (c) 2014 XiaoTian. All rights reserved.
//
#import "Mylog.h"
#import "ConstantsXT.h"
// 声明所有属性默认NONNULL
NS_ASSUME_NONNULL_BEGIN

@interface UILabel (XT)
// 扩展属性

// 扩展方法
/// 设置Label的左右图标
-(void)setIconLeft:(NSString* _Nullable)left iconRight:(NSString* _Nullable )right;
/// 设置Label的文本内容和左右图标
-(void)setText:(NSString* _Nullable)text withIconLeft:(NSString* _Nullable)left iconRight:(NSString* _Nullable)right;
/// 设置固定行间距的文本内容(段落属性,首行缩进,行间距)
-(void)setText:(NSString*)text lineSpacing:(CGFloat)lineSpacing;
/// 设置指定字体大小
-(void)setFont:(UIFont*)font forText:(NSString*)text;
/// 设置指定文字颜色
-(void)setColor:(UIColor*)color forText:(NSString*)text;
/// 设置指定文字背景颜色
-(void)setBackgroundColor:(UIColor*)color forText:(NSString*)text;
/// 设置指定字体文字间距(正加宽,负减小)
-(void)setChatSpace:(CGFloat)space forText:(NSString*)text;
/// 设置指定字体删除线
-(void)setDeleteLine:(UIColor* _Nullable)color forText:(NSString*)text;
/// 设置指定字体下滑线
-(void)setUnderLine:(UIColor*)color forText:(NSString*)text;
/// 设置指定字体画笔大小(负值填充加粗效果，正值中空效果 ),画笔颜色
-(void)setStroke:(CGFloat)width color:(UIColor*)color forText:(NSString*)text;
/// 设置指定字体阴影 (模糊度shadowBlurRadius 阴影颜色shadowColor 阴影偏移shadowOffset) [self setShadow:1 color:UIColor.whiteColor offset:CGSizeMake(3, 3) forText:@"KeyWord"];
-(void)setShadow:(CGFloat)blurRadius color:(UIColor*)color offset:(CGSize)offset forText:(NSString*)text;
/// 设置指定字体基线偏移(字体上偏移, 下偏移 : 正值上偏，负值下偏)
-(void)setBaselineOffset:(CGFloat)offset forText:(NSString*)text;
/// 设置指定文字倾斜(正值右倾，负值左倾)
-(void)setItalic:(CGFloat)offset forText:(NSString*)text;
/// 设置指定文字横向拉伸(正值拉伸文本，负值压缩文本)
-(void)setExpansion:(CGFloat)scale forText:(NSString*)text;
/// 设置指定文字书写方向(0: LRE, 1:RLE, 2:LRO, 3:RLO) NSWritingDirectionLeftToRight | NSTextWritingDirectionEmbedding, NSWritingDirectionLeftToRight | NSTextWritingDirectionOverride
-(void)setDirection:(int)direction forText:(NSString*)text;
/// 设置指定文字超链接
-(void)setLink:(NSURL*)url forText:(NSString*)text;
/// 插入图片到指定文本位置
-(void)insertImage:(UIImage*)image bounds:(CGRect)bounds toIndex:(NSUInteger)index;
/// 设置文字点击(第一个和最后一个字符排除检测范围)
-(void)setClick:(XTAnonymityBlock)click forText:(NSString*)text;

-(void)add:(NSString*)key color:(UIColor*)color clickCallback:(XTAnonymityBlock)callback;

// 必须要设置Text后调用,用于重新计算大小
- (CGFloat) resizeLabel:(UILabel *)theLabel;

- (CGFloat) resizeLabel:(UILabel *)theLabel shrinkViewIfLabelShrinks:(BOOL)canShrink;
/// 更加文本创建图片
-(UIImage*)createSpanImage:(NSString*)text background:(UIColor*)color textSize:(CGFloat)textSize textColor:(UIColor*)textColor;

///设置圆角背景
-(void)setBackgroundRadius:(UIColor*)color radius:(CGFloat)radius;
@end

NS_ASSUME_NONNULL_END
