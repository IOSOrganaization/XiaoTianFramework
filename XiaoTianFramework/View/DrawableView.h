//
//  DrawableView.h
//  qiqidu
//  画图View
//  Created by XiaoTian on 2019/9/28.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BoxScaleFactor 2.0
#define PointsCountThreshold 500
typedef struct ImageCreationResponse ImageCreationResponse;//预声明
//
typedef NSInteger ImageCreationRequestIdentifier;
typedef void(^StringGenerationBlock)(ImageCreationResponse response);
typedef void(^CreationCallback)(ImageCreationResponse response);

NS_ASSUME_NONNULL_BEGIN
@protocol DrawableViewDelegate <NSObject>
-(void)setDrawing:(BOOL)isDrawing;
@end

struct ImageCreationResponse {
    UIImage* image;
    ImageCreationRequestIdentifier requestID;
};

@interface Brush : NSObject
@property(assign,nonatomic)CGFloat width;
@property(assign,nonatomic)CGFloat transparency;
@property(strong,nonatomic)UIColor* color;
-(instancetype) init:(CGFloat)strokeWidth strokeColor:(UIColor*)strokeColor strokeTransparency:(CGFloat) strokeTransparency;
-(void)drawPath:(NSArray*) points ctx:(CGContextRef) ctx;
@end

@interface Stroke : NSObject
@property(strong,nonatomic)NSMutableArray* points;
@property(strong,nonatomic)Brush* brush;
-(instancetype)init:(CGPoint) point brush:(Brush*) brush;
@end

@interface StrokeCollection : NSObject
@property(strong,nonatomic)NSMutableArray<Stroke*>* strokes;
@property(assign,nonatomic)NSUInteger totalPointCount;
@property(assign,nonatomic)NSUInteger strokeCount;
@property(assign,nonatomic)BOOL isEmpty;
@property(assign,nonatomic)CGPoint lastPoint;
@property(strong,nonatomic)Brush* lastBrush;
@property(assign,nonatomic)NSUInteger lastStrokePointCount;
-(void)newStroke:(CGPoint)initialPoint brush:(Brush*) brush;
-(void)addPointToLastStroke:(CGPoint)point;
-(void)removeLastStroke;
-(StrokeCollection*)splitInTwo:(NSUInteger) numPoints;
-(void)clear;
-(void) draw:(CGContextRef) context;
@end

@interface LatestStrokeCollection : StrokeCollection
@property(assign,nonatomic)NSUInteger transferrablePointCount;
@property(assign,nonatomic)BOOL pointsOfLastStrokeAreTransferrable;
@end

@interface DrawableView : UIView
@property(weak,nonatomic)id<DrawableViewDelegate> delegate;
@property(assign,nonatomic)BOOL containsDrawing;
@property(strong,nonatomic)StrokeCollection* _Nullable strokes;
@property(strong,nonatomic)LatestStrokeCollection* _Nullable latestStrokes;
@property(strong,nonatomic)StrokeCollection* _Nullable strokesWaitingForImage;
@property(strong,nonatomic)UIImage* _Nullable previousStrokesImage;
@property(assign,nonatomic)ImageCreationRequestIdentifier nextImageCreationRequestId;
@property(assign,nonatomic)ImageCreationRequestIdentifier pendingImageCreationRequestId;
//
@property(assign,nonatomic)CGFloat strokeWidth;
@property(strong,nonatomic)UIColor* strokeColor;
@property(assign,nonatomic)CGFloat strokeTransparency;

-(UIImage*) saveAsImage;
@end

NS_ASSUME_NONNULL_END
