//
//  DottedLineView.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/3/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "DottedLineView.h"
#import "UIColor+CustomColors.h"

const CGFloat dotSize = 2;

@implementation DottedLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];
    path.lineWidth = dotSize / 2;
    CGFloat centerY = rect.size.height * 0.5;
    [path moveToPoint:(CGPointMake(0, centerY))];
    [path addLineToPoint:(CGPointMake(rect.size.width, centerY))];
    CGFloat dashes[] = {0, 6};
    [path setLineDash:dashes count:2 phase:0];
    path.lineCapStyle = kCGLineCapRound;
    [[UIColor customLightGrayColor] setStroke];
    [path stroke];
    
}

@end
