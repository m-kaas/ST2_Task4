//
//  EventCollectionViewCell.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 7/2/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "EventCollectionViewCell.h"
#import "UIColor+CustomColors.h"
#import "UIFont+CustomFonts.h"

@interface EventCollectionViewCell ()

@property (weak, nonatomic) UILabel *eventTitleLabel;

@end

@implementation EventCollectionViewCell

- (void)commonInit {
    self.layer.cornerRadius = 3;
    UILabel *label = [UILabel new];
    [self addSubview:label];
    self.eventTitleLabel = label;
    self.eventTitleLabel.frame = self.bounds;
    self.eventTitleLabel.textColor = [UIColor customBlackColor];
    self.eventTitleLabel.font = [UIFont system17MediumFont];
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

- (void)prepareForReuse {
    //self.backgroundColor = [UIColor clearColor];
    self.eventTitleLabel.text = @"";
}

- (void)setEvent:(EKEvent *)event {
    if (![_event isEqual:event]) {
        _event = event;
    }
    UIColor *calendarColor = [UIColor colorWithCGColor:self.event.calendar.CGColor];
    //self.backgroundColor = [calendarColor colorWithAlphaComponent:0.5];
    self.eventTitleLabel.text = event.title;
}

@end
