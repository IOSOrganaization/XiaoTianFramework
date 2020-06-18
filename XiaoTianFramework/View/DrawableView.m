//
//  DrawableView.m
//  qiqidu
//
//  Created by XiaoTian on 2019/9/28.
//  Copyright © 2019 XiaoTian. All rights reserved.
//

#import "DrawableView.h"
@implementation DrawableView
- (BOOL)containsDrawing{
    return !self.strokes.isEmpty;
}
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.strokeWidth = 4.0;
        self.strokeColor = UIColor.redColor;
        self.strokeTransparency = 1.0;
        self.strokes = [[StrokeCollection alloc] init];
        self.latestStrokes = [[LatestStrokeCollection alloc] init];
        self.nextImageCreationRequestId = 0;
    }
    return self;
}
// 触摸事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.delegate) [self.delegate setDrawing:YES];
    if(touches.count > 0){
        UITouch* touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        Brush* brush = [[Brush alloc] init:self.strokeWidth strokeColor:self.strokeColor strokeTransparency:self.strokeTransparency];
        [self.strokes newStroke:point brush:brush];
        [self.latestStrokes newStroke:point brush:brush];
    }
}
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(touches.count > 0){
        UITouch* touch = [touches anyObject];
        [self drawFromTouch:touch];
    }
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if(self.delegate) [self.delegate setDrawing:NO];
    if(touches.count > 0){
        UITouch* touch = [touches anyObject];
        [self drawFromTouch:touch];
    }
}
// 返回上一步
-(void)undo{
    self.strokesWaitingForImage = nil;
    self.pendingImageCreationRequestId = 0;
    if(!self.strokes.isEmpty){
        [self.strokes removeLastStroke];
        [self.latestStrokes clear];
        self.previousStrokesImage = [self createImage:self.strokes size: self.bounds.size];
        [self.layer setNeedsLayout];
    }
}
-(void)drawFromTouch:(UITouch*) touch{
    CGPoint point = [touch locationInView:self];
    CGPoint previousPoint = self.strokes.lastPoint;
    Brush* brush = self.strokes.lastBrush;
    if(brush){
        [self.strokes addPointToLastStroke:point];
        [self.latestStrokes addPointToLastStroke:point];
        BOOL overThreshold = self.latestStrokes.transferrablePointCount >= PointsCountThreshold;
        if(overThreshold){
            StrokeCollection* strokesToMakeImage = [self.latestStrokes splitInTwo:self.latestStrokes.transferrablePointCount];
            NSInteger requestID = self.nextImageCreationRequestId;
            CreationCallback imageCreationBlock = ^(ImageCreationResponse response){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (requestID == response.requestID) {
                        self.strokesWaitingForImage = nil;
                        self.pendingImageCreationRequestId = 0;
                        self.previousStrokesImage = response.image;
                    }
                });
            };
            self.pendingImageCreationRequestId = requestID;
            self.strokesWaitingForImage = strokesToMakeImage;
            self.nextImageCreationRequestId += 1;
            [self createImageAsynchronously:strokesToMakeImage image:self.previousStrokesImage size:self.bounds.size requestID:requestID callback:imageCreationBlock];
        }
        [self redrawLayerInBoundingBoxOfLastLine:previousPoint point:point brushWidth:brush.width];
    }
}
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
    if(self.strokes.isEmpty) return;
    CGImageRef img = self.previousStrokesImage.CGImage;
    if(img){
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, 0, CGImageGetHeight(img));
        CGContextScaleCTM(ctx, 1.0, -1.0);
        CGContextDrawImage(ctx, CGRectMake(0, 0, CGImageGetWidth(img), CGImageGetHeight(img)), img);
        CGContextRestoreGState(ctx);
    }
    [self.strokesWaitingForImage draw:ctx];;
    [self.latestStrokes draw:ctx];
}
-(UIImage*)createImage:(StrokeCollection*)strokes size:(CGSize)size{
    return [self createImage:strokes image:nil size:size];
}
-(UIImage*)createImage:(StrokeCollection*)strokes image:(UIImage*)image size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if(!ctx) return nil;
    CGImageRef cgImage = image.CGImage;
    if(image && cgImage){
        CGContextSaveGState(ctx);
        CGContextTranslateCTM(ctx, 0.0, image.size.height);
        CGContextScaleCTM(ctx, 1.0, -1.0);
        CGContextDrawImage(ctx, CGRectMake(0, 0, image.size.width, image.size.height), cgImage);
        CGContextRestoreGState(ctx);
    }
    [self.strokes draw:ctx];
    UIImage* imageResult = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageResult;
}
-(void)redrawLayerInBoundingBoxOfLastLine:(CGPoint)previousPoint point:(CGPoint)point brushWidth:(CGFloat)brushWidth{
    CGMutablePathRef subPath = CGPathCreateMutable();
    CGPathMoveToPoint(subPath, nil, previousPoint.x, previousPoint.y);
    CGPathAddLineToPoint(subPath, nil, point.x, point.y);
    CGRect drawBox = CGPathGetPathBoundingBox(subPath);
    drawBox.origin.x -= brushWidth * BoxScaleFactor;
    drawBox.origin.y -= brushWidth * BoxScaleFactor;
    drawBox.size.width += brushWidth * BoxScaleFactor*2;
    drawBox.size.height += brushWidth *BoxScaleFactor*2;
    [self.layer setNeedsDisplayInRect:drawBox];
}
-(void)createImageAsynchronously:(StrokeCollection*)strokes image:(UIImage*)image size:(CGSize)size requestID:(ImageCreationRequestIdentifier)requestID callback:(CreationCallback)callback{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage* image = [self createImage:strokes size:size];
        ImageCreationResponse response = {.image = image, .requestID = requestID};
        callback(response);
    });
}
-(UIImage*) saveAsImage{
    CGSize size = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(size, YES, [UIScreen mainScreen].scale);//大小,不透明,拉伸密度
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];//渲染到上下文
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end

