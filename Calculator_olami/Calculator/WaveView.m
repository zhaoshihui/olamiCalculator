//
//  WaveView.m
//  Calculator
//
//  Created by Scarlett on 2017/7/4.
//  Copyright © 2017年 Scarlett Zhao. All rights reserved.
//

#import "WaveView.h"

@interface WaveView ()
{
    float _currentLinePointY;//变了y轴改变
    
    float maxA;//波峰
    float moveX;//x轴移动
    
    CGRect _MYframe;

}

@end

@implementation WaveView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        _present = 0.5;
        
        maxA = 5;
        moveX = 10;
        
        _MYframe = frame;
        
        _currentLinePointY = 150;//距离上面
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect{

    //1.
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = CGPathCreateMutable();

    CGContextSetLineWidth(context, 3);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetRGBStrokeColor(context, 255.0 / 255.0, 0.0 / 255.0, 255.0 / 255.0, 1.0);  //线的颜色
    CGContextBeginPath(context);
    
    float y= (1 - self.present) * rect.size.height;
    float y1= (1 - self.present) * rect.size.height;
    
    CGPathMoveToPoint(path, NULL, 0, y);
    for(float x=0;x<=rect.size.width;x++){
        y=  sin( 3*x/rect.size.width * M_PI + moveX/rect.size.width *M_PI ) *maxA + _currentLinePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGContextAddPath(context, path);
    
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
    
    
    //2.
    CGMutablePathRef path1 = CGPathCreateMutable();
    CGContextSetLineWidth(context, 1);
    
    CGPathMoveToPoint(path1, NULL, 0, y1);
    for(float x=0;x<=rect.size.width;x++){
        
        y1= sin( 3*x/rect.size.width * M_PI + moveX/rect.size.width *M_PI  +M_PI ) *maxA + _currentLinePointY ;
        CGPathAddLineToPoint(path1, nil, x, y1);
    }
    
    
    CGContextAddPath(context, path1);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path1);
    
    [self setNeedsDisplay];

}


- (void)setPresent:(CGFloat)present{
    _present = present;
    
    //修改波浪的幅度
    maxA = _MYframe.size.height  * _present * 0.5;

    moveX = moveX+100;
    if (moveX >= _MYframe.size.width * 2.0) {
        moveX = 0;
    }
    [self setNeedsDisplay];
}

@end
