//
//  WeekCollectionViewCell.m
//  DailyCalendar
//
//  Created by Liubou Sakalouskaya on 6/30/19.
//  Copyright © 2019 Liubou Sakalouskaya. All rights reserved.
//

#import "WeekCollectionViewCell.h"
#import "UIColor+CustomColors.h"
#import "UIFont+CustomFonts.h"

@implementation WeekCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.dateLabel.textColor = [UIColor customWhiteColor];
    self.dateLabel.font = [UIFont system17SemiboldFont];
    self.dayLabel.textColor = [UIColor customWhiteColor];
    self.dayLabel.font = [UIFont system12RegularFont];
    self.dotLabel.font = [UIFont system17SemiboldFont];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.selected = NO;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.backgroundColor = [UIColor customRedColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

@end