@implementation Brush

- (instancetype)init:(CGFloat)strokeWidth strokeColor:(UIColor *)strokeColor strokeTransparency:(CGFloat)strokeTransparency{
    self = [super init];
    if (self) {
        self.width = strokeWidth;
        self.color = strokeColor;
        self.transparency = strokeTransparency;
    }
    return self;
}

- (void)drawPath:(NSArray *)points ctx:(CGContextRef)ctx{
    if(points.count < 1) return;
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineWidth(ctx, self.width);
    CGContextSetStrokeColorWithColor(ctx, [[self.color colorWithAlphaComponent:self.transparency] CGColor]);
    CGContextBeginPath(ctx);
    CGPoint lastPoint = [points[0] CGPointValue];
    for (int i=0; i<points.count; i++) {
        CGPoint point = [points[i] CGPointValue];
        CGContextMoveToPoint(ctx, lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(ctx, point.x, point.y);
        lastPoint = point;
    }
    CGContextStrokePath(ctx);
}
@end

@implementation Stroke
-(instancetype)init:(CGPoint) point brush:(Brush*) brush{
    self = [super init];
    if (self) {
        self.points = @[[NSValue valueWithCGPoint:point]].mutableCopy;
        self.brush = brush;
    }
    return self;
}

@end

@implementation StrokeCollection

- (NSUInteger)strokeCount{
    return self.strokes.count;
}
- (BOOL)isEmpty{
    return self.strokes.count == 0;
}
- (CGPoint)lastPoint{
    if(!self.strokes.lastObject.points) return CGPointZero;
    return [self.strokes.lastObject.points.lastObject CGPointValue];
}
- (Brush *)lastBrush{
    return self.strokes.lastObject.brush;
}
- (NSUInteger)lastStrokePointCount{
    if(!self.strokes.lastObject) return 0;
    return self.strokes.lastObject.points.count;
}
- (instancetype)init{
    self = [super init];
    if (self) {
        self.strokes = [[NSMutableArray alloc] init];
    }
    return self;
}
-(void)newStroke:(CGPoint)initialPoint brush:(Brush*) brush{
    Stroke* stroke = [[Stroke alloc] init:initialPoint brush:brush];
    [self.strokes addObject:stroke];
    self.totalPointCount += stroke.points.count;
}
-(void)addPointToLastStroke:(CGPoint)point{
    [self.strokes.lastObject.points addObject:[NSValue valueWithCGPoint:point]];
    self.totalPointCount += 1;
}
-(void)removeLastStroke{
    if(self.strokes.lastObject){
        self.totalPointCount -= self.strokes.lastObject.points.count;
        [self.strokes removeLastObject];
    }
}
-(void) draw:(CGContextRef) context{
    for (Stroke* stroke in self.strokes) {
        [stroke.brush drawPath:stroke.points ctx:context];
    }
}
-(void)clear{
    [self.strokes removeAllObjects];
    self.totalPointCount = 0;
}
-(StrokeCollection*)splitInTwo:(NSUInteger) numPoints{
    StrokeCollection* newCollection = [[StrokeCollection alloc] init];
    if(self.totalPointCount > 0){
        NSUInteger pointsLeft = MIN(numPoints, self.totalPointCount);
        while (pointsLeft > 0) {
            Stroke* strokeToTransferFrom = self.strokes.firstObject;
            if(!strokeToTransferFrom) break;
            NSUInteger strokePointCount = strokeToTransferFrom.points.count;
            if(strokePointCount < pointsLeft){
                [self.strokes removeObjectAtIndex:0];
                [newCollection.strokes addObject:strokeToTransferFrom];
                newCollection.totalPointCount += strokePointCount;
                self.totalPointCount -= strokePointCount;
                pointsLeft -= strokePointCount;
            }else{
                Stroke* strokeBeforeSplit = [[Stroke alloc] init:CGPointZero brush:strokeToTransferFrom.brush];
                NSArray* pointsBeforeSplit = [NSArray arrayWithArray:[strokeToTransferFrom.points subarrayWithRange:NSMakeRange(0, pointsLeft)]];
                strokeBeforeSplit.points = pointsBeforeSplit.mutableCopy;
                [newCollection.strokes addObject:strokeBeforeSplit];
                BOOL duplicateSplitPoint = self.strokes.count == 1 || pointsLeft < strokePointCount;
                NSUInteger pointsToDrop = pointsLeft - (duplicateSplitPoint ? 1 : 0);
                NSArray* pointsAfterSplit = [NSArray arrayWithArray:[strokeToTransferFrom.points subarrayWithRange:NSMakeRange(pointsToDrop, strokeToTransferFrom.points.count-pointsToDrop)]];
                strokeToTransferFrom.points = pointsAfterSplit.mutableCopy;
                newCollection.totalPointCount += pointsLeft;
                self.totalPointCount -= pointsToDrop;
                pointsLeft = 0;
            }
        }
    }
    return newCollection;
}
@end

@implementation LatestStrokeCollection
- (instancetype)init{
    self = [super init];
    if (self) {
        self.transferrablePointCount = 0;
    }
    return self;
}
- (BOOL)pointsOfLastStrokeAreTransferrable{
    if(!self.lastBrush) return YES;
    return self.lastBrush.transparency >= 1.0;
}
-(void)newStroke:(CGPoint)initialPoint brush:(Brush*) brush{
    NSUInteger newTransferrablePoints = !self.pointsOfLastStrokeAreTransferrable ? self.lastStrokePointCount : 0;
    [super newStroke:initialPoint brush:brush];
    newTransferrablePoints += self.pointsOfLastStrokeAreTransferrable ? self.lastStrokePointCount : 0;
    self.transferrablePointCount += newTransferrablePoints;
}
-(void)addPointToLastStroke:(CGPoint)point{
    [super addPointToLastStroke:point];
    self.transferrablePointCount += self.pointsOfLastStrokeAreTransferrable ? 1 : 0;
}
-(void)removeLastStroke{
    BOOL lastStrokesPointsWereTransferrable = self.pointsOfLastStrokeAreTransferrable;
    [super removeLastStroke];
    self.transferrablePointCount -= lastStrokesPointsWereTransferrable ? self.lastStrokePointCount : 0;
    self.transferrablePointCount -= !self.pointsOfLastStrokeAreTransferrable ? self.lastStrokePointCount : 0;
}
-(StrokeCollection*)splitInTwo:(NSUInteger) numPoints{
    StrokeCollection* newCollection = [super splitInTwo:numPoints];
    self.transferrablePointCount = 0;
    for (Stroke* stroke in [self.strokes subarrayWithRange:NSMakeRange(0, self.strokes.count-1)]) {
        self.transferrablePointCount += stroke.points.count;
    }
    self.transferrablePointCount += self.pointsOfLastStrokeAreTransferrable ? self.lastStrokePointCount : 0;
    return newCollection;
}
-(void)clear{
    [super clear];
    self.transferrablePointCount = 0;
}
@end
