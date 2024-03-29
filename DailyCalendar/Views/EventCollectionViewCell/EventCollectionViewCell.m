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

#pragma mark - Lifecycle

- (void)commonInit {
    self.layer.cornerRadius = 3;
    UILabel *label = [UILabel new];
    [self.contentView addSubview:label];
    self.eventTitleLabel = label;
    self.eventTitleLabel.textColor = [UIColor customBlackColor];
    self.eventTitleLabel.font = [UIFont system17MediumFont];
    self.eventTitleLabel.numberOfLines = 0;
    self.eventTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.eventTitleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.leadingAnchor],
        [self.eventTitleLabel.topAnchor constraintEqualToAnchor:self.contentView.layoutMarginsGuide.topAnchor],
        [self.contentView.layoutMarginsGuide.trailingAnchor constraintEqualToAnchor:self.eventTitleLabel.trailingAnchor],
        [self.contentView.layoutMarginsGuide.bottomAnchor constraintGreaterThanOrEqualToAnchor:self.eventTitleLabel.bottomAnchor]]];
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
    self.backgroundColor = [UIColor clearColor];
    self.eventTitleLabel.text = @"";
}

#pragma mark - Custom Accessors

- (void)setEvent:(EKEvent *)event {
    if (_event != event) {
        _event = event;
    }
    UIColor *calendarColor = [UIColor colorWithCGColor:event.calendar.CGColor];
    if (!calendarColor) {
        calendarColor = [UIColor customRedColor];
    }
    self.backgroundColor = [calendarColor colorWithAlphaComponent:0.5];
    self.eventTitleLabel.text = event.title;
}

@end
