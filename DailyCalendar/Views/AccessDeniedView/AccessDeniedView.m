//
//  AccessDeniedView.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 6/29/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "AccessDeniedView.h"
#import "UIColor+CustomColors.h"
#import "UIFont+CustomFonts.h"

@interface AccessDeniedView ()

@property (weak, nonatomic) UILabel *textLable;

@end

@implementation AccessDeniedView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor customLightGrayColor];
        UILabel *accessDeniedLabel = [UILabel new];
        accessDeniedLabel.textColor = [UIColor customBlackColor];
        accessDeniedLabel.font = [UIFont system17RegularFont];
        accessDeniedLabel.numberOfLines = 0;
        accessDeniedLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:accessDeniedLabel];
        self.textLable = accessDeniedLabel;
        accessDeniedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[[accessDeniedLabel.centerXAnchor constraintEqualToAnchor:self.centerXAnchor],
                                                  [accessDeniedLabel.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
                                                  [accessDeniedLabel.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:20],
                                                  [self.trailingAnchor constraintEqualToAnchor:accessDeniedLabel.trailingAnchor constant:20]]];
    }
    return self;
}

- (void)setLabelText:(NSString *)text {
    self.textLable.text = text;
}

@end
