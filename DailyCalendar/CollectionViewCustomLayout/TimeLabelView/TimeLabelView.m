//
//  TimeLabelView.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/3/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "TimeLabelView.h"
#import "TimeLabelViewLayoutAttributes.h"
#import "UIColor+CustomColors.h"
#import "UIFont+CustomFonts.h"

@interface TimeLabelView ()

@property (weak, nonatomic) UILabel *timeLabel;

@end

@implementation TimeLabelView

- (void)commonInit {
    UILabel *label = [UILabel new];
    [self addSubview:label];
    self.timeLabel = label;
    self.timeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[[self.timeLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
                                              [self.timeLabel.topAnchor constraintEqualToAnchor:self.topAnchor],
                                              [self.trailingAnchor constraintEqualToAnchor:self.timeLabel.trailingAnchor],
                                              [self.bottomAnchor constraintEqualToAnchor:self.timeLabel.bottomAnchor]]];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [super applyLayoutAttributes:layoutAttributes];
    if ([layoutAttributes isKindOfClass:[TimeLabelViewLayoutAttributes class]]) {
        TimeLabelViewLayoutAttributes *attr = (TimeLabelViewLayoutAttributes *)layoutAttributes;
        self.timeLabel.text = attr.timeText;
        self.timeLabel.textColor = attr.textColor;
        self.timeLabel.font = attr.font;
    }
}

@end
