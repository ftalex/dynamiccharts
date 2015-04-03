//
//  NCIZoomGraphView.m
//  NCIChart
//
//  Created by Ira on 1/27/14.
//  Copyright (c) 2014 FlowForwarding.Org. All rights reserved.
//

#import "NCIZoomGraphView.h"
#import "NCISimpleGridView.h"

@interface NCIZoomGraphView(){
    UIScrollView *gridScroll;
}

@end

@implementation NCIZoomGraphView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIPinchGestureRecognizer *croperViewGessture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(croperViewScale:)];
        [self addGestureRecognizer:croperViewGessture];
    }
    return self;
}

-(void)croperViewScale:(id)sender
{
    if (self.chart.dataCount == 0)
        return;
    if([(UIPinchGestureRecognizer *)sender state]==UIGestureRecognizerStateBegan)
    {
        
        if ([sender numberOfTouches] == 2) {
            CGPoint point1 = [(UIPinchGestureRecognizer *)sender locationOfTouch:0 inView:self];
            CGPoint point2 = [(UIPinchGestureRecognizer *)sender locationOfTouch:1 inView:self];
            [self startMoveWithPoint:point1 andPoint:point2];
        }
    }
    if ([(UIPinchGestureRecognizer *)sender state] == UIGestureRecognizerStateChanged) {
        if ([sender numberOfTouches] == 2) {
            CGPoint point1 = [(UIPinchGestureRecognizer *)sender locationOfTouch:0 inView:self];
            CGPoint point2 = [(UIPinchGestureRecognizer *)sender locationOfTouch:1 inView:self];
            [self moveRangesWithPoint:point1 andPoint:point2];
        }
    }
    
}

static float startFingersDiff;
static float startRangesDiff;
static float startMinRangeVal;
static float startMaxRangeVal;

- (void)startMoveWithPoint:(CGPoint) point1 andPoint:(CGPoint) point2{
    startFingersDiff = point1.x - point2.x;
    startRangesDiff = self.chart.maxRangeVal - self.chart.minRangeVal;
    startMinRangeVal = self.chart.minRangeVal;
    startMaxRangeVal = self.chart.maxRangeVal;
}

- (void)moveRangesWithPoint:(CGPoint) point1 andPoint:(CGPoint) point2{
    float newFingersDiff = point1.x - point2.x;
    float newRangesDiffs = startRangesDiff * newFingersDiff/startFingersDiff;
    double oneSideShiftRange = (startRangesDiff  - newRangesDiffs)/2;
    
    double newMin = startMinRangeVal - oneSideShiftRange;
    if (newMin  < self.chart.minX){
        newMin  = self.chart.minX;
    }
    double newMax = startMaxRangeVal + oneSideShiftRange;
    if (newMax  > self.chart.maxX){
        newMax  = self.chart.maxX;
    }
    if (newMin >= newMax || ((newMax - newMin) < 0.000005) )
        return;
    self.chart.minRangeVal = newMin;
    self.chart.maxRangeVal = newMax;

    [self setNeedsLayout];

}

- (void)addSubviews{
    gridScroll = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [gridScroll setShowsVerticalScrollIndicator:NO];
    [self addSubview:gridScroll];
    gridScroll.delegate = self;
    self.grid = [[NCISimpleGridView alloc] initWithGraph:self];
    [gridScroll addSubview:self.grid];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.chart.chartData.count == 0)
        return;
    float rangesPeriod = [self getRangesPeriod];
    
    float offsetForRanges = scrollView.contentOffset.x;
    if (offsetForRanges < 0)
        offsetForRanges = 0;
    if (offsetForRanges > (scrollView.contentSize.width - scrollView.frame.size.width))
        offsetForRanges = scrollView.contentSize.width - scrollView.frame.size.width;
    
    float newMinRange = [self getArgumentByX:0];
    if (self.chart.xAxis.nciAxisDecreasing){
        self.chart.maxRangeVal = newMinRange;
        self.chart.minRangeVal = newMinRange - rangesPeriod;
    } else {
        self.chart.minRangeVal = newMinRange;
        self.chart.maxRangeVal = newMinRange + rangesPeriod;
    }
    
    self.grid.frame = CGRectMake(gridScroll.contentOffset.x, 0, self.gridWidth, self.gridHeigth);
    
    [self setNeedsLayout];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.chart.dataCount == 0)
        return;
    float scaleIndex = [self getScaleIndex];
    float contentWidth = self.gridWidth* scaleIndex;
    float timeDiff = self.chart.maxX - self.chart.minX;
    if (timeDiff == 0)
        timeDiff = 1000*60*2;
    
    float stepX = contentWidth/timeDiff;
    gridScroll.frame = CGRectMake(0, 0, self.gridWidth, self.gridHeigth);
    gridScroll.contentSize = CGSizeMake(contentWidth, self.gridHeigth);
    
    if (self.chart.minRangeVal != self.chart.minRangeVal){
        self.chart.minRangeVal = self.chart.minX;
        self.chart.maxRangeVal = self.chart.maxX;
    }
    
    double timeOffest;
    if (self.chart.xAxis.nciAxisDecreasing){
        timeOffest =  self.chart.maxX - self.chart.maxRangeVal;
    } else {
        timeOffest = self.chart.minRangeVal - self.chart.minX;
    }

    if (timeOffest < 0 || timeOffest != timeOffest)
        timeOffest = 0;
    gridScroll.contentOffset = CGPointMake(timeOffest * stepX, 0);
    self.grid.frame = CGRectMake(timeOffest * stepX, 0, self.gridWidth, self.gridHeigth);
    [self.chart layoutSelectedPoint];
}

- (float)getScaleIndex{
    if ( self.chart.minRangeVal !=  self.chart.maxRangeVal  || self.chart.maxRangeVal !=  self.chart.maxRangeVal )
        return 1;
    float rangeDiff = [self getRangesPeriod];
    if (rangeDiff == 0){
        return  1;
    } else {
        return [self getXValuesGap]/rangeDiff;
    }
}

- (float)getXValuesGap{
    if (!self.chart.dataCount) return 0;
    return self.chart.maxX - self.chart.minX;
}

- (float)getRangesPeriod{
    return  self.chart.maxRangeVal - self.chart.minRangeVal;
}

- (float)getArgumentByX:(float) pointX{
    float scaleIndex = [self getScaleIndex];
    
    if (self.chart.xAxis.nciAxisDecreasing){
        return self.maxXVal - (gridScroll.contentOffset.x + pointX)/scaleIndex/self.xStep;
    } else {
        return self.minXVal + (gridScroll.contentOffset.x + pointX)/scaleIndex/self.xStep;
    }
}

- (float)getXByArgument:(float) arg{
    float scaleIndex = [self getScaleIndex];
    return [super getXByArgument:arg]* scaleIndex - gridScroll.contentOffset.x;
}

- (void)detectRanges{
    self.minYVal = self.chart.minY;
    self.maxYVal = self.chart.maxY;
    self.yStep = self.gridHeigth/(self.maxYVal - self.minYVal);
}

- (NSArray *)getFirstLast{
    return @[[NSNumber numberWithFloat:self.chart.minRangeVal], [NSNumber numberWithFloat:self.chart.maxRangeVal]];
}


@end
