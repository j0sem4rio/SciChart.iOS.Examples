//
//  LineChartViewController.m
//  SciChartDemo
//
//  Created by Yaroslav Pelyukh on 1/23/16.
//  Copyright © 2016 SciChart Ltd. All rights reserved.
//

#import "DashedLineChartView.h"
#import <SciChart/SciChart.h>

@implementation DashedLineChartView


@synthesize surface;

-(void) initializeSurfaceRenderableSeries{
    int dataCount = 20;
    SCIXyDataSeries * priceDataSeries = [[SCIXyDataSeries alloc] initWithXType:SCIDataType_Float YType:SCIDataType_Float];
    //Getting Fourier dataSeries
    for (int i = 0; i < dataCount; i++) {
        double time = 10 * i / (double)dataCount;
        double x = time;
        double y = arc4random_uniform(20);
        [priceDataSeries appendX:SCIGeneric(x) Y:SCIGeneric(y)];
    }
    
    dataCount = 1000;
    SCIXyDataSeries * fourierDataSeries = [[SCIXyDataSeries alloc] initWithXType:SCIDataType_Float YType:SCIDataType_Float];
    //Getting Fourier dataSeries
    for (int i = 0; i < dataCount; i++) {
        double time = 10 * i / (double)dataCount;
        double x = time;
        double y = 2 * sin(x)+10;
        [fourierDataSeries appendX:SCIGeneric(x) Y:SCIGeneric(y)];
    };
    
    SCIEllipsePointMarker * ellipsePointMarker = [[SCIEllipsePointMarker alloc]init];
    [ellipsePointMarker setFillStyle:[[SCISolidBrushStyle alloc] initWithColorCode:0xFFd6ffd7]];
    [ellipsePointMarker setHeight:5];
    [ellipsePointMarker setWidth:5];
    
    SCIFastLineRenderableSeries * priceRenderableSeries = [SCIFastLineRenderableSeries new];
    [priceRenderableSeries setPointMarker: ellipsePointMarker];
    [priceRenderableSeries setStrokeStyle: [[SCISolidPenStyle alloc] initWithColor:[UIColor fromARGBColorCode:0xFF99EE99]
                                                                       withThickness:1.f
                                                                       andStrokeDash:@[@(10.f), @(3.f), @(10.f), @(3.f)]] ];

    [priceRenderableSeries setXAxisId: @"xAxis"];
    [priceRenderableSeries setYAxisId: @"yAxis"];
    [priceRenderableSeries setDataSeries:priceDataSeries];
    [priceRenderableSeries addAnimation:[[SCIDrawLineRenderableSeriesAnimation alloc] initWithDuration:3 curveAnimation:SCIAnimationCurve_EaseOut]];
    [surface.renderableSeries add:priceRenderableSeries];
    
    SCIFastLineRenderableSeries * fourierRenderableSeries = [SCIFastLineRenderableSeries new];
    fourierRenderableSeries.strokeStyle = [[SCISolidPenStyle alloc] initWithColor:[UIColor fromARGBColorCode:0xFF4c8aff]
                                                                      withThickness:1.f
                                                                      andStrokeDash:@[@(50.f), @(14.f), @(50.f), @(14.f), @(50.f), @(14.f), @(50.f), @(14.f)]];
    fourierRenderableSeries.xAxisId = @"xAxis";
    fourierRenderableSeries.yAxisId = @"yAxis";
    [fourierRenderableSeries setDataSeries:fourierDataSeries];
    [fourierRenderableSeries addAnimation:[[SCIDrawLineRenderableSeriesAnimation alloc] initWithDuration:3 curveAnimation:SCIAnimationCurve_EaseOut]];
    [surface.renderableSeries add:fourierRenderableSeries];
    
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    if (self) {
        SCIChartSurface * view = [[SCIChartSurface alloc]initWithFrame:frame];
        surface = view;
        
        [surface setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addSubview:surface];
        NSDictionary *layout = @{@"SciChart":surface};
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(0)-[SciChart]-(0)-|" options:0 metrics:0 views:layout]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[SciChart]-(0)-|" options:0 metrics:0 views:layout]];
        
        [self initializeSurfaceData];
    }
    
    return self;
}

-(void) initializeSurfaceData {
    [self addAxes];
    [self addModifiers];
    [self initializeSurfaceRenderableSeries];
}

-(void) addAxes{

    id<SCIAxis2DProtocol> axis = [[SCINumericAxis alloc] init];
    axis.axisId = @"yAxis";
    [axis setGrowBy: [[SCIDoubleRange alloc]initWithMin:SCIGeneric(0.1) Max:SCIGeneric(0.1)]];
    [surface.yAxes add:axis];
    
    axis = [[SCINumericAxis alloc] init];
    axis.axisId = @"xAxis";
    [axis setGrowBy: [[SCIDoubleRange alloc]initWithMin:SCIGeneric(0.1) Max:SCIGeneric(0.1)]];
    [axis setFlipCoordinates:NO];
    [surface.xAxes add:axis];
}

-(void) addModifiers{
    SCIXAxisDragModifier * xDragModifier = [SCIXAxisDragModifier new];
    xDragModifier.axisId = @"xAxis";
    xDragModifier.dragMode = SCIAxisDragMode_Pan;
    xDragModifier.clipModeX = SCIClipMode_None;
    [xDragModifier setModifierName:@"XAxis DragModifier"];
    
    SCIYAxisDragModifier * yDragModifier = [SCIYAxisDragModifier new];
    yDragModifier.axisId = @"yAxis";
    yDragModifier.dragMode = SCIAxisDragMode_Pan;
    [yDragModifier setModifierName:@"YAxis DragModifier"];
    
    SCIPinchZoomModifier * pzm = [[SCIPinchZoomModifier alloc] init];
    [pzm setModifierName:@"PinchZoom Modifier"];
    
    SCIZoomExtentsModifier * zem = [[SCIZoomExtentsModifier alloc] init];
    [zem setModifierName:@"ZoomExtents Modifier"];
    
    SCIRolloverModifier * rollover = [[SCIRolloverModifier alloc] init];
    rollover.style.tooltipSize = CGSizeMake(200, NAN);
    [rollover setModifierName:@"Rollover Modifier"];
    
    SCIChartModifierCollection * gm = [[SCIChartModifierCollection alloc] initWithChildModifiers:@[xDragModifier, yDragModifier, pzm, zem, rollover]];
    surface.chartModifiers = gm;
}

@end
